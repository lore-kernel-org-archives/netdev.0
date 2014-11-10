From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [patch net-next v2 01/10] net: rename netdev_phys_port_id to
 more generic name
Date: Sun, 09 Nov 2014 22:35:12 -0500
Message-ID: <54603270.509@mojatatu.com>
References: <1415530280-9190-1-git-send-email-jiri@resnulli.us> <1415530280-9190-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	roopa@cumulusnetworks.com, linville@tuxdriver.com,
	jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:44797 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095AbaKJDfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Nov 2014 22:35:20 -0500
Received: by mail-ie0-f180.google.com with SMTP id y20so8227984ier.25
        for <netdev@vger.kernel.org>; Sun, 09 Nov 2014 19:35:19 -0800 (PST)
In-Reply-To: <1415530280-9190-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 11/09/14 05:51, Jiri Pirko wrote:
> So this can be reused for identification of other "items" as well.
>




>
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 9dd0669..55dc4da 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -387,7 +387,7 @@ static ssize_t phys_port_id_show(struct device *dev,
>   		return restart_syscall();
>
>   	if (dev_isalive(netdev)) {
> -		struct netdev_phys_port_id ppid;
> +		struct netdev_phys_item_id ppid;
>
>   		ret = dev_get_phys_port_id(netdev, &ppid);
>   		if (!ret)
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index a688268..1087c6d 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -868,7 +868,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>   	       + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
>   	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
>   	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
> -	       + nla_total_size(MAX_PHYS_PORT_ID_LEN); /* IFLA_PHYS_PORT_ID */
> +	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_PORT_ID */
>   }
>

[...]
>   static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
> @@ -952,7 +952,7 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev,
>   static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
>   {
>   	int err;
> -	struct netdev_phys_port_id ppid;
> +	struct netdev_phys_item_id ppid;
>
>   	err = dev_get_phys_port_id(dev, &ppid);
>   	if (err) {
> @@ -1196,7 +1196,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>   	[IFLA_PROMISCUITY]	= { .type = NLA_U32 },
>   	[IFLA_NUM_TX_QUEUES]	= { .type = NLA_U32 },
>   	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
> -	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_PORT_ID_LEN },
> +	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>   	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
>   };


wouldnt this just break an existing ABI? You may need to introduce a new 
attribute.

cheers,
jamal
