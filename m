From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] net: Use setup_timer and mod_timer
Date: Fri, 27 Feb 2015 14:18:12 +0530
Message-ID: <20150227084812.GA15946@vaishali-Ideapad-Z570>
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
 drivers/net/ethernet/smsc/smc91c92_cs.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index 6b33127..3449893 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -1070,11 +1070,8 @@ static int smc_open(struct net_device *dev)
     smc->packets_waiting = 0;
 
     smc_reset(dev);
-    init_timer(&smc->media);
-    smc->media.function = media_check;
-    smc->media.data = (u_long) dev;
-    smc->media.expires = jiffies + HZ;
-    add_timer(&smc->media);
+    setup_timer(&smc->media, media_check, (u_long)dev);
+    mod_timer(&smc->media, jiffies + HZ);
 
     return 0;
 } /* smc_open */
-- 
1.9.1
