From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] drivers/net: Use setup_timer and mod_timer
Date: Wed, 11 Feb 2015 15:59:50 +0530
Message-ID: <20150211102950.GA23755@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	Felipe Balbi <balbi@ti.com>,
	Justin van Wijngaarden <justinvanwijngaarden@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduces the use of functions setup_timer
and mod_timer.

This is done using Coccinelle and semantic patch used
for this as follows:

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
 drivers/net/ethernet/3com/3c589_cs.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
index f18647c..c5a3205 100644
--- a/drivers/net/ethernet/3com/3c589_cs.c
+++ b/drivers/net/ethernet/3com/3c589_cs.c
@@ -518,11 +518,8 @@ static int el3_open(struct net_device *dev)
 	netif_start_queue(dev);
 
 	tc589_reset(dev);
-	init_timer(&lp->media);
-	lp->media.function = media_check;
-	lp->media.data = (unsigned long) dev;
-	lp->media.expires = jiffies + HZ;
-	add_timer(&lp->media);
+	setup_timer(&lp->media, media_check, (unsigned long)dev);
+	mod_timer(&lp->media, jiffies + HZ);
 
 	dev_dbg(&link->dev, "%s: opened, status %4.4x.\n",
 	  dev->name, inw(dev->base_addr + EL3_STATUS));
-- 
1.9.1
