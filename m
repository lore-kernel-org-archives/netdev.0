From: Vaishali Thakkar <vthakkar1994@gmail.com>
Subject: [PATCH] net: dl2k: Use setup_timer
Date: Mon, 1 Jun 2015 09:55:10 +0530
Message-ID: <20150601042510.GA3846@vaishali-Ideapad-Z570>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the timer API function setup_timer instead of structure field
assignments to initialize a timer.

A simplified version of the Coccinelle semantic patch that performs
this transformation is as follows:

@change@
expression e1, e2, e3, e4, a, b;
@@

-init_timer(&e1);
+setup_timer(&e1, a, b);

... when != a = e2
    when != b = e3

-e1.data = b;
... when != a = e4
-e1.function = a;

Signed-off-by: Vaishali Thakkar <vthakkar1994@gmail.com>
---
 drivers/net/ethernet/dlink/dl2k.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 1274b6f..cf0a5fc 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -463,10 +463,8 @@ rio_open (struct net_device *dev)
 		dw32(MACCtrl, dr32(MACCtrl) | AutoVLANuntagging);
 	}
 
-	init_timer (&np->timer);
+	setup_timer(&np->timer, rio_timer, (unsigned long)dev);
 	np->timer.expires = jiffies + 1*HZ;
-	np->timer.data = (unsigned long) dev;
-	np->timer.function = rio_timer;
 	add_timer (&np->timer);
 
 	/* Start Tx/Rx */
-- 
1.9.1
