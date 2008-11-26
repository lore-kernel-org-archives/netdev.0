From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2/4 2.6.29] cxgb3 - avoid potential memory leak.
Date: Wed, 26 Nov 2008 12:38:20 -0800
Message-ID: <20081126203820.4819.17969.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:10952 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752538AbYKZUiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 15:38:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Add consistency in alloc_ring() parameter checking
to avoid potential memory leaks.
alloc_ring() callers are correct fo far.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 268f158..bc6a8dc 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -549,16 +549,15 @@ static void *alloc_ring(struct pci_dev *pdev, size_t nelem, size_t elem_size,
 
 	if (!p)
 		return NULL;
-	if (sw_size) {
+	if (sw_size && metadata) {
 		s = kcalloc(nelem, sw_size, GFP_KERNEL);
 
 		if (!s) {
 			dma_free_coherent(&pdev->dev, len, p, *phys);
 			return NULL;
 		}
-	}
-	if (metadata)
 		*(void **)metadata = s;
+	}
 	memset(p, 0, len);
 	return p;
 }

