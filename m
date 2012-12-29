From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [Patch RFC] ndisc: Fix skb allocation size for link layer options.
Date: Sun, 30 Dec 2012 00:29:14 +0900
Message-ID: <50DF0C4A.5020401@linux-ipv6.org>
References: <1356702410-32293-1-git-send-email-stephan.gatzka@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Stephan Gatzka <stephan.gatzka@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44680 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752070Ab2L2P3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Dec 2012 10:29:16 -0500
In-Reply-To: <1356702410-32293-1-git-send-email-stephan.gatzka@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephan Gatzka wrote:
> Signed-off-by: Stephan Gatzka <stephan.gatzka@gmail.com>
> ---
>  net/ipv6/ndisc.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> index 6574175..b12b94c 100644
> --- a/net/ipv6/ndisc.c
> +++ b/net/ipv6/ndisc.c
> @@ -392,7 +392,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
>  
>  	len = sizeof(struct icmp6hdr) + (target ? sizeof(*target) : 0);
>  	if (llinfo)
> -		len += ndisc_opt_addr_space(dev);
> +		len += sizeof(struct nd_opt_hdr) + ndisc_opt_addr_space(dev);
>  
>  	skb = sock_alloc_send_skb(sk,
>  				  (MAX_HEADER + sizeof(struct ipv6hdr) +
> @@ -1424,7 +1424,8 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
>  			memcpy(ha_buf, neigh->ha, dev->addr_len);
>  			read_unlock_bh(&neigh->lock);
>  			ha = ha_buf;
> -			len += ndisc_opt_addr_space(dev);
> +			len += sizeof(struct nd_opt_hdr) +
> +				ndisc_opt_addr_space(dev);
>  		} else
>  			read_unlock_bh(&neigh->lock);
>  
> 

Disagree.  NDISC_OPT_SPACE() takes care size of nd option header.

--yoshfuji
