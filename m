From: Chetan Loke <loke.chetan@gmail.com>
Subject: [PATCH 1/1] block/nbd: micro-optimization in nbd request completion
Date: Wed,  6 Jun 2012 10:15:16 -0400
Message-ID: <1338992116-28094-1-git-send-email-loke.chetan@gmail.com>
Cc: netdev@vger.kernel.org, Chetan Loke <loke.chetan@gmail.com>
To: Paul.Clements@steeleye.com, axboe@kernel.dk,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add in-flight cmds to the tail. That way while searching(during request completion),we will always get a hit on the first element.


Signed-off-by: Chetan Loke <loke.chetan@gmail.com>
---
 drivers/block/nbd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 061427a..8957b9f 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -481,7 +481,7 @@ static void nbd_handle_req(struct nbd_device *nbd, struct request *req)
 		nbd_end_request(req);
 	} else {
 		spin_lock(&nbd->queue_lock);
-		list_add(&req->queuelist, &nbd->queue_head);
+		list_add_tail(&req->queuelist, &nbd->queue_head);
 		spin_unlock(&nbd->queue_lock);
 	}
 
-- 
1.7.5.2
