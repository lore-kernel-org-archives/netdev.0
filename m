From: <Frank.Li@freescale.com>
Subject: [Patch net-next 1/1] net: fec: fix build error at m68k platform
Date: Wed, 17 Sep 2014 02:34:18 +0800
Message-ID: <1410892458-2113-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0112.outbound.protection.outlook.com ([207.46.100.112]:1920
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754881AbaIPTiV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 15:38:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>

reproduce:
  wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
  chmod +x ~/bin/make.cross
  git checkout 4d494cdc92b3b9a0f5fb9e1560810fa27d5a0489
  make.cross ARCH=m68k  m5272c3_defconfig
  make.cross ARCH=m68k

drivers/net/ethernet/freescale/fec.h:262:0: warning: "FEC_R_DES_START" redefined
 #define FEC_R_DES_START(X) ((X == 1) ? FEC_R_DES_START_1 : \
 ^
drivers/net/ethernet/freescale/fec.h:158:0: note: this is the location of the previous definition
 #define FEC_R_DES_START  0x3d0 /* Receive descriptor ring */
 ^
drivers/net/ethernet/freescale/fec.h:265:0: warning: "FEC_X_DES_START" redefined
 #define FEC_X_DES_START(X) ((X == 1) ? FEC_X_DES_START_1 : \

...

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 This patch based on previous interrupt coalescence patches

 drivers/net/ethernet/freescale/fec.h | 30 +++++++++++++++++++++++++-----
 1 file changed, 25 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.h b/drivers/net/ethernet/freescale/fec.h
index 2814610..de86d61 100644
--- a/drivers/net/ethernet/freescale/fec.h
+++ b/drivers/net/ethernet/freescale/fec.h
@@ -140,8 +140,12 @@
 #define FEC_IEVENT		0x004 /* Interrupt even reg */
 #define FEC_IMASK		0x008 /* Interrupt mask reg */
 #define FEC_IVEC		0x00c /* Interrupt vec status reg */
-#define FEC_R_DES_ACTIVE	0x010 /* Receive descriptor reg */
-#define FEC_X_DES_ACTIVE	0x014 /* Transmit descriptor reg */
+#define FEC_R_DES_ACTIVE_0	0x010 /* Receive descriptor reg */
+#define FEC_R_DES_ACTIVE_1	FEC_R_DES_ACTIVE_0
+#define FEC_R_DES_ACTIVE_2	FEC_R_DES_ACTIVE_0
+#define FEC_X_DES_ACTIVE_0	0x014 /* Transmit descriptor reg */
+#define FEC_X_DES_ACTIVE_1	FEC_X_DES_ACTIVE_0
+#define FEC_X_DES_ACTIVE_2	FEC_X_DES_ACTIVE_0
 #define FEC_MII_DATA		0x040 /* MII manage frame reg */
 #define FEC_MII_SPEED		0x044 /* MII speed control reg */
 #define FEC_R_BOUND		0x08c /* FIFO receive bound reg */
@@ -155,11 +159,27 @@
 #define FEC_ADDR_HIGH		0x3c4 /* High 16bits MAC address */
 #define FEC_GRP_HASH_TABLE_HIGH	0x3c8 /* High 32bits hash table */
 #define FEC_GRP_HASH_TABLE_LOW	0x3cc /* Low 32bits hash table */
-#define FEC_R_DES_START		0x3d0 /* Receive descriptor ring */
-#define FEC_X_DES_START		0x3d4 /* Transmit descriptor ring */
+#define FEC_R_DES_START_0	0x3d0 /* Receive descriptor ring */
+#define FEC_R_DES_START_1	FEC_R_DES_START_0
+#define FEC_R_DES_START_2	FEC_R_DES_START_0
+#define FEC_X_DES_START_0	0x3d4 /* Transmit descriptor ring */
+#define FEC_X_DES_START_1	FEC_X_DES_START_0
+#define FEC_X_DES_START_2	FEC_X_DES_START_0
 #define FEC_R_BUFF_SIZE		0x3d8 /* Maximum receive buff size */
 #define FEC_FIFO_RAM		0x400 /* FIFO RAM buffer */
-
+/* Not existed in real chip
+ * Just for pass build.
+ */
+#define FEC_RCMR_1		0xFFF
+#define FEC_RCMR_2		0xFFF
+#define FEC_DMA_CFG_1		0xFFF
+#define FEC_DMA_CFG_2		0xFFF
+#define FEC_TXIC0		0xFFF
+#define FEC_TXIC1		0xFFF
+#define FEC_TXIC2		0xFFF
+#define FEC_RXIC0		0xFFF
+#define FEC_RXIC1		0xFFF
+#define FEC_RXIC2		0xFFF
 #endif /* CONFIG_M5272 */
 
 
-- 
1.9.1
