From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next v2 01/12] bnxt_en: Refactor rx SKB function.
Date: Thu, 2 Feb 2017 14:56:55 -0800
Message-ID: <20170202145655.6b1ae712@cakuba.netronome.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
        <1486054540-366-2-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:43305 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751500AbdBBW5O (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 17:57:14 -0500
In-Reply-To: <1486054540-366-2-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  2 Feb 2017 11:55:29 -0500, Michael Chan wrote:
> @@ -755,8 +757,8 @@ static void bnxt_reuse_rx_agg_bufs(struct bnxt_napi *bnapi, u16 cp_cons,
>  
>  static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
>  				   struct bnxt_rx_ring_info *rxr, u16 cons,
> -				   u16 prod, u8 *data, dma_addr_t dma_addr,
> -				   unsigned int len)
> +				   u16 prod, void *data, dma_addr_t dma_addr,
> +				   unsigned int offset_and_len)
>  {
>  	int err;
>  	struct sk_buff *skb;
> @@ -776,7 +778,7 @@ static struct sk_buff *bnxt_rx_skb(struct bnxt *bp,
>  	}
>  
>  	skb_reserve(skb, BNXT_RX_OFFSET);
> -	skb_put(skb, len);
> +	skb_put(skb, offset_and_len & 0xffff);
>  	return skb;
>  }
>  

Sorry to be a pain but I still don't understand (a) why you make this
change in the first patch if it's only needed from patch 5 on; (b) why
do you encode the two parameters in a single u32?  It's the seventh
parameter so it's going on the stack anyway, no?
