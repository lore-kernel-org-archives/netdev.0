From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] defxx: Remove an incorrectly inverted preprocessor
 conditional
Date: Wed, 02 Jul 2014 18:25:32 -0700 (PDT)
Message-ID: <20140702.182532.2188312011824918761.davem@davemloft.net>
References: <alpine.LFD.2.11.1406290059510.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42631 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525AbaGCBZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 21:25:33 -0400
In-Reply-To: <alpine.LFD.2.11.1406290059510.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Sun, 29 Jun 2014 01:45:53 +0100 (BST)

> The RX handler of the driver has two paths switched between, depending on 
> the size of the frame received, as determined by SKBUFF_RX_COPYBREAK.  
> 
> When a small frame is received, a new skb allocated has data space large 
> enough to hold the incoming frame only, and data is copied there from the 
> original skb whose buffer is returned to the DMA RX ring; in that case 
> `rx_in_place' is 0.  When a large frame is received, a new skb allocated 
> has data space large enough to hold the largest frame possible, including 
> the overhead for alignment, the receive status and padding, over 4.5kiB 
> overall, and its buffer is placed on the DMA RX ring while the original 
> buffer is passed up to the network stack avoiding the need to copy data; 
> in that case `rx_in_place' is 1.
> 
> However the latter scenario is only possible when dynamic buffers are 
> used, as determined by DYNAMIC_BUFFERS, because otherwise the buffers used 
> for the DMA RX ring are fixed at the time the interface is brought up.
> 
> That leads to an observation that the preprocessor conditional around the 
> `rx_in_place' check is inverted, the check only really matters when 
> dynamic buffers are in use.  It has gone unnoticed for many years since 
> support for using dynamic buffers on the DMA RX ring was introduced in 
> 2.1.40 -- because the only problem that results is in the case where 
> `rx_in_place' is 1 frame data received is unnecessarily copied to the 
> newly-allocated buffer, before the buffer placed on the the DMA receive RX 
> and its contents ignored.  Therefore the only symptom is some performance 
> loss.
> 
> Rather than flipping the condition though I decided to discard the 
> conditional altogether -- in the case of static buffers `rx_in_place' is 
> always 0 so GCC will optimise the C conditional away instead.
> 
> Tested on a few DEFPA and DEFTA boards successfully using both small and 
> large frames, both with DYNAMIC_BUFFERS defined and with the macro 
> undefined.
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>

Applied, thanks.
