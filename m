From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 07/20] tg3: Improve 5785 PCIe performance
Date: Mon, 2 Nov 2009 16:26:03 -0800
Message-ID: <1257211996.22001@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3562 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756421AbZKCBdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Nov 2009 20:33:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch improves 5785 performance by allowing the write DMA engine to
request larger DMA burst sizes than it otherwise would.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    3 +++
 drivers/net/tg3.h |    3 ++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 54dbe98..a43ef2b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7633,6 +7633,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	if (tp->tg3_flags3 & TG3_FLG3_5755_PLUS)
 		val |= WDMAC_MODE_STATUS_TAG_FIX;
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785)
+		val |= WDMAC_MODE_BURST_ALL_DATA;
+
 	tw32_f(WDMAC_MODE, val);
 	udelay(40);
 
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 530c36b..68431da 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1264,8 +1264,9 @@
 #define  WDMAC_MODE_FIFOURUN_ENAB	 0x00000080
 #define  WDMAC_MODE_FIFOOREAD_ENAB	 0x00000100
 #define  WDMAC_MODE_LNGREAD_ENAB	 0x00000200
-#define  WDMAC_MODE_RX_ACCEL	 	 0x00000400
+#define  WDMAC_MODE_RX_ACCEL		 0x00000400
 #define  WDMAC_MODE_STATUS_TAG_FIX	 0x20000000
+#define  WDMAC_MODE_BURST_ALL_DATA	 0xc0000000
 #define WDMAC_STATUS			0x00004c04
 #define  WDMAC_STATUS_TGTABORT		 0x00000004
 #define  WDMAC_STATUS_MSTABORT		 0x00000008
-- 
1.6.4.4


