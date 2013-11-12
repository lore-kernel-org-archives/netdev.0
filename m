From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net/7990: Make lance_private.name const
Date: Tue, 12 Nov 2013 20:14:09 +0100
Message-ID: <1384283649-10482-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows to drop a few casts.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 drivers/net/ethernet/amd/7990.h    |    2 +-
 drivers/net/ethernet/amd/hplance.c |    2 +-
 drivers/net/ethernet/amd/mvme147.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/7990.h b/drivers/net/ethernet/amd/7990.h
index 0a5837b96421..60c60926afda 100644
--- a/drivers/net/ethernet/amd/7990.h
+++ b/drivers/net/ethernet/amd/7990.h
@@ -100,7 +100,7 @@ struct lance_init_block {
  */
 struct lance_private
 {
-        char *name;
+        const char *name;
 	unsigned long base;
         volatile struct lance_init_block *init_block; /* CPU address of RAM */
         volatile struct lance_init_block *lance_init_block; /* LANCE address of RAM */
diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
index 0c61fd50d882..a9046cf3a564 100644
--- a/drivers/net/ethernet/amd/hplance.c
+++ b/drivers/net/ethernet/amd/hplance.c
@@ -149,7 +149,7 @@ static void hplance_init(struct net_device *dev, struct dio_dev *d)
         }
 
         lp = netdev_priv(dev);
-        lp->lance.name = (char*)d->name;                /* discards const, shut up gcc */
+        lp->lance.name = d->name;
         lp->lance.base = va;
         lp->lance.init_block = (struct lance_init_block *)(va + HPLANCE_MEMOFF); /* CPU addr */
         lp->lance.lance_init_block = NULL;              /* LANCE addr of same RAM */
diff --git a/drivers/net/ethernet/amd/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
index e108e911da05..b5d76b45176e 100644
--- a/drivers/net/ethernet/amd/mvme147.c
+++ b/drivers/net/ethernet/amd/mvme147.c
@@ -120,7 +120,7 @@ struct net_device * __init mvme147lance_probe(int unit)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	lp->lance.name = (char*)name;                   /* discards const, shut up gcc */
+	lp->lance.name = name;
 	lp->lance.base = dev->base_addr;
 	lp->lance.init_block = (struct lance_init_block *)(lp->ram); /* CPU addr */
 	lp->lance.lance_init_block = (struct lance_init_block *)(lp->ram);                 /* LANCE addr of same RAM */
-- 
1.7.9.5
