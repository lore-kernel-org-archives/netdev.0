From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] ip: introduce ip_is_fragment helper inline
 function
Date: Fri, 17 Jun 2011 19:19:24 +0100
Message-ID: <1308334764.2831.18.camel@bwh-desktop>
References: <1308334091-10031-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:49603 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932107Ab1FQST2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 14:19:28 -0400
In-Reply-To: <1308334091-10031-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-17 at 14:08 -0400, Paul Gortmaker wrote:
> There are enough instances of this:
> 
>     iph->frag_off & htons(IP_MF | IP_OFFSET)
> 
> that a helper function is probably warranted.
[...]
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -4111,7 +4111,7 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
>  			struct tcphdr *th;
>  			ip = ip_hdr(skb);
>  
> -			if ((ip->frag_off & htons(IP_OFFSET|IP_MF)) == 0) {
> +			if (ip_is_fragment(ip) == 0) {
>  				th = (struct tcphdr *)(((unsigned char *)ip) +
>  						       ip->ihl*4);
>  

The condition should be written more clearly as !ip_is_fragment().

[...]
> diff --git a/include/net/ip.h b/include/net/ip.h
> index e9ea7c7..114a152 100644
> --- a/include/net/ip.h
> +++ b/include/net/ip.h
> @@ -250,6 +250,11 @@ int ip_decrease_ttl(struct iphdr *iph)
>  	return --iph->ttl;
>  }
>  
> +static inline int ip_is_fragment(const struct iphdr *iph)
> +{
> +	return iph->frag_off & htons(IP_MF | IP_OFFSET);
> +}
> +
>  static inline
>  int ip_dont_fragment(struct sock *sk, struct dst_entry *dst)
>  {
[..]

The return type should be bool.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

