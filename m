From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 03/13] qla3xxx: Changed to use netdev_alloc_skb() from dev_alloc_skb
Date: Mon, 26 Feb 2007 11:06:33 -0800
Message-ID: <11725168033310-git-send-email-ron.mercer@qlogic.com>
References: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Cc: ron.mercer@qlogic.com, romieu@fr.zoreil.com,
	benjamin.li@qlogic.com, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:15768 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933804AbXBZTHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Feb 2007 14:07:43 -0500
In-Reply-To: <20070226190450.GA7325@linux-7mw0.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Li <benjamin.li@qlogic.com>

Signed-off-by: Benjamin Li <benjamin.li@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qla3xxx.c |   13 ++++++++-----
 1 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 18a2bb5..5acae02 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -287,9 +287,10 @@ static void ql_release_to_lrg_buf_free_list(struct ql3_adapter *qdev,
 	}
 
 	if (!lrg_buf_cb->skb) {
-		lrg_buf_cb->skb = dev_alloc_skb(qdev->lrg_buffer_len);
+		lrg_buf_cb->skb = netdev_alloc_skb(qdev->ndev,
+						   qdev->lrg_buffer_len);
 		if (unlikely(!lrg_buf_cb->skb)) {
-			printk(KERN_ERR PFX "%s: failed dev_alloc_skb().\n",
+			printk(KERN_ERR PFX "%s: failed netdev_alloc_skb().\n",
 			       qdev->ndev->name);
 			qdev->lrg_buf_skb_check++;
 		} else {
@@ -1619,10 +1620,11 @@ static int ql_populate_free_queue(struct ql3_adapter *qdev)
 
 	while (lrg_buf_cb) {
 		if (!lrg_buf_cb->skb) {
-			lrg_buf_cb->skb = dev_alloc_skb(qdev->lrg_buffer_len);
+			lrg_buf_cb->skb = netdev_alloc_skb(qdev->ndev,
+							   qdev->lrg_buffer_len);
 			if (unlikely(!lrg_buf_cb->skb)) {
 				printk(KERN_DEBUG PFX
-				       "%s: Failed dev_alloc_skb().\n",
+				       "%s: Failed netdev_alloc_skb().\n",
 				       qdev->ndev->name);
 				break;
 			} else {
@@ -2514,7 +2516,8 @@ static int ql_alloc_large_buffers(struct ql3_adapter *qdev)
 	u64 map;
 
 	for (i = 0; i < NUM_LARGE_BUFFERS; i++) {
-		skb = dev_alloc_skb(qdev->lrg_buffer_len);
+		skb = netdev_alloc_skb(qdev->ndev,
+				       qdev->lrg_buffer_len);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
 			printk(KERN_ERR PFX
-- 
1.5.0.rc4.16.g9e258

