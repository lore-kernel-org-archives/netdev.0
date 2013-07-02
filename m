From: Simon Derr <simon.derr@bull.net>
Subject: [PATCH 02/10] 9P/RDMA: rdma_request() needs not allocate req->rc
Date: Tue,  2 Jul 2013 15:11:16 +0200
Message-ID: <1372770684-25573-3-git-send-email-simon.derr@bull.net>
References: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Cc: simon.derr@bull.net, ericvh@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:40995 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560Ab3GBNl5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 09:41:57 -0400
In-Reply-To: <1372770684-25573-1-git-send-email-simon.derr@bull.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

p9_tag_alloc() takes care of that.

Signed-off-by: Simon Derr <simon.derr@bull.net>
---
 net/9p/trans_rdma.c |   19 -------------------
 1 files changed, 0 insertions(+), 19 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 2c69ddd..b1dfdf2 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -427,26 +427,7 @@ static int rdma_request(struct p9_client *client, struct p9_req_t *req)
 		err = -ENOMEM;
 		goto err_close;
 	}
-
-	/*
-	 * If the request has a buffer, steal it, otherwise
-	 * allocate a new one.  Typically, requests should already
-	 * have receive buffers allocated and just swap them around
-	 */
-	if (!req->rc) {
-		req->rc = kmalloc(sizeof(struct p9_fcall)+client->msize,
-				  GFP_NOFS);
-		if (req->rc) {
-			req->rc->sdata = (char *) req->rc +
-						sizeof(struct p9_fcall);
-			req->rc->capacity = client->msize;
-		}
-	}
 	rpl_context->rc = req->rc;
-	if (!rpl_context->rc) {
-		err = -ENOMEM;
-		goto err_free2;
-	}
 
 	/*
 	 * Post a receive buffer for this request. We need to ensure
-- 
1.7.2.2
