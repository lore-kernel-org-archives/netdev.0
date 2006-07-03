From: Brice Goglin <brice@myri.com>
Subject: [patch 4/4] myri10ge - Export more parameters to ethtool
Date: Mon, 03 Jul 2006 18:16:46 -0400
Message-ID: <44A9974E.8010308@myri.com>
References: <20060703220230.606593000@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:29368 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932149AbWGCWQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2006 18:16:50 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060703220230.606593000@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the IRQ line, the tx_boundary, and whether Write-combining and MSI
are enabled to the list of parameters that are exported to ethtool.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:04:47.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-07-03 16:39:29.000000000 -0400
@@ -1288,6 +1288,7 @@
 	"tx_aborted_errors", "tx_carrier_errors", "tx_fifo_errors",
 	"tx_heartbeat_errors", "tx_window_errors",
 	/* device-specific stats */
+	"tx_boundary", "WC", "irq", "MSI",
 	"read_dma_bw_MBs", "write_dma_bw_MBs", "read_write_dma_bw_MBs",
 	"serial_number", "tx_pkt_start", "tx_pkt_done",
 	"tx_req", "tx_done", "rx_small_cnt", "rx_big_cnt",
@@ -1326,6 +1327,10 @@
 	for (i = 0; i < MYRI10GE_NET_STATS_LEN; i++)
 		data[i] = ((unsigned long *)&mgp->stats)[i];
 
+	data[i++] = (unsigned int)mgp->tx.boundary;
+	data[i++] = (unsigned int)(mgp->mtrr >= 0);
+	data[i++] = (unsigned int)mgp->pdev->irq;
+	data[i++] = (unsigned int)mgp->msi_enabled;
 	data[i++] = (unsigned int)mgp->read_dma;
 	data[i++] = (unsigned int)mgp->write_dma;
 	data[i++] = (unsigned int)mgp->read_write_dma;


