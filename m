From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] net: mvpp2: do not call txq_done from the Tx
 path when Tx irqs are used
Date: Tue, 24 Oct 2017 18:34:58 +0900 (KST)
Message-ID: <20171024.183458.1613489746739108710.davem@davemloft.net>
References: <20171023132431.5756-1-antoine.tenart@free-electrons.com>
        <20171023132431.5756-3-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: antoine.tenart@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58214 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932297AbdJXJfD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:35:03 -0400
In-Reply-To: <20171023132431.5756-3-antoine.tenart@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antoine Tenart <antoine.tenart@free-electrons.com>
Date: Mon, 23 Oct 2017 15:24:31 +0200

> When Tx IRQs are used, txq_bufs_free() can be called from both the Tx
> path and from NAPI poll(). This led to CPU stalls as if these two tasks
> (Tx and Poll) are scheduled on two CPUs at the same time, DMA unmapping
> operations are done on the same txq buffers.
> 
> This patch adds a check not to call txq_done() from the Tx path if Tx
> interrupts are used as it does not make sense to do so.
> 
> Fixes: edc660fa09e2 ("net: mvpp2: replace TX coalescing interrupts with hrtimer")
> Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>

Applied.
