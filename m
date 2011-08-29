From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/24] 9p: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 14:17:21 -0700
Message-ID: <54b66b2e5c1e1e0dac18e79fe97f4db6096403e5.1314650069.git.joe@perches.com>
References: <cover.1314650069.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52020 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754941Ab1H2VSm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Aug 2011 17:18:42 -0400
In-Reply-To: <cover.1314650069.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing unnecessary messages saves code and text.

Site specific OOM messages are duplications of a generic MM
out of memory message and aren't really useful, so just
delete them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/9p/client.c       |    7 ++-----
 net/9p/trans_virtio.c |    6 +-----
 2 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 0505a03..85c2a10 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -222,7 +222,6 @@ static struct p9_req_t *p9_tag_alloc(struct p9_client *c, u16 tag)
 					sizeof(struct p9_req_t), GFP_ATOMIC);
 
 			if (!c->reqs[row]) {
-				printk(KERN_ERR "Couldn't grow tag array\n");
 				spin_unlock_irqrestore(&c->lock, flags);
 				return ERR_PTR(-ENOMEM);
 			}
@@ -240,10 +239,9 @@ static struct p9_req_t *p9_tag_alloc(struct p9_client *c, u16 tag)
 	req = &c->reqs[row][col];
 	if (!req->tc) {
 		req->wq = kmalloc(sizeof(wait_queue_head_t), GFP_NOFS);
-		if (!req->wq) {
-			printk(KERN_ERR "Couldn't grow tag array\n");
+		if (!req->wq)
 			return ERR_PTR(-ENOMEM);
-		}
+
 		init_waitqueue_head(req->wq);
 		if ((c->trans_mod->pref & P9_TRANS_PREF_PAYLOAD_MASK) ==
 				P9_TRANS_PREF_PAYLOAD_SEP) {
@@ -263,7 +261,6 @@ static struct p9_req_t *p9_tag_alloc(struct p9_client *c, u16 tag)
 			req->rc->capacity = c->msize;
 		}
 		if ((!req->tc) || (!req->rc)) {
-			printk(KERN_ERR "Couldn't grow tag array\n");
 			kfree(req->tc);
 			kfree(req->rc);
 			kfree(req->wq);
diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 175b513..2ac547e 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -293,11 +293,8 @@ p9_virtio_request(struct p9_client *client, struct p9_req_t *req)
 			rpinfo->rp_alloc = 0;
 		} else {
 			req->tc->private = kmalloc(rpinfo_size, GFP_NOFS);
-			if (!req->tc->private) {
-				P9_DPRINTK(P9_DEBUG_TRANS, "9p debug: "
-					"private kmalloc returned NULL");
+			if (!req->tc->private)
 				return -ENOMEM;
-			}
 			rpinfo = (struct trans_rpage_info *)req->tc->private;
 			rpinfo->rp_alloc = 1;
 		}
@@ -431,7 +428,6 @@ static int p9_virtio_probe(struct virtio_device *vdev)
 
 	chan = kmalloc(sizeof(struct virtio_chan), GFP_KERNEL);
 	if (!chan) {
-		printk(KERN_ERR "9p: Failed to allocate virtio 9P channel\n");
 		err = -ENOMEM;
 		goto fail;
 	}
-- 
1.7.6.405.gc1be0
