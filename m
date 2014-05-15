From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/4] drivers/net/wan: delete unneeded call to netdev_priv
Date: Thu, 15 May 2014 05:43:18 +0200
Message-ID: <1400125401-15512-1-git-send-email-Julia.Lawall@lip6.fr>
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
 drivers/net/wan/sdla.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index de3bbf4..cdd45fb 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -1322,10 +1322,6 @@ NOTE:  This is rather a useless action right now, as the
 
 static int sdla_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct frad_local *flp;
-
-	flp = netdev_priv(dev);
-
 	if (netif_running(dev))
 		return -EBUSY;
 
