From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] cxgb4vf: remove obsolete DECLARE_PCI_UNMAP_ADDR usage
Date: Thu, 8 Jul 2010 18:52:37 +0900
Message-ID: <20100708185111D.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:34212 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754512Ab0GHJwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jul 2010 05:52:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We could use DEFINE_DMA_UNMAP_ADDR instead but using
CONFIG_NEED_DMA_MAP_STATE is a simpler way to see if a platform does
real DMA unmapping.

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
---
 drivers/net/cxgb4vf/sge.c |   14 +++++---------
 1 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index 3a7c02f..4bc1858 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -228,15 +228,11 @@ static inline bool is_buf_mapped(const struct rx_sw_desc *sdesc)
  */
 static inline int need_skb_unmap(void)
 {
-	/*
-	 * This structure is used to tell if the platfrom needs buffer
-	 * unmapping by checking if DECLARE_PCI_UNMAP_ADDR defines anything.
-	 */
-	struct dummy {
-		DECLARE_PCI_UNMAP_ADDR(addr);
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

