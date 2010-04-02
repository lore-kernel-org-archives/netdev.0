From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH 1/2] benet: use the dma state API instead of the pci equivalents
Date: Fri,  2 Apr 2010 11:53:22 +0900
Message-ID: <1270176803-8561-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: sarveshwarb@serverengines.com, ajitk@serverengines.com,
	netdev@vger.kernel.org, fujita.tomonori@lab.ntt.co.jp
To: sathyap@serverengines.com, subbus@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:48540 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759160Ab0DBC5D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Apr 2010 22:57:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DMA API is preferred.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/benet/be.h      |    2 +-
 drivers/net/benet/be_main.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 8f07525..bddae08 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -206,7 +206,7 @@ struct be_tx_obj {
 /* Struct to remember the pages posted for rx frags */
 struct be_rx_page_info {
 	struct page *page;
-	dma_addr_t bus;
+	DEFINE_DMA_UNMAP_ADDR(bus);
 	u16 page_offset;
 	bool last_page_user;
 };
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 17282df..8d5e27b 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -682,7 +682,7 @@ get_rx_page_info(struct be_adapter *adapter, u16 frag_idx)
 	BUG_ON(!rx_page_info->page);
 
 	if (rx_page_info->last_page_user) {
-		pci_unmap_page(adapter->pdev, pci_unmap_addr(rx_page_info, bus),
+		pci_unmap_page(adapter->pdev, dma_unmap_addr(rx_page_info, bus),
 			adapter->big_page_size, PCI_DMA_FROMDEVICE);
 		rx_page_info->last_page_user = false;
 	}
@@ -993,7 +993,7 @@ static void be_post_rx_frags(struct be_adapter *adapter)
 		}
 		page_offset = page_info->page_offset;
 		page_info->page = pagep;
-		pci_unmap_addr_set(page_info, bus, page_dmaaddr);
+		dma_unmap_addr_set(page_info, bus, page_dmaaddr);
 		frag_dmaaddr = page_dmaaddr + page_info->page_offset;
 
 		rxd = queue_head_node(rxq);
-- 
1.7.0

