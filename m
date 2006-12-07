From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 1/2] ucc_geth: compilation error fixes
Date: Thu, 7 Dec 2006 13:31:07 -0600
Message-ID: <20061207193107.GA23994@ld0162-tx32.am.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:46078 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937996AbWLGTbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 14:31:18 -0500
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix compilation failures when building the ucc_geth driver with spinlock
debugging.

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
 drivers/net/ucc_geth.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 1f05511..62d979b 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -194,9 +194,9 @@ static void enqueue(struct list_head *no
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(ugeth_lock, flags);
+	spin_lock_irqsave(&ugeth_lock, flags);
 	list_add_tail(node, lh);
-	spin_unlock_irqrestore(ugeth_lock, flags);
+	spin_unlock_irqrestore(&ugeth_lock, flags);
 }
 #endif /* CONFIG_UGETH_FILTERING */
 
@@ -204,14 +204,14 @@ static struct list_head *dequeue(struct 
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(ugeth_lock, flags);
+	spin_lock_irqsave(&ugeth_lock, flags);
 	if (!list_empty(lh)) {
 		struct list_head *node = lh->next;
 		list_del(node);
-		spin_unlock_irqrestore(ugeth_lock, flags);
+		spin_unlock_irqrestore(&ugeth_lock, flags);
 		return node;
 	} else {
-		spin_unlock_irqrestore(ugeth_lock, flags);
+		spin_unlock_irqrestore(&ugeth_lock, flags);
 		return NULL;
 	}
 }
-- 
1.4.2.3
