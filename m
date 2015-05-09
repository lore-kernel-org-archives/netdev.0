From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] gianfar: Move TxFIFO underrun handling to
 reset path
Date: Sat, 09 May 2015 17:37:56 -0400 (EDT)
Message-ID: <20150509.173756.121159914986189798.davem@davemloft.net>
References: <1430924850-2871-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45718 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752027AbbEIVh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 17:37:58 -0400
In-Reply-To: <1430924850-2871-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 6 May 2015 18:07:29 +0300

> Handle TxFIFO underrun exceptions outside the fast path.
> A controller reset is more reliable in this exceptional
> case, as opposed to re-enabling on-the-fly the Tx DMA.
> 
> As the controller reset is handled outside the fast path
> by the reset_gfar() workqueue handler, the locking
> scheme on the Tx path is significantly simplified.
> Because the Tx processing (xmit queues and tx napi) is
> disabled during controller reset, tstat access from xmit
> does not require locking.  So the scope of the txlock on
> the processing path is now reduced to num_txbdfree, which
> is shared only between process context (xmit) and softirq
> (clean_tx_ring).  As a result, the txlock must not guard
> against interrupt context, and the spin_lock_irqsave()
> from xmit can be replaced by spin_lock_bh().  Likewise,
> the locking has been downgraded for clean_tx_ring().
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>

Applied.
