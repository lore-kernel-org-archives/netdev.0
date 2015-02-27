From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] drivers/net: Use setup_timer and mod_timer
Date: Fri, 27 Feb 2015 14:08:12 +0530
Message-ID: <20150227083812.GA15793@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use timer API functions setup_timer and mod_timer instead
of structure assignments as they are standard way to set
the timer and to update the expire field of an active timer
respectively.

This is done using Coccinelle and semantic patch used for
this is as follows:

// <smpl>
@@
expression x,y,z,a,b;
@@

-init_timer (&x);
+setup_timer (&x, y, z);
+mod_timer (&a, b);
-x.function = y;
-x.data = z;
-x.expires = b;
-add_timer(&a);

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/net/ethernet/8390/pcnet_cs.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/8390/pcnet_cs.c b/drivers/net/ethernet/8390/pcnet_cs.c
index 9fb7b9d..2777289 100644
--- a/drivers/net/ethernet/8390/pcnet_cs.c
+++ b/drivers/net/ethernet/8390/pcnet_cs.c
@@ -918,11 +918,8 @@ static int pcnet_open(struct net_device *dev)
 
     info->phy_id = info->eth_phy;
     info->link_status = 0x00;
-    init_timer(&info->watchdog);
-    info->watchdog.function = ei_watchdog;
-    info->watchdog.data = (u_long)dev;
-    info->watchdog.expires = jiffies + HZ;
-    add_timer(&info->watchdog);
+    setup_timer(&info->watchdog, ei_watchdog, (u_long)dev);
+    mod_timer(&info->watchdog, jiffies + HZ);
 
     return ei_open(dev);
 } /* pcnet_open */
-- 
1.9.1
