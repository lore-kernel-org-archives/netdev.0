From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 2/7] rtnetlink: add helper to put master ifindex
Date: Thu, 21 Sep 2017 11:16:59 -0600
Message-ID: <286fbbfa-d387-debe-bd9d-185376a2c9a5@gmail.com>
References: <20170921165902.10746-1-fw@strlen.de>
 <20170921165902.10746-3-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33755 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752420AbdIURQ6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 13:16:58 -0400
Received: by mail-pf0-f195.google.com with SMTP id h4so2733590pfk.0
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 10:16:58 -0700 (PDT)
In-Reply-To: <20170921165902.10746-3-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/21/17 10:58 AM, Florian Westphal wrote:

> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index a78fd61da0ec..c801212ee40e 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1307,6 +1307,31 @@ static u32 rtnl_get_event(unsigned long event)
>  	return rtnl_event_type;
>  }
>  
> +static int put_master_ifindex(struct sk_buff *skb, struct net_device *dev)
> +{
> +	const struct net_device *upper_dev;
> +	int ret = 0;
> +
> +	rcu_read_lock();
> +
> +	upper_dev = netdev_master_upper_dev_get_rcu(dev);
> +	if (upper_dev)
> +		ret = nla_put_u32(skb, IFLA_MASTER, upper_dev->ifindex);
> +
> +	rcu_read_unlock();
> +	return ret;
> +}
> +
> +static int nla_put_iflink(struct sk_buff *skb, const struct net_device *dev)
> +{
> +	int ifindex = dev_get_iflink(dev);
> +
> +	if (dev->ifindex == ifindex)
> +		return 0;
> +
> +	return nla_put_u32(skb, IFLA_LINK, ifindex);
> +}
> +
>  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			    int type, u32 pid, u32 seq, u32 change,
>  			    unsigned int flags, u32 ext_filter_mask,

Subject references only change for master index, put the patch is
converting 2 things to helpers.
