From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] connector: Delete an error message for a failed memory
 allocation in cn_queue_alloc_callback_entry()
Date: Sun, 27 Aug 2017 21:25:35 +0200
Message-ID: <7b206228-b3e9-5cb9-873c-75b5d8aae23b@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.12]:52966 "EHLO mout.web.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751255AbdH0TZi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 15:25:38 -0400
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 27 Aug 2017 21:18:37 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/connector/cn_queue.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index 1f8bf054d11c..e4f31d679f02 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -40,10 +40,8 @@ cn_queue_alloc_callback_entry(struct cn_queue_dev *dev, const char *name,
 	struct cn_callback_entry *cbq;
 
 	cbq = kzalloc(sizeof(*cbq), GFP_KERNEL);
-	if (!cbq) {
-		pr_err("Failed to create new callback queue.\n");
+	if (!cbq)
 		return NULL;
-	}
 
 	atomic_set(&cbq->refcnt, 1);
 
-- 
2.14.1
