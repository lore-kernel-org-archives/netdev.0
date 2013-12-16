From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 9/10] lro: remove unused code
Date: Mon, 16 Dec 2013 19:54:27 +0000
Message-ID: <1387223667.1799.32.camel@bwh-desktop.uk.level5networks.com>
References: <20131216103606.62524131@nehalam.linuxnetplumber.net>
	 <20131216104531.27407d6f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:16667 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654Ab3LPTyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 14:54:32 -0500
In-Reply-To: <20131216104531.27407d6f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-16 at 10:45 -0800, Stephen Hemminger wrote:
> This code is not used anywhere in net-next
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
[...]
> --- a/net/ipv4/inet_lro.c	2013-10-06 14:48:24.966449847 -0700
> +++ b/net/ipv4/inet_lro.c	2013-12-12 13:28:43.435225437 -0800
> @@ -506,23 +506,6 @@ void lro_receive_skb(struct net_lro_mgr
>  }
>  EXPORT_SYMBOL(lro_receive_skb);
>  
> -void lro_receive_frags(struct net_lro_mgr *lro_mgr,
> -		       struct skb_frag_struct *frags,
> -		       int len, int true_size, void *priv, __wsum sum)
> -{
> -	struct sk_buff *skb;
> -
> -	skb = __lro_proc_segment(lro_mgr, frags, len, true_size, priv, sum);

You should remove unused functions recursively.  After this, you can
remove at least __lro_proc_segment(), lro_gen_skb() and lro_add_frags().

> -	if (!skb)
> -		return;
> -
> -	if (lro_mgr->features & LRO_F_NAPI)
> -		netif_receive_skb(skb);
> -	else
> -		netif_rx(skb);
> -}
> -EXPORT_SYMBOL(lro_receive_frags);
> -
>  void lro_flush_all(struct net_lro_mgr *lro_mgr)
>  {
>  	int i;
> @@ -534,14 +517,3 @@ void lro_flush_all(struct net_lro_mgr *l
>  	}
>  }
>  EXPORT_SYMBOL(lro_flush_all);
> -
> -void lro_flush_pkt(struct net_lro_mgr *lro_mgr,
> -		  struct iphdr *iph, struct tcphdr *tcph)
> -{
> -	struct net_lro_desc *lro_desc;
> -
> -	lro_desc = lro_get_desc(lro_mgr, lro_mgr->lro_arr, iph, tcph);
> -	if (lro_desc->active)
> -		lro_flush(lro_mgr, lro_desc);
> -}
> -EXPORT_SYMBOL(lro_flush_pkt);

It looks like lro_flush_pkt() was *never* used!

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
