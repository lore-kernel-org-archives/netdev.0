From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net: macb: replace macb_writel() call by
 queue_writel() to update queue ISR
Date: Thu, 24 Mar 2016 14:50:48 -0400 (EDT)
Message-ID: <20160324.145048.1317096517497751465.davem@davemloft.net>
References: <1458830404-6213-1-git-send-email-cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, soren.brinkmann@xilinx.com,
	linux-kernel@vger.kernel.org
To: cyrille.pitchen@atmel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52367 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751908AbcCXSuv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:50:51 -0400
In-Reply-To: <1458830404-6213-1-git-send-email-cyrille.pitchen@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Date: Thu, 24 Mar 2016 15:40:04 +0100

> macb_interrupt() should not use macb_writel(bp, ISR, <value>) but only
> queue_writel(queue, ISR, <value>).
> 
> There is one IRQ and one set of {ISR, IER, IDR, IMR} [1] registers per
> queue on gem hardware, though only queue0 is actually used for now to
> receive frames: other queues can already be used to transmit frames.
> 
> The queue_readl() and queue_writel() helper macros are designed to access
> the relevant IRQ registers.
> 
> [1]
> ISR: Interrupt Status Register
> IER: Interrupt Enable Register
> IDR: Interrupt Disable Register
> IMR: Interrupt Mask Register
> 
> Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
> Fixes: bfbb92c44670 ("net: macb: Handle the RXUBR interrupt on all devices")

Applied, thanks.
