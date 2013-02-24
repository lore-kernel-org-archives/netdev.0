From: Syam Sidhardhan <syamsidhardh@gmail.com>
Subject: [PATCH] ehea: Fix possible NULL pointer dereference
Date: Mon, 25 Feb 2013 04:29:58 +0530
Message-ID: <1361746798-29215-1-git-send-email-s.syam@samsung.com>
Cc: syamsidhardh@gmail.com, cascardo@linux.vnet.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f42.google.com ([209.85.210.42]:53258 "EHLO
	mail-da0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758716Ab3BXXAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 18:00:10 -0500
Received: by mail-da0-f42.google.com with SMTP id z17so1173902dal.29
        for <netdev@vger.kernel.org>; Sun, 24 Feb 2013 15:00:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check for (queue == NULL) has to be done before accessing queue.

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 drivers/net/ethernet/ibm/ehea/ehea_qmr.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
index 9b03033..a0820f7 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
@@ -103,12 +103,14 @@ out_nomem:
 
 static void hw_queue_dtor(struct hw_queue *queue)
 {
-	int pages_per_kpage = PAGE_SIZE / queue->pagesize;
+	int pages_per_kpage;
 	int i, nr_pages;
 
 	if (!queue || !queue->queue_pages)
 		return;
 
+	pages_per_kpage = PAGE_SIZE / queue->pagesize;
+
 	nr_pages = queue->queue_length / queue->pagesize;
 
 	for (i = 0; i < nr_pages; i += pages_per_kpage)
-- 
1.7.9.5
