From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/3] myri10ge: make wc_fifo usage load-time tunable
Date: Tue, 09 Jan 2007 21:04:25 +0100
Message-ID: <45A3F549.4070404@myri.com>
References: <45A3F4FF.5000803@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-64-172-73-26.dsl.lsan03.pacbell.net ([64.172.73.26]:1798
	"EHLO myri.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932421AbXAIUa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 15:30:27 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45A3F4FF.5000803@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Under some circumstances, using WC without the WC fifo is faster.
So we make it possible to tune wc_fifo with a module parameter.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-01-07 16:57:45.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-01-09 19:30:43.000000000 +0100
@@ -274,6 +274,10 @@
 module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
 
+static int myri10ge_wcfifo = 1;
+module_param(myri10ge_wcfifo, int, S_IRUGO);
+MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled\n");
+
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \
 (sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
@@ -1714,7 +1718,7 @@
 		goto abort_with_irq;
 	}
 
-	if (mgp->mtrr >= 0) {
+	if (myri10ge_wcfifo && mgp->mtrr >= 0) {
 		mgp->tx.wc_fifo = (u8 __iomem *) mgp->sram + MXGEFW_ETH_SEND_4;
 		mgp->rx_small.wc_fifo =
 		    (u8 __iomem *) mgp->sram + MXGEFW_ETH_RECV_SMALL;


