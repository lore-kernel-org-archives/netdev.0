From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/cxgb3/xgmac.c: remove dead code
Date: Sun, 29 Jul 2007 16:55:45 +0200
Message-ID: <20070729145544.GA16817@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>, Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763844AbXG2O4n@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes dead code ("tx_xcnt" can never be != 0 at this place) 
spotted by the Coverity checker.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/cxgb3/xgmac.c |    5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

--- linux-2.6.22-rc6-mm1/drivers/net/cxgb3/xgmac.c.old	2007-07-24 13:55:33.000000000 +0200
+++ linux-2.6.22-rc6-mm1/drivers/net/cxgb3/xgmac.c	2007-07-24 13:57:06.000000000 +0200
@@ -510,38 +510,35 @@ int t3b2_mac_watchdog_task(struct cmac *
 	if (tx_mcnt == mac->tx_mcnt) {
 		tx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
 						A_XGM_TX_SPI4_SOP_EOP_CNT +
 					       	mac->offset)));
 		if (tx_xcnt == 0) {
 			t3_write_reg(adap, A_TP_PIO_ADDR,
 				     A_TP_TX_DROP_CNT_CH0 + macidx(mac));
 			tx_tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap,
 						      A_TP_PIO_DATA)));
 		} else {
 			goto rxcheck;
 		}
 	} else {
 		mac->toggle_cnt = 0;
 		goto rxcheck;
 	}
 
-	if (((tx_tcnt != mac->tx_tcnt) &&
-	     (tx_xcnt == 0) && (mac->tx_xcnt == 0)) ||
-	    ((mac->tx_mcnt == tx_mcnt) &&
-	     (tx_xcnt != 0) && (mac->tx_xcnt != 0))) {
+	if ((tx_tcnt != mac->tx_tcnt) && (mac->tx_xcnt == 0))  {
 		if (mac->toggle_cnt > 4) {
 			status = 2;
 			goto out;
 		} else {
 			status = 1;
 			goto out;
 		}
 	} else {
 		mac->toggle_cnt = 0;
 		goto rxcheck;
 	}
 
 rxcheck:
 	if (rx_mcnt != mac->rx_mcnt)
 		rx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
 						A_XGM_RX_SPI4_SOP_EOP_CNT +
 						mac->offset)));
