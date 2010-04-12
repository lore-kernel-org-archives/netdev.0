From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 2/8] tg3: Set card 57765 card reader MRRS to
 1024B
Date: Mon, 12 Apr 2010 09:58:25 -0700
Message-ID: <1271091511-11173-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4920 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752896Ab0DLQ6u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 12:58:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch sets the Maximum Read Request Size for the card reader
function to 1024 bytes to prevent an SD controller lockup.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    2 ++
 drivers/net/tg3.h |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4ae01b3..a0ab89e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -7704,6 +7704,8 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_57765) {
 		val = tr32(TG3PCI_DMA_RW_CTRL) &
 		      ~DMA_RWCTRL_DIS_CACHE_ALIGNMENT;
+		if (tp->pci_chip_rev_id == CHIPREV_ID_57765_A0)
+			val &= ~DMA_RWCTRL_CRDRDR_RDMA_MRRS_MSK;
 		tw32(TG3PCI_DMA_RW_CTRL, val | tp->dma_rwctrl);
 	} else if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5784 &&
 		   GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5761) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 8a6012a..9e7fe0e 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -183,6 +183,7 @@
 #define   METAL_REV_B2			 0x02
 #define TG3PCI_DMA_RW_CTRL		0x0000006c
 #define  DMA_RWCTRL_DIS_CACHE_ALIGNMENT  0x00000001
+#define  DMA_RWCTRL_CRDRDR_RDMA_MRRS_MSK 0x00000380
 #define  DMA_RWCTRL_READ_BNDRY_MASK	 0x00000700
 #define  DMA_RWCTRL_READ_BNDRY_DISAB	 0x00000000
 #define  DMA_RWCTRL_READ_BNDRY_16	 0x00000100
-- 
1.6.4.4


