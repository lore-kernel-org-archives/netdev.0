From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] cxgb3: simplify need_skb_unmap
Date: Thu, 8 Jul 2010 18:52:38 +0900
Message-ID: <20100708185209E.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:34211 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752832Ab0GHJwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jul 2010 05:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use CONFIG_NEED_DMA_MAP_STATE to see if a platform does real
DMA unmapping.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/cxgb3/sge.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 5962b91..8ff96c6 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -203,15 +203,11 @@ static inline void refill_rspq(struct adapter *adapter,
  */
 static inline int need_skb_unmap(void)
 {
-	/*
-	 * This structure is used to tell if the platform needs buffer
-	 * unmapping by checking if DECLARE_PCI_UNMAP_ADDR defines anything.
-	 */
-	struct dummy {
-		DEFINE_DMA_UNMAP_ADDR(addr);
-	};
-
-	return sizeof(struct dummy) != 0;
+#ifdef CONFIG_NEED_DMA_MAP_STATE
+	return 1;
+#else
+	return 0;
+#endif
 }
 
 /**
-- 
1.6.5

