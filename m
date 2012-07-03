From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/7] qlge: Fixed packet transmit errors due to
 potential driver errors.
Date: Tue, 03 Jul 2012 16:14:24 -0700 (PDT)
Message-ID: <20120703.161424.1399041252994063483.davem@davemloft.net>
References: <20120702.183826.1521103644475572622.davem@davemloft.net>
	<20120702.184134.1131493483786674336.davem@davemloft.net>
	<5E4F49720D0BAD499EE1F01232234BA877435B2797@AVEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com
To: jitendra.kalsaria@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536Ab2GCXO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 19:14:26 -0400
In-Reply-To: <5E4F49720D0BAD499EE1F01232234BA877435B2797@AVEXMB1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Date: Tue, 3 Jul 2012 12:38:04 -0700

> This patch was intended to remove the line that increments the
> tx_error statistic when the queue is correctly stopped.

It isn't correctly stopped, for the millionth time this condition is a
BUG, there is a kernel log message there because it is a BUG, are you
blind?
	if (unlikely(atomic_read(&tx_ring->tx_count) < 2)) {
		netif_info(qdev, tx_queued, qdev->ndev,
			   "%s: shutting down tx queue %d du to lack of resources.\n",
			   __func__, tx_ring_idx);
		netif_stop_subqueue(ndev, tx_ring->wq_id);
		atomic_inc(&tx_ring->queue_stopped);
		tx_ring->tx_errors++;
		return NETDEV_TX_BUSY;
	}

THIS CODE BLOCK SHOULD NEVER EXECUTE.  It's a driver bug, it should
never happen.

Even if the driver recovers correctly, it's still an error condition.

It's a bug, and bumping the statistic is not wrong at all.  You should
find out why this happens, because it's a bug, and it should be fixed.
