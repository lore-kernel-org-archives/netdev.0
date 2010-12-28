From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip: reuse ip_summed of first fragment for all
 subsequent fragments
Date: Tue, 28 Dec 2010 13:49:05 -0800 (PST)
Message-ID: <20101228.134905.183040321.davem@davemloft.net>
References: <20101217.115837.39184596.davem@davemloft.net>
	<1292841525-15572-1-git-send-email-timo.lindfors@iki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timo.lindfors@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47914
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752133Ab0L1Vse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Dec 2010 16:48:34 -0500
In-Reply-To: <1292841525-15572-1-git-send-email-timo.lindfors@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timo Juhani Lindfors <timo.lindfors@iki.fi>
Date: Mon, 20 Dec 2010 12:38:45 +0200

> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 439d2a3..c0743ed 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1167,7 +1167,7 @@ ssize_t	ip_append_page(struct sock *sk, struct page *page,
>  			/*
>  			 *	Fill in the control structures
>  			 */
> -			skb->ip_summed = CHECKSUM_NONE;
> +			skb->ip_summed = skb_prev->ip_summed;
>  			skb->csum = 0;
>  			skb_reserve(skb, hh_len);

You can't just assign skb_prev->ip_summed here, if it's CHECKSUM_PARTIAL
then things will go completely wrong.  This is especially true since
we're about to zero out skb->csum.
