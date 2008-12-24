From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/5] qlge: bugfux: Add missing pci_mapping_err checking.
Date: Wed, 24 Dec 2008 10:21:32 -0800
Message-ID: <1230142896-15533-1-git-send-email-ron.mercer@qlogic.com>
References: <20081224181834.GA15470@susedev.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:27618 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067AbYLXSVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 13:21:35 -0500
In-Reply-To: <20081224181834.GA15470@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)
 mode change 100644 => 100755 drivers/net/qlge/qlge_main.c

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
old mode 100644
new mode 100755
index 0214708..56c7531
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -963,6 +963,11 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 						     sbq_desc->p.skb->data,
 						     rx_ring->sbq_buf_size /
 						     2, PCI_DMA_FROMDEVICE);
+				if (pci_dma_mapping_error(qdev->pdev, map)) {
+					QPRINTK(qdev, IFUP, ERR, "PCI mapping failed.\n");
+					rx_ring->sbq_clean_idx = clean_idx;
+					return;
+				}
 				pci_unmap_addr_set(sbq_desc, mapaddr, map);
 				pci_unmap_len_set(sbq_desc, maplen,
 						  rx_ring->sbq_buf_size / 2);
-- 
1.6.0

