From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH 3/3] [IrDA] stir4200: removing undocumented bits handling
Date: Wed, 20 Sep 2006 08:09:24 +0300
Message-ID: <20060920050923.GE4140@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	andrzej zaborowski <balrogg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3.pp.htv.fi ([213.243.153.36]:13266 "EHLO smtp3.pp.htv.fi")
	by vger.kernel.org with ESMTP id S1751083AbWISVyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 17:54:52 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

FIFOCTL_RXERR and FIFOCTL_TXERR are undocumented bits, according to the
Sigmatel datasheet. We should thus not take any assumption on their values
and semantics.

Problem spotted by andrzej zaborowski <balrogg@gmail.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

---
 drivers/net/irda/stir4200.c |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)

diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index d61b208..12103c9 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -149,8 +149,6 @@ enum StirFifoCtlMask {
 	FIFOCTL_DIR = 0x10,
 	FIFOCTL_CLR = 0x08,
 	FIFOCTL_EMPTY = 0x04,
-	FIFOCTL_RXERR = 0x02,
-	FIFOCTL_TXERR = 0x01,
 };
 
 enum StirDiagMask {
@@ -615,19 +613,6 @@ static int fifo_txwait(struct stir_cb *s
 
 		pr_debug("fifo status 0x%lx count %lu\n", status, count);
 
-		/* error when receive/transmit fifo gets confused */
-		if (status & FIFOCTL_RXERR) {
-			stir->stats.rx_fifo_errors++;
-			stir->stats.rx_errors++;
-			break;
-		}
-
-		if (status & FIFOCTL_TXERR) {
-			stir->stats.tx_fifo_errors++;
-			stir->stats.tx_errors++;
-			break;
-		}
-
 		/* is fifo receiving already, or empty */
 		if (!(status & FIFOCTL_DIR)
 		    || (status & FIFOCTL_EMPTY))
-- 
1.4.1.1

