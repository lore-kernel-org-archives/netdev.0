From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/4] net/ariadne: delete unneeded call to netdev_priv
Date: Thu, 15 May 2014 05:43:19 +0200
Message-ID: <1400125401-15512-2-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Netdev_priv is an accessor function, and has no purpose if its result is
not used.

A simplified version of the semantic match that fixes this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@ local idexpression x; @@
-x = netdev_priv(...);
... when != x
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/amd/ariadne.c |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index b08101b..968b7bf 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -718,7 +718,6 @@ static int ariadne_init_one(struct zorro_dev *z,
 	unsigned long mem_start = board + ARIADNE_RAM;
 	struct resource *r1, *r2;
 	struct net_device *dev;
-	struct ariadne_private *priv;
 	u32 serial;
 	int err;
 
@@ -738,8 +737,6 @@ static int ariadne_init_one(struct zorro_dev *z,
 		return -ENOMEM;
 	}
 
-	priv = netdev_priv(dev);
-
 	r1->name = dev->name;
 	r2->name = dev->name;
 
