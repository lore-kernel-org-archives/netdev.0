From: Andrea Shepard <andrea@persephoneslair.org>
Subject: [13/22] Cyclades PC300 driver: alignment fix for portability
Date: Sun, 29 Jan 2012 18:54:31 -0800
Message-ID: <20120130025431.GN10262@cronus.persephoneslair.org>
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

This fixes an unaligned memory access to one of the device registers which was
causing a kernel panic on sparc64.

Signed-off-by: Andrea Shepard <andrea@persephoneslair.org>

diff --git a/drivers/net/wan/pc300_drv.c b/drivers/net/wan/pc300_drv.c
index 14500eb..8249038 100644
--- a/drivers/net/wan/pc300_drv.c
+++ b/drivers/net/wan/pc300_drv.c
@@ -3277,8 +3277,10 @@ static int ch_config(pc300dev_t * d)
 		   IR0_DTX(IR0_EFT | IR0_DMIA | IR0_DMIB, ch));
 	cpc_writeb(scabase + M_REG(IE0, ch),
 		   cpc_readl(scabase + M_REG(IE0, ch)) | IE0_RXINTA);
+
+	/* Was cpc_readl(), changed for unaligned access */
 	cpc_writeb(scabase + M_REG(IE1, ch),
-		   cpc_readl(scabase + M_REG(IE1, ch)) | IE1_CDCD);
+		   cpc_readb(scabase + M_REG(IE1, ch)) | IE1_CDCD);
 
 	return 0;
 }
