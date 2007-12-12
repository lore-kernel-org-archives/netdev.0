From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r6040 various cleanups
Date: Wed, 12 Dec 2007 23:35:41 +0100
Message-ID: <20071212223541.GA32305@electric-eye.fr.zoreil.com>
References: <200712121044.01820.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, Andrew Morton <akpm@linux-foundation.org>,
	Sten Wang <sten.wang@rdc.com.tw>, netdev@vger.kernel.org
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36396 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751429AbXLLWmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 17:42:39 -0500
Content-Disposition: inline
In-Reply-To: <200712121044.01820.florian.fainelli@telecomint.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli <florian.fainelli@telecomint.eu> :
[r6040 changes]
> - remove unused private structure members
> - functions to allocate/free TX and RX buffers
> - recover from transmit timeout
> - use netdev_alloc_skb instead of dev_alloc_skb
> - do not use a private stats structure to store statistics
> - break each TX/RX error to a separate line for better reading
> - better control of the timer
> - clean the IRQ handler
> - fix typos and spelling mistakes in the driver

Thanks, I have split it in parts. The serie should be available shortly at:

git://git.kernel.org/pub/scm/linux/kernel/git/romieu/netdev-2.6.git r6040

Please note that:
1. TIMER_WUT has been removed as it was not used any more
2. I have kept the difference below. Was the patch really supposed to update
   the same error counter twice ?

diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 19184e4..ff72c51 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -518,7 +519,9 @@ static int r6040_rx(struct net_device *dev, int limit)
 		if (err & 0x0020)
 			dev->stats.rx_over_errors++;
 		/* Received packet with too long or short */
-		if (err & (0x0010 | 0x0008))
+		if (err & 0x0010)
+			dev->stats.rx_length_errors++;
+		if (err & 0x0008)
 			dev->stats.rx_length_errors++;
 		/* Received packet with CRC errors */
 		if (err & 0x0004) {
@@ -579,7 +582,9 @@ static void r6040_tx(struct net_device *dev)
 
 		if (err & 0x0200)
 			dev->stats.rx_fifo_errors++;
-		if (err & (0x2000 | 0x4000))
+		if (err & 0x2000)
+			dev->stats.tx_carrier_errors++;
+		if (err & 0x4000)
 			dev->stats.tx_carrier_errors++;
 
 		if (descptr->status & 0x8000)

-- 
Ueimor
