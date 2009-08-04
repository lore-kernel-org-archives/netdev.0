From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH] netxen: fix dma mask update calculation
Date: Tue,  4 Aug 2009 13:39:03 -0700
Message-ID: <1249418343-15741-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:16116 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S1753255AbZHDUsl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2009 16:48:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix dma mask calculation that caps at 63-bit addressing even
when firmware advertises full 64-bit support.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 3cd8cfc..70c05c4 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -260,7 +260,7 @@ nx_update_dma_mask(struct netxen_adapter *adapter)
 	change = 0;
 
 	shift = NXRD32(adapter, CRB_DMA_SHIFT);
-	if (shift >= 32)
+	if (shift > 32)
 		return 0;
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id) && (shift > 9))
@@ -272,7 +272,7 @@ nx_update_dma_mask(struct netxen_adapter *adapter)
 		old_mask = pdev->dma_mask;
 		old_cmask = pdev->dev.coherent_dma_mask;
 
-		mask = (1ULL<<(32+shift)) - 1;
+		mask = DMA_BIT_MASK(32+shift);
 
 		err = pci_set_dma_mask(pdev, mask);
 		if (err)
-- 
1.6.0.2

