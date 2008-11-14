From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000e: enable ECC correction on 82571 silicon
Date: Fri, 14 Nov 2008 08:54:36 -0800
Message-ID: <20081114165436.5396.40453.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.westchester.pa.mail.comcast.net ([76.96.62.24]:40864
	"EHLO QMTA02.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750918AbYKNQzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 11:55:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change enables ECC correction for the packet buffer on all 82571
silicon.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/82571.c   |    6 ++++++
 drivers/net/e1000e/defines.h |    7 +++++++
 drivers/net/e1000e/hw.h      |    1 +
 3 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/82571.c b/drivers/net/e1000e/82571.c
index b2c910c..3027ad5 100644
--- a/drivers/net/e1000e/82571.c
+++ b/drivers/net/e1000e/82571.c
@@ -973,6 +973,12 @@ static void e1000_initialize_hw_bits_82571(struct e1000_hw *hw)
 		ew32(CTRL_EXT, reg);
 	}
 
+	if (hw->mac.type == e1000_82571) {
+		reg = er32(PBA_ECC);
+		reg |= E1000_PBA_ECC_CORR_EN;
+		ew32(PBA_ECC, reg);
+	}
+
 	/* PCI-Ex Control Register */
 	if (hw->mac.type == e1000_82574) {
 		reg = er32(GCR);
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index 48f79ec..34a68fc 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -372,6 +372,13 @@
 #define E1000_ICR_TXQ1          0x00800000 /* Tx Queue 1 Interrupt */
 #define E1000_ICR_OTHER         0x01000000 /* Other Interrupts */
 
+/* PBA ECC Register */
+#define E1000_PBA_ECC_COUNTER_MASK  0xFFF00000 /* ECC counter mask */
+#define E1000_PBA_ECC_COUNTER_SHIFT 20         /* ECC counter shift value */
+#define E1000_PBA_ECC_CORR_EN       0x00000001 /* ECC correction enable */
+#define E1000_PBA_ECC_STAT_CLR      0x00000002 /* Clear ECC error counter */
+#define E1000_PBA_ECC_INT_EN        0x00000004 /* Enable ICR bit 5 for ECC */
+
 /*
  * This defines the bits that are set in the Interrupt Mask
  * Set/Read Register.  Each bit is documented below:
diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index f66ed37..c4ffd4b 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -87,6 +87,7 @@ enum e1e_registers {
 	E1000_EEMNGCTL = 0x01010, /* MNG EEprom Control */
 	E1000_EEWR     = 0x0102C, /* EEPROM Write Register - RW */
 	E1000_FLOP     = 0x0103C, /* FLASH Opcode Register */
+	E1000_PBA_ECC  = 0x01100, /* PBA ECC Register */
 	E1000_ERT      = 0x02008, /* Early Rx Threshold - RW */
 	E1000_FCRTL    = 0x02160, /* Flow Control Receive Threshold Low - RW */
 	E1000_FCRTH    = 0x02168, /* Flow Control Receive Threshold High - RW */

