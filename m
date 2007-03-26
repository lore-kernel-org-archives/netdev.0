From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/7] qla3xxx: bugfix: Multi segment sends were getting whacked.
Date: Mon, 26 Mar 2007 12:43:48 -0700
Message-ID: <11749382332973-git-send-email-ron.mercer@qlogic.com>
References: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:59437 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753741AbXCZTn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 15:43:57 -0400
In-Reply-To: <20070326164650.GA3822@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The proper header length was not being used.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index f645a0d..85850d1 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -2217,12 +2217,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 	int seg_cnt, seg = 0;
 	int frag_cnt = (int)skb_shinfo(skb)->nr_frags;
 
-	seg_cnt = tx_cb->seg_count = ql_get_seg_count(qdev,
-						      (skb_shinfo(skb)->nr_frags));
-	if(seg_cnt == -1) {
-		printk(KERN_ERR PFX"%s: invalid segment count!\n",__func__);
-		return NETDEV_TX_BUSY;
-	}
+	seg_cnt = tx_cb->seg_count;
 	/*
 	 * Map the skb buffer first.
 	 */
@@ -2278,7 +2273,7 @@ static int ql_send_map(struct ql3_adapter *qdev,
 				pci_unmap_addr_set(&tx_cb->map[seg], mapaddr,
 						   map);
 				pci_unmap_len_set(&tx_cb->map[seg], maplen,
-						  len);
+						  sizeof(struct oal));
 				oal_entry = (struct oal_entry *)oal;
 				oal++;
 				seg++;
-- 
1.5.0.rc4.16.g9e258

