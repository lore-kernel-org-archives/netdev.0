From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net 2/5] stmmac: Add defines and documentation for enabling flow control
Date: Wed, 15 Apr 2015 11:17:39 -0500
Message-ID: <1429114662-1528-3-git-send-email-vbridger@opensource.altera.com>
References: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@opensource.altera.com>, <vbridger@altera.com>
To: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0096.outbound.protection.outlook.com ([207.46.100.96]:60919
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754958AbbDOU4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 16:56:25 -0400
In-Reply-To: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add defines and documentation for enabling flow control on the stmmac. Flow
control was not implemented correctly on the stmmac driver and is currently
non-functional as a result. This is the first in a series of small patches
to correctly implement this feature.

Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac1000.h | 51 +++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
index 64d8f56..b3fe057 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac1000.h
@@ -172,6 +172,7 @@ enum inter_frame_gap {
 /* GMAC FLOW CTRL defines */
 #define GMAC_FLOW_CTRL_PT_MASK	0xffff0000	/* Pause Time Mask */
 #define GMAC_FLOW_CTRL_PT_SHIFT	16
+#define GMAC_FLOW_CTRL_UP	0x00000008	/* Unicast pause frame enable */
 #define GMAC_FLOW_CTRL_RFE	0x00000004	/* Rx Flow Control Enable */
 #define GMAC_FLOW_CTRL_TFE	0x00000002	/* Tx Flow Control Enable */
 #define GMAC_FLOW_CTRL_FCB_BPA	0x00000001	/* Flow Control Busy ... */
@@ -246,6 +247,56 @@ enum ttc_control {
 #define DMA_CONTROL_FEF		0x00000080
 #define DMA_CONTROL_FUF		0x00000040
 
+/* Receive flow control activation field
+ * RFA field in DMA control register, bits 23,10:9
+ */
+#define DMA_CONTROL_RFA_MASK	0x00800600
+
+/* Receive flow control deactivation field
+ * RFD field in DMA control register, bits 22,12:11
+ */
+#define DMA_CONTROL_RFD_MASK	0x00401800
+
+/* RFD and RFA fields are encoded as follows
+ *
+ *   Bit Field
+ *   0,00 - Full minus 1KB (only valid when rxfifo >= 4KB and EFC enabled)
+ *   0,01 - Full minus 2KB (only valid when rxfifo >= 4KB and EFC enabled)
+ *   0,10 - Full minus 3KB (only valid when rxfifo >= 4KB and EFC enabled)
+ *   0,11 - Full minus 4KB (only valid when rxfifo > 4KB and EFC enabled)
+ *   1,00 - Full minus 5KB (only valid when rxfifo > 8KB and EFC enabled)
+ *   1,01 - Full minus 6KB (only valid when rxfifo > 8KB and EFC enabled)
+ *   1,10 - Full minus 7KB (only valid when rxfifo > 8KB and EFC enabled)
+ *   1,11 - Reserved
+ *
+ * RFD should always be > RFA for a given FIFO size. RFD == RFA may work,
+ * but packet throughput performance may not be as expected.
+ *
+ * Be sure that bit 3 in GMAC Register 6 is set for Unicast Pause frame
+ * detection (IEEE Specification Requirement, Annex 31B, 31B.1, Pause
+ * Description).
+ *
+ * Be sure that DZPA (bit 7 in Flow Control Register, GMAC Register 6),
+ * is set to 0. This allows pause frames with a quanta of 0 to be sent
+ * as an XOFF message to the link peer.
+ */
+
+#define RFA_FULL_MINUS_1K	0x00000000
+#define RFA_FULL_MINUS_2K	0x00000200
+#define RFA_FULL_MINUS_3K	0x00000400
+#define RFA_FULL_MINUS_4K	0x00000600
+#define RFA_FULL_MINUS_5K	0x00800000
+#define RFA_FULL_MINUS_6K	0x00800200
+#define RFA_FULL_MINUS_7K	0x00800400
+
+#define RFD_FULL_MINUS_1K	0x00000000
+#define RFD_FULL_MINUS_2K	0x00000800
+#define RFD_FULL_MINUS_3K	0x00001000
+#define RFD_FULL_MINUS_4K	0x00001800
+#define RFD_FULL_MINUS_5K	0x00400000
+#define RFD_FULL_MINUS_6K	0x00400800
+#define RFD_FULL_MINUS_7K	0x00401000
+
 enum rtc_control {
 	DMA_CONTROL_RTC_64 = 0x00000000,
 	DMA_CONTROL_RTC_32 = 0x00000008,
-- 
1.9.1
