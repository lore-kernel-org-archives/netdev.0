From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 5/9] tg3: Turn off multiple DMA reads for 5717
Date: Fri, 12 Feb 2010 16:47:09 -0800
Message-ID: <1266022033-3546-6-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2535 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756654Ab0BMArd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 19:47:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5717's DMA read engine has a bug when initiating multiple DMA reads
across the PCIe bus.  This patch disables the feature.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Reviewed-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/tg3.c |    3 +++
 drivers/net/tg3.h |    1 +
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d1452d3..1c545a8 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7915,6 +7915,9 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		      RDMAC_MODE_FIFOURUN_ENAB | RDMAC_MODE_FIFOOREAD_ENAB |
 		      RDMAC_MODE_LNGREAD_ENAB);
 
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717)
+		rdmac_mode |= RDMAC_MODE_MULT_DMA_RD_DIS;
+
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5784 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5785 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57780)
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 46db4ad..a8fb53a 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1258,6 +1258,7 @@
 #define  RDMAC_MODE_MBUF_SBD_CRPT_ENAB	 0x00002000
 #define  RDMAC_MODE_FIFO_SIZE_128	 0x00020000
 #define  RDMAC_MODE_FIFO_LONG_BURST	 0x00030000
+#define  RDMAC_MODE_MULT_DMA_RD_DIS	 0x01000000
 #define  RDMAC_MODE_IPV4_LSO_EN		 0x08000000
 #define  RDMAC_MODE_IPV6_LSO_EN		 0x10000000
 #define RDMAC_STATUS			0x00004804
-- 
1.6.4.4


