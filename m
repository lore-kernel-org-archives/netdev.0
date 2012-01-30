From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [18/22] Cyclades PC300 driver: adjust SCA-II DMA buffer parameters
Date: Sun, 29 Jan 2012 18:57:52 -0800
Message-ID: <20120130025752.GS10262@cronus.persephoneslair.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khc@pm.waw.pl, davem@davemloft.net, mmarek@suse.cz,
	jkosina@suse.cz, joe@perches.com, justinmattock@gmail.com,
	gregkh@suse.de, alan@linux.intel.com, jdmason@kudzu.us
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DMA buffer interrupt trigger levels in the original driver do not seem
suitable and lead to poor performance (around 30 kilobytes/sec on a full T1,
in my test).  These new values seem to be optimal.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 4d81507..6cecef5 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -3486,7 +3486,8 @@ static int rx_config(pc300dev_t *d)
 
 	/* General RX settings */
 	cpc_writeb(scabase + M_REG(RRC, ch), 0);
-	cpc_writeb(scabase + M_REG(RNR, ch), 16);
+	cpc_writeb(scabase + M_REG(RNR, ch), 8);
+	cpc_writeb(scabase + M_REG(RCR, ch), 16);
 
 	/* Enable reception */
 	cpc_writeb(scabase + M_REG(CMD, ch), CMD_RX_CRC_INIT);
@@ -3517,10 +3518,10 @@ static int tx_config(pc300dev_t *d)
 
 	/* General TX settings */
 	cpc_writeb(scabase + M_REG(TRC0, ch), 0);
-	cpc_writeb(scabase + M_REG(TFS, ch), 32);
-	cpc_writeb(scabase + M_REG(TNR0, ch), 20);
-	cpc_writeb(scabase + M_REG(TNR1, ch), 48);
-	cpc_writeb(scabase + M_REG(TCR, ch), 8);
+	cpc_writeb(scabase + M_REG(TFS, ch), 0x3c);
+	cpc_writeb(scabase + M_REG(TNR0, ch), 0x38);
+	cpc_writeb(scabase + M_REG(TNR1, ch), 0x3f);
+	cpc_writeb(scabase + M_REG(TCR, ch), 0x38);
 
 	/* Enable transmission */
 	cpc_writeb(scabase + M_REG(CMD, ch), CMD_TX_CRC_INIT);
