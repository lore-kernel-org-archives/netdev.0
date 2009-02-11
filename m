From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 3/7] qlge: bugfix: Add missing put_page() call.
Date: Wed, 11 Feb 2009 05:58:33 -0800
Message-ID: <1234360717-32194-3-git-send-email-ron.mercer@qlogic.com>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50248 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbZBKOBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 09:01:15 -0500
In-Reply-To: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We put the page back if we can't get mapping for it.  We don't
want unmapped buffers on our receive buffer queue.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 69f7d05..5b75fc9 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -907,6 +907,8 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 						   0, PAGE_SIZE,
 						   PCI_DMA_FROMDEVICE);
 				if (pci_dma_mapping_error(qdev->pdev, map)) {
+					put_page(lbq_desc->p.lbq_page);
+					lbq_desc->p.lbq_page = NULL;
 					QPRINTK(qdev, RX_STATUS, ERR,
 						"PCI mapping failed.\n");
 					return;
-- 
1.6.0.2

