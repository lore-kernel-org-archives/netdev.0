From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 1/2] nbd: use list_for_each_entry_safe to make it more consolidated and readable
Date: Thu, 19 Jul 2007 17:34:30 +0800
Message-ID: <11848376711601-git-send-email-crquan@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Pavel Machek <pavel@ucw.cz>,
	Steven Whitehouse <steve@chygwyn.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Denis Cheng <crquan@gmail.com>
To: Paul Clements <Paul.Clements@steeleye.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.230]:26275 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758869AbXGSJep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 05:34:45 -0400
Received: by qb-out-0506.google.com with SMTP id e11so1095853qbe
        for <netdev@vger.kernel.org>; Thu, 19 Jul 2007 02:34:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thus the traverse of the loop may delete nodes, use the safe version.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 drivers/block/nbd.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index c129510..86639c0 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -237,8 +237,7 @@ error_out:
 
 static struct request *nbd_find_request(struct nbd_device *lo, char *handle)
 {
-	struct request *req;
-	struct list_head *tmp;
+	struct request *req, *n;
 	struct request *xreq;
 	int err;
 
@@ -249,8 +248,7 @@ static struct request *nbd_find_request(struct nbd_device *lo, char *handle)
 		goto out;
 
 	spin_lock(&lo->queue_lock);
-	list_for_each(tmp, &lo->queue_head) {
-		req = list_entry(tmp, struct request, queuelist);
+	list_for_each_entry_safe(req, n, &lo->queue_head, queuelist) {
 		if (req != xreq)
 			continue;
 		list_del_init(&req->queuelist);
-- 
1.5.2.2

