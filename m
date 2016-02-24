From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH 3/3] 3c59x: Use setup_timer()
Date: Wed, 24 Feb 2016 19:28:19 +0530
Message-ID: <20160224135819.GA14426@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: klassert@mathematik.tu-chemnitz.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
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
 ...
-t.data = d;
-t.function = f;
// </smpl>

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/net/ethernet/3com/3c59x.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 79e1a02..c377607 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -1601,15 +1601,9 @@ vortex_up(struct net_device *dev)
 				dev->name, media_tbl[dev->if_port].name);
 	}
 
-	init_timer(&vp->timer);
+	setup_timer(&vp->timer, vortex_timer, (unsigned long)dev);
 	vp->timer.expires = RUN_AT(media_tbl[dev->if_port].wait);
-	vp->timer.data = (unsigned long)dev;
-	vp->timer.function = vortex_timer;		/* timer handler */
-	add_timer(&vp->timer);
-
-	init_timer(&vp->rx_oom_timer);
-	vp->rx_oom_timer.data = (unsigned long)dev;
-	vp->rx_oom_timer.function = rx_oom_timer;
+	setup_timer(&vp->rx_oom_timer, rx_oom_timer, (unsigned long)dev);
 
 	if (vortex_debug > 1)
 		pr_debug("%s: Initial media type %s.\n",
-- 
1.9.1
