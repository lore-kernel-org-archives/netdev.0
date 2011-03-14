From: huzaifas@redhat.com
Subject: [PATCH] Fix possible null pointer dereference in ehea_qmr.c
Date: Mon, 14 Mar 2011 13:16:04 +0530
Message-ID: <1300088764-9330-1-git-send-email-huzaifas@redhat.com>
Cc: leitao@linux.vnet.ibm.com,
	Huzaifa Sidhpurwala <huzaifas@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10352 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753127Ab1CNHqN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Mar 2011 03:46:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Huzaifa Sidhpurwala <huzaifas@redhat.com>

If queue is zero, dont reference it

Signed-off-by: Huzaifa Sidhpurwala <huzaifas@redhat.com>
---
 drivers/net/ehea/ehea_qmr.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ehea/ehea_qmr.c
index cd44bb8..fd0815d 100644
--- a/drivers/net/ehea/ehea_qmr.c
+++ b/drivers/net/ehea/ehea_qmr.c
@@ -106,12 +106,13 @@ out_nomem:

 static void hw_queue_dtor(struct hw_queue *queue)
 {
-	int pages_per_kpage = PAGE_SIZE / queue->pagesize;
+	int pages_per_kpage;
        int i, nr_pages;

        if (!queue || !queue->queue_pages)
                return;

+	pages_per_kpage = PAGE_SIZE / queue->pagesize;
        nr_pages = queue->queue_length / queue->pagesize;

        for (i = 0; i < nr_pages; i += pages_per_kpage)
--
1.7.3.4
