From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 4/6] rtnetlink: add helper to dump ifalias
Date: Sat, 23 Sep 2017 11:14:19 -0600
Message-ID: <5184e670-8061-16d5-1185-40efa90cac99@gmail.com>
References: <20170922061008.14723-1-fw@strlen.de>
 <20170922061008.14723-5-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37119 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbdIWROV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 23 Sep 2017 13:14:21 -0400
Received: by mail-pf0-f195.google.com with SMTP id e69so1792739pfg.4
        for <netdev@vger.kernel.org>; Sat, 23 Sep 2017 10:14:21 -0700 (PDT)
In-Reply-To: <20170922061008.14723-5-fw@strlen.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/22/17 12:10 AM, Florian Westphal wrote:
> ifalias is currently protected by rtnl mutex, add assertion
> as a reminder.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  net/core/rtnetlink.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index ad3f27da37a8..42ff582a010e 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1345,6 +1345,16 @@ static int nla_put_qdisc(struct sk_buff *skb, struct net_device *dev)
>  	return ret;
>  }
>  
> +static noinline int nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)
> +{
> +	ASSERT_RTNL();

The assert is not needed given the code path.

> +
> +	if (dev->ifalias)
> +		return nla_put_string(skb, IFLA_IFALIAS, dev->ifalias);
> +
> +	return 0;
> +}
> +
>  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			    int type, u32 pid, u32 seq, u32 change,
>  			    unsigned int flags, u32 ext_filter_mask,
> @@ -1386,8 +1396,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  	    put_master_ifindex(skb, dev) ||
>  	    nla_put_u8(skb, IFLA_CARRIER, netif_carrier_ok(dev)) ||
>  	    nla_put_qdisc(skb, dev) ||
> -	    (dev->ifalias &&
> -	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)) ||
> +	    nla_put_ifalias(skb, dev) ||
>  	    nla_put_u32(skb, IFLA_CARRIER_CHANGES,
>  			atomic_read(&dev->carrier_changes)) ||
>  	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
> 

Reviewed-by: David Ahern <dsahern@gmail.com>
