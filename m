From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [PATCH -mm] net: yellowfin parenthesis fix
Date: Thu, 20 Mar 2008 01:53:27 +0100
Message-ID: <200803200153.27730.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-2"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762387AbYCTAxx@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

	The code is under unused #ifdef NO_TXSTATS branch but its better
to have it fixed. The patch is against 2.6.25-rc5-mm1.

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

--- linux-2.6.25-rc5-mm1-a/drivers/net/yellowfin.c	2008-03-20 01:35:48.000000000 +0100
+++ linux-2.6.25-rc5-mm1-b/drivers/net/yellowfin.c	2008-03-20 01:36:46.000000000 +0100
@@ -770,14 +770,14 @@ static void yellowfin_init_ring(struct n
 		/* Branch on Tx error. */
 		yp->tx_ring[j].dbdma_cmd = cpu_to_le32(CMD_STOP);
 		yp->tx_ring[j].branch_addr = cpu_to_le32(yp->tx_ring_dma +
-			(j+1)*sizeof(struct yellowfin_desc);
+			(j+1)*sizeof(struct yellowfin_desc));
 		j++;
 		if (yp->flags & FullTxStatus) {
 			yp->tx_ring[j].dbdma_cmd =
 				cpu_to_le32(CMD_TXSTATUS | sizeof(*yp->tx_status));
 			yp->tx_ring[j].request_cnt = sizeof(*yp->tx_status);
 			yp->tx_ring[j].addr = cpu_to_le32(yp->tx_status_dma +
-				i*sizeof(struct tx_status_words);
+				i*sizeof(struct tx_status_words));
 		} else {
 			/* Symbios chips write only tx_errs word. */
 			yp->tx_ring[j].dbdma_cmd =
