From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] xen-netback: Fix handling of skbs requiring too
 many slots
Date: Thu, 05 Jun 2014 15:09:52 -0700 (PDT)
Message-ID: <20140605.150952.1419101660779617906.davem@davemloft.net>
References: <1401908331-13297-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, ian.campbell@citrix.com,
	wei.liu2@citrix.com, paul.durrant@citrix.com, linux@eikelenboom.it,
	netdev@vger.kernel.org, david.vrabel@citrix.com
To: zoltan.kiss@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631AbaFEWJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 18:09:53 -0400
In-Reply-To: <1401908331-13297-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Wed, 4 Jun 2014 19:58:51 +0100

> A recent commit (a02eb4 "xen-netback: worse-case estimate in xenvif_rx_action is
> underestimating") capped the slot estimation to MAX_SKB_FRAGS, but that triggers
> the next BUG_ON a few lines down, as the packet consumes more slots than
> estimated.
> This patch introduces full_coalesce on the skb callback buffer, which is used in
> start_new_rx_buffer() to decide whether netback needs coalescing more
> aggresively. By doing that, no packet should need more than
> (XEN_NETIF_MAX_TX_SIZE + 1) / PAGE_SIZE data slots (excluding the optional GSO
> slot, it doesn't carry data, therefore irrelevant in this case), as the provided
> buffers are fully utilized.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Applied, and:

> -		if (max_slots_needed > MAX_SKB_FRAGS)
> +		if (max_slots_needed > MAX_SKB_FRAGS) {
>  			max_slots_needed = MAX_SKB_FRAGS;
> +			XENVIF_RX_CB(skb)->full_coalesce = true;
> +		} else
> +			XENVIF_RX_CB(skb)->full_coalesce = false;

I took care of adding the {} to the else block, as suggested by Wei Liu.
