From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 3/3] netxen: fix infinite loop on dma mapping failure
Date: Thu,  3 Sep 2009 16:10:55 -0700
Message-ID: <1252019455-30683-3-git-send-email-dhananjay@netxen.com>
References: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:12130 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S932472AbZICXKz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Sep 2009 19:10:55 -0400
In-Reply-To: <1252019455-30683-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a perpetual while() loop in unwinding partial
mapped tx skb on dma mapping failure.

Reported-by: "Juha Leppanen" <juha_motorsportcom@luukku.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 53d57dc..41b2967 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1577,8 +1577,8 @@ netxen_map_tx_skb(struct pci_dev *pdev,
 	return 0;
 
 unwind:
-	while (i > 0) {
-		nf = &pbuf->frag_array[i];
+	while (--i >= 0) {
+		nf = &pbuf->frag_array[i+1];
 		pci_unmap_page(pdev, nf->dma, nf->length, PCI_DMA_TODEVICE);
 	}
 
-- 
1.6.0.2

