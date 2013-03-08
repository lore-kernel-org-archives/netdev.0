From: <daveo@ll.mit.edu>
Subject: [PATCH] rrunner.c: fix possible memory leak in rr_init_one()
Date: Fri, 8 Mar 2013 13:28:15 -0500
Message-ID: <1362767295-16334-1-git-send-email-daveo@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jes@trained-monkey.org>, David Oostdyk <daveo@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:49732 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759867Ab3CHS23 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 13:28:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Oostdyk <daveo@ll.mit.edu>

In the event that register_netdev() failed, the rrpriv->evt_ring
allocation would have not been freed.

Signed-off-by: David Oostdyk <daveo@ll.mit.edu>
---
 drivers/net/hippi/rrunner.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/hippi/rrunner.c b/drivers/net/hippi/rrunner.c
index d471963..970595a 100644
--- a/drivers/net/hippi/rrunner.c
+++ b/drivers/net/hippi/rrunner.c
@@ -203,6 +203,9 @@ static int __devinit rr_init_one(struct pci_dev *pdev,
 	return 0;
 
  out:
+	if (rrpriv->evt_ring)
+		pci_free_consistent(pdev, EVT_RING_SIZE, rrpriv->evt_ring,
+				    rrpriv->evt_ring_dma);
 	if (rrpriv->rx_ring)
 		pci_free_consistent(pdev, RX_TOTAL_SIZE, rrpriv->rx_ring,
 				    rrpriv->rx_ring_dma);
-- 
1.8.1.5
