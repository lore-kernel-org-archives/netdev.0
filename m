From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next PATCH v2 2/2] bridge: netlink dump interface at par
 with brctl
Date: Tue, 24 Jun 2014 08:29:01 -0700
Message-ID: <1403623741.3796.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1403619319-16131-1-git-send-email-jhs@emojatatu.com>
	 <1403619319-16131-3-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, stephen@networkplumber.org,
	netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:39970 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752564AbaFXP3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2014 11:29:08 -0400
Received: by mail-wg0-f51.google.com with SMTP id x12so532132wgg.34
        for <netdev@vger.kernel.org>; Tue, 24 Jun 2014 08:29:05 -0700 (PDT)
In-Reply-To: <1403619319-16131-3-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-06-24 at 10:15 -0400, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 

...

>  
>  static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  {
> -	int idx = 0;
> -	struct net *net = sock_net(skb->sk);
>  	struct net_device *dev;
> +	struct nlattr *tb[IFLA_MAX+1];
> +	struct net_device *bdev = NULL;
> +	struct net_device *br_dev = NULL;
> +	const struct net_device_ops *ops = NULL;
> +	const struct net_device_ops *cops = NULL;
> +	struct ifinfomsg *ifm = nlmsg_data(cb->nlh);
> +	struct net *net = sock_net(skb->sk);
> +	int brport_idx = 0;
> +	int br_idx = 0;
> +	int idx = 0;
> +
> +	if (nlmsg_parse(cb->nlh, sizeof(struct ifinfomsg), tb, IFLA_MAX,
> +			ifla_policy) == 0) {
> +		if (tb[IFLA_MASTER])
> +			br_idx = nla_get_u32(tb[IFLA_MASTER]);
> +	}
> +	
> +	brport_idx = ifm->ifi_index;
> +
> +	if (br_idx) {
> +		br_dev = __dev_get_by_index(net, br_idx);
> +		if (!br_dev) {
> +			return -ENODEV;
> +		}
> +		ops = br_dev->netdev_ops;
> +		bdev = br_dev;
> +	}
>  
> -	rcu_read_lock();
>  	for_each_netdev_rcu(net, dev) {


for_each_netdev() 
