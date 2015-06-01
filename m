From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] xen-netfront: Use setup_timer
Date: Mon, 1 Jun 2015 10:28:37 +0530
Message-ID: <20150601045837.GA6448@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Julia Lawall <julia.lawall@lip6.fr>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the timer API function setup_timer instead of structure field
assignments to initialize a timer.

A simplified version of the Coccinelle semantic patch that performs
this transformation is as follows:

@change@
expression e, func, da;
@@

-init_timer (&e);
+setup_timer (&e, func, da);
-e.data = da;
-e.function = func;

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/net/xen-netfront.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 3f45afd..10a087a 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1560,9 +1560,8 @@ static int xennet_init_queue(struct netfront_queue *queue)
 	spin_lock_init(&queue->tx_lock);
 	spin_lock_init(&queue->rx_lock);
 
-	init_timer(&queue->rx_refill_timer);
-	queue->rx_refill_timer.data = (unsigned long)queue;
-	queue->rx_refill_timer.function = rx_refill_timeout;
+	setup_timer(&queue->rx_refill_timer, rx_refill_timeout,
+		    (unsigned long)queue);
 
 	snprintf(queue->name, sizeof(queue->name), "%s-q%u",
 		 queue->info->netdev->name, queue->id);
-- 
1.9.1
