From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 rx descriptors
Date: Mon, 16 Jun 2008 00:04:10 +0200
Message-ID: <20080615220410.GA10522@electric-eye.fr.zoreil.com>
References: <20080615211030.M80450@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:46865 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751436AbYFOWd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2008 18:33:26 -0400
Content-Disposition: inline
In-Reply-To: <20080615211030.M80450@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denys Fedoryshchenko <denys@visp.net.lb> :
[...]
> Why in Linux source:
> 
> #define NUM_TX_DESC     64      /* Number of Tx descriptor registers */
> #define NUM_RX_DESC     256     /* Number of Rx descriptor registers */

One do not necessarily gain much from a huge Rx / Tx ring. You can
increase NUM_RX_DESC though.

> Is it possible to do them changeable over ethtool -g ?

Yes.

> Maybe NetBSD developers signed NDA and have access to datasheets?

A NDA is not needed. You can get in touch with Edward Hsu
<edward_hsu@realtek.com.tw> if you have some questions.

It can help for the moderately documented irq mitigation register.

> Also i seen in one patch from Realtek , something similar to
> -#define RX_DMA_BURST    6       /* Maximum PCI burst, '6' is 1024 */
> +#define RX_DMA_BURST    7       /* Maximum PCI burst, '6' is 1024 */
> 
> Why it is reverted or not applied?

I do not always apply Realtek's changes blindly. This one could make a
difference though.

> In sources from Realtek website it is 
> #define RX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */
> #define TX_DMA_BURST	7	/* Maximum PCI burst, '7' is unlimited */
> 
> I will try to change burst settings on my router, and waiting comments about 

Apparently 1) you are experiencing Rx fifo overflows 2) your mean packet
stands at 300 bytees. I'd try to lower RX_FIFO_THRESH first then lower
TX_DMA_BURST.

-- 
Ueimor
