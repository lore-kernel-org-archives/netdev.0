From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH 1/3] net: tulip: Use setup_timer()
Date: Wed, 24 Feb 2016 19:27:49 +0530
Message-ID: <20160224135749.GA14342@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: netdev@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert a call to init_timer and accompanying intializations of
the timer's data and function fields to a call to setup_timer.

The Coccinelle semantic patch that fixes this problem is
as follows:

// <smpl>
@@
expression t,f,d;
@@

-init_timer(&t);
+setup_timer(&t,f,d);
-t.data = d;
-t.function = f;
// </smpl>

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/ethernet/dec/tulip/tulip_core.c | 14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index b553409..94d0eeb 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -505,9 +505,7 @@ media_picked:
 	tp->timer.expires = RUN_AT(next_tick);
 	add_timer(&tp->timer);
 #ifdef CONFIG_TULIP_NAPI
-	init_timer(&tp->oom_timer);
-        tp->oom_timer.data = (unsigned long)dev;
-        tp->oom_timer.function = oom_timer;
+	setup_timer(&tp->oom_timer, oom_timer, (unsigned long)dev);
 #endif
 }
 
@@ -782,9 +780,8 @@ static void tulip_down (struct net_device *dev)
 
 	spin_unlock_irqrestore (&tp->lock, flags);
 
-	init_timer(&tp->timer);
-	tp->timer.data = (unsigned long)dev;
-	tp->timer.function = tulip_tbl[tp->chip_id].media_timer;
+	setup_timer(&tp->timer, tulip_tbl[tp->chip_id].media_timer,
+		    (unsigned long)dev);
 
 	dev->if_port = tp->saved_if_port;
 
@@ -1475,9 +1472,8 @@ static int tulip_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->csr0 = csr0;
 	spin_lock_init(&tp->lock);
 	spin_lock_init(&tp->mii_lock);
-	init_timer(&tp->timer);
-	tp->timer.data = (unsigned long)dev;
-	tp->timer.function = tulip_tbl[tp->chip_id].media_timer;
+	setup_timer(&tp->timer, tulip_tbl[tp->chip_id].media_timer,
+		    (unsigned long)dev);
 
 	INIT_WORK(&tp->media_work, tulip_tbl[tp->chip_id].media_task);
 
-- 
1.9.1

