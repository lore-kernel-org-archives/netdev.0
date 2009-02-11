From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/7] qlge: bugfix: Add missing dev_kfree_skb_any() call.
Date: Wed, 11 Feb 2009 05:58:34 -0800
Message-ID: <1234360717-32194-4-git-send-email-ron.mercer@qlogic.com>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50248 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754378AbZBKOBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 09:01:16 -0500
In-Reply-To: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We put the skb back if we can't get mapping for it.  We don't
want unmapped buffers on our receive buffer queue.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 5b75fc9..fc7d210 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -970,6 +970,8 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				if (pci_dma_mapping_error(qdev->pdev, map)) {
 					QPRINTK(qdev, IFUP, ERR, "PCI mapping failed.\n");
 					rx_ring->sbq_clean_idx = clean_idx;
+					dev_kfree_skb_any(sbq_desc->p.skb);
+					sbq_desc->p.skb = NULL;
 					return;
 				}
 				pci_unmap_addr_set(sbq_desc, mapaddr, map);
-- 
1.6.0.2

