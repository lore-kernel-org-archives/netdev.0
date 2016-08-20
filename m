From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/15] i40e: refactor tail_bump check
Date: Fri, 19 Aug 2016 23:19:42 -0700
Message-ID: <1471673991-117115-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:50330 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752277AbcHTGTz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 Aug 2016 02:19:55 -0400
In-Reply-To: <1471673991-117115-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch refactors tail bump check.

Change-ID: Ide0e19171d67d90cb2b06b8dcd4fa791ae120160
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 6 ++----
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 6 ++----
 2 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index df7ecc9..f8d6623 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2840,10 +2840,9 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 						  I40E_TXD_QW1_CMD_SHIFT);
 
 	/* notify HW of packet */
-	if (!tail_bump)
+	if (!tail_bump) {
 		prefetchw(tx_desc + 1);
-
-	if (tail_bump) {
+	} else {
 		/* Force memory writes to complete before letting h/w
 		 * know there are new descriptors to fetch.  (Only
 		 * applicable for weak-ordered memory model archs,
@@ -2852,7 +2851,6 @@ static inline void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		wmb();
 		writel(i, tx_ring->tail);
 	}
-
 	return;
 
 dma_error:
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index a579193..0130458 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -2068,10 +2068,9 @@ static inline void i40evf_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 						  I40E_TXD_QW1_CMD_SHIFT);
 
 	/* notify HW of packet */
-	if (!tail_bump)
+	if (!tail_bump) {
 		prefetchw(tx_desc + 1);
-
-	if (tail_bump) {
+	} else {
 		/* Force memory writes to complete before letting h/w
 		 * know there are new descriptors to fetch.  (Only
 		 * applicable for weak-ordered memory model archs,
@@ -2080,7 +2079,6 @@ static inline void i40evf_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		wmb();
 		writel(i, tx_ring->tail);
 	}
-
 	return;
 
 dma_error:
-- 
2.7.4
