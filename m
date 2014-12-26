From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 6/27] cw1200: queue: Use setup_timer
Date: Fri, 26 Dec 2014 15:35:39 +0100
Message-ID: <1419604558-29743-9-git-send-email-Julia.Lawall@lip6.fr>
References: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Solomon Peachy <pizza@shaftnet.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1419604558-29743-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert a call to init_timer and accompanying intializations of
the timer's data and function fields to a call to setup_timer.

A simplified version of the semantic match that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression t,f,d;
@@

-init_timer(&t);
+setup_timer(&t,f,d);
-t.data = d;
-t.function = f;
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/wireless/cw1200/queue.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/wireless/cw1200/queue.c b/drivers/net/wireless/cw1200/queue.c
index 9c3925f..0ba5ef9 100644
--- a/drivers/net/wireless/cw1200/queue.c
+++ b/drivers/net/wireless/cw1200/queue.c
@@ -179,9 +179,7 @@ int cw1200_queue_init(struct cw1200_queue *queue,
 	INIT_LIST_HEAD(&queue->pending);
 	INIT_LIST_HEAD(&queue->free_pool);
 	spin_lock_init(&queue->lock);
-	init_timer(&queue->gc);
-	queue->gc.data = (unsigned long)queue;
-	queue->gc.function = cw1200_queue_gc;
+	setup_timer(&queue->gc, cw1200_queue_gc, (unsigned long)queue);
 
 	queue->pool = kzalloc(sizeof(struct cw1200_queue_item) * capacity,
 			GFP_KERNEL);

