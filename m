From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [net-next:master 90/102] net/ipv4/route.c:1283:9: warning:
 unused variable 'saddr'
Date: Thu, 12 Jul 2012 22:54:44 +0800
Message-ID: <20120712145444.GA20982@localhost>
References: <20120712143449.GA19890@localhost>
 <20120712.074058.753681400854318989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:44142 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932571Ab2GLOyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2012 10:54:49 -0400
Content-Disposition: inline
In-Reply-To: <20120712.074058.753681400854318989.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK!

On Thu, Jul 12, 2012 at 07:40:58AM -0700, David Miller wrote:
> 
> There's not need to report these to kernel-janitors if it's a
> net-next specific issue and I'm going to fix it up 5 minutes
> after you report it.
> 
> ====================
> [PATCH] ipv4: Fix warnings in ip_do_redirect() for some configurations.
> 
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/ipv4/route.c |   10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index 23bbe29..9319bf1 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -1275,12 +1275,9 @@ static void rt_del(unsigned int hash, struct rtable *rt)
>  
>  static void ip_do_redirect(struct dst_entry *dst, struct sk_buff *skb)
>  {
> -	const struct iphdr *iph = (const struct iphdr *) skb->data;
>  	__be32 new_gw = icmp_hdr(skb)->un.gateway;
>  	__be32 old_gw = ip_hdr(skb)->saddr;
>  	struct net_device *dev = skb->dev;
> -	__be32 daddr = iph->daddr;
> -	__be32 saddr = iph->saddr;
>  	struct in_device *in_dev;
>  	struct neighbour *n;
>  	struct rtable *rt;
> @@ -1336,11 +1333,16 @@ static void ip_do_redirect(struct dst_entry *dst, struct sk_buff *skb)
>  
>  reject_redirect:
>  #ifdef CONFIG_IP_ROUTE_VERBOSE
> -	if (IN_DEV_LOG_MARTIANS(in_dev))
> +	if (IN_DEV_LOG_MARTIANS(in_dev)) {
> +		const struct iphdr *iph = (const struct iphdr *) skb->data;
> +		__be32 daddr = iph->daddr;
> +		__be32 saddr = iph->saddr;
> +
>  		net_info_ratelimited("Redirect from %pI4 on %s about %pI4 ignored\n"
>  				     "  Advised path = %pI4 -> %pI4\n",
>  				     &old_gw, dev->name, &new_gw,
>  				     &saddr, &daddr);
> +	}
>  #endif
>  	;
>  }
> -- 
> 1.7.10.4
