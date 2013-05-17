From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [Patch net-next v8 02/11] ipv6: make ip6_dst_hoplimit() static
 inline
Date: Fri, 17 May 2013 17:02:34 +0400
Message-ID: <51962A6A.5000009@cogentembedded.com>
References: <1368750099-14086-1-git-send-email-amwang@redhat.com> <1368750099-14086-3-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:55172 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535Ab3EQNCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 May 2013 09:02:36 -0400
Received: by mail-lb0-f176.google.com with SMTP id x10so4349272lbi.35
        for <netdev@vger.kernel.org>; Fri, 17 May 2013 06:02:35 -0700 (PDT)
In-Reply-To: <1368750099-14086-3-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 17-05-2013 4:21, Cong Wang wrote:

> From: Cong Wang <amwang@redhat.com>

> It will be used by vxlan module, so move it from ipv6 module
> to core kernel. I think it is small enough to be inlined.

> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>   include/net/ip6_route.h |   23 +++++++++++++++++++++--
>   net/ipv6/route.c        |   19 -------------------
>   2 files changed, 21 insertions(+), 21 deletions(-)

> diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
> index 260f83f..7e9192e 100644
> --- a/include/net/ip6_route.h
> +++ b/include/net/ip6_route.h
[...]
> @@ -201,4 +200,24 @@ static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr
>   	return dest;
>   }
>
> +#if IS_ENABLED(CONFIG_IPV6)
> +static inline int ip6_dst_hoplimit(struct dst_entry *dst)
> +{
> +	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);

     Empty line wouldn't hurt here, after the declaration, like below...

> +	if (hoplimit == 0) {
> +		struct net_device *dev = dst->dev;
> +		struct inet6_dev *idev;
> +
> +		rcu_read_lock();
> +		idev = __in6_dev_get(dev);
> +		if (idev)
> +			hoplimit = idev->cnf.hop_limit;
> +		else
> +			hoplimit = dev_net(dev)->ipv6.devconf_all->hop_limit;
> +		rcu_read_unlock();
> +	}
> +	return hoplimit;
> +}
> +#endif
> +

WBR, Sergei
