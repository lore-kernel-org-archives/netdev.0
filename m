From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 1/5] qlge: bugfix: Add missing pci_mapping_err checking.
Date: Tue, 30 Dec 2008 13:12:21 -0800
Message-ID: <1230671545-19084-1-git-send-email-ron.mercer@qlogic.com>
References: <20081230211122.GD16018@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, bhutchings@solarflare.com, hch@infradead.org
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:38470 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200AbYL3VMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 16:12:24 -0500
In-Reply-To: <20081230211122.GD16018@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 718a7bd..c6ab6a4 100644
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

