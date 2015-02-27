From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH v2] net: 8390: axnet_cs: Use setup_timer and mod_timer
Date: Sat, 28 Feb 2015 00:02:34 +0530
Message-ID: <20150227183234.GA20213@vaishali-Ideapad-Z570>
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
// </smpl>

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
Changes since v1:
        -Change subject line
        -Change commit log

 drivers/net/ethernet/8390/axnet_cs.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index 7769c05..ec6eac1 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -484,11 +484,8 @@ static int axnet_open(struct net_device *dev)
     link->open++;
 
     info->link_status = 0x00;
-    init_timer(&info->watchdog);
-    info->watchdog.function = ei_watchdog;
-    info->watchdog.data = (u_long)dev;
-    info->watchdog.expires = jiffies + HZ;
-    add_timer(&info->watchdog);
+    setup_timer(&info->watchdog, ei_watchdog, (u_long)dev);
+    mod_timer(&info->watchdog, jiffies + HZ);
 
     return ax_open(dev);
 } /* axnet_open */
-- 
1.9.1
