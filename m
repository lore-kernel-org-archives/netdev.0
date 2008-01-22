From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.25 1/4][BNX2]: Disable jumbo rx paging on 5709 Ax.
Date: Mon, 21 Jan 2008 17:07:32 -0800
Message-ID: <1200964052.10010.46.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1242 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754241AbYAVAV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 19:21:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Disable jumbo rx paging on 5709 Ax.

The chip has problem running in this mode and needs to be disabled.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 94d1857..8348af2 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4669,7 +4669,7 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	bp->rx_pg_ring_size = 0;
 	bp->rx_max_pg_ring = 0;
 	bp->rx_max_pg_ring_idx = 0;
-	if (rx_space > PAGE_SIZE) {
+	if ((rx_space > PAGE_SIZE) && !(bp->flags & JUMBO_BROKEN_FLAG)) {
 		int pages = PAGE_ALIGN(bp->dev->mtu - 40) >> PAGE_SHIFT;
 
 		jumbo_size = size * pages;
@@ -7031,6 +7031,8 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 			goto err_out_unmap;
 		}
 		bp->flags |= PCIE_FLAG;
+		if (CHIP_REV(bp) == CHIP_REV_Ax)
+			bp->flags |= JUMBO_BROKEN_FLAG;
 	} else {
 		bp->pcix_cap = pci_find_capability(pdev, PCI_CAP_ID_PCIX);
 		if (bp->pcix_cap == 0) {
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 09bd665..c1ab30b 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6582,6 +6582,7 @@ struct bnx2 {
 #define PCIE_FLAG			0x00000200
 #define USING_MSIX_FLAG			0x00000400
 #define USING_MSI_OR_MSIX_FLAG		(USING_MSI_FLAG | USING_MSIX_FLAG)
+#define JUMBO_BROKEN_FLAG		0x00000800
 
 	/* Put tx producer and consumer fields in separate cache lines. */
 


