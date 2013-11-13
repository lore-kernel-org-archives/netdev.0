From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH -v2 2/2] net/7990: Make lance_private.name const
Date: Wed, 13 Nov 2013 09:52:38 +0100
Message-ID: <1384332758-7106-2-git-send-email-geert@linux-m68k.org>
References: <1384332758-7106-1-git-send-email-geert@linux-m68k.org>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from georges.telenet-ops.be ([195.130.137.68]:54177 "EHLO
	georges.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932584Ab3KMIws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 03:52:48 -0500
In-Reply-To: <1384332758-7106-1-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows to drop a few casts.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
v2: Rebase after whitespace cleanup

 drivers/net/ethernet/amd/7990.h    |    2 +-
 drivers/net/ethernet/amd/hplance.c |    2 +-
 drivers/net/ethernet/amd/mvme147.c |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/7990.h b/drivers/net/ethernet/amd/7990.h
index 6a1a45374aec..408aa2a4783b 100644
--- a/drivers/net/ethernet/amd/7990.h
+++ b/drivers/net/ethernet/amd/7990.h
@@ -98,7 +98,7 @@ struct lance_init_block {
  * drivers to add things...
  */
 struct lance_private {
-	char *name;
+	const char *name;
 	unsigned long base;
 	volatile struct lance_init_block *init_block; /* CPU address of RAM */
 	volatile struct lance_init_block *lance_init_block; /* LANCE address of RAM */
diff --git a/drivers/net/ethernet/amd/hplance.c b/drivers/net/ethernet/amd/hplance.c
index 88a81a18374d..47ce57c2c893 100644
--- a/drivers/net/ethernet/amd/hplance.c
+++ b/drivers/net/ethernet/amd/hplance.c
@@ -149,7 +149,7 @@ static void hplance_init(struct net_device *dev, struct dio_dev *d)
 	}
 
 	lp = netdev_priv(dev);
-	lp->lance.name = (char *)d->name;                /* discards const, shut up gcc */
+	lp->lance.name = d->name;
 	lp->lance.base = va;
 	lp->lance.init_block = (struct lance_init_block *)(va + HPLANCE_MEMOFF); /* CPU addr */
 	lp->lance.lance_init_block = NULL;              /* LANCE addr of same RAM */
diff --git a/drivers/net/ethernet/amd/mvme147.c b/drivers/net/ethernet/amd/mvme147.c
index 15a5e366af29..0e8399dec054 100644
--- a/drivers/net/ethernet/amd/mvme147.c
+++ b/drivers/net/ethernet/amd/mvme147.c
@@ -118,7 +118,7 @@ struct net_device * __init mvme147lance_probe(int unit)
 		return ERR_PTR(-ENOMEM);
 	}
 
-	lp->lance.name = (char *)name;                   /* discards const, shut up gcc */
+	lp->lance.name = name;
 	lp->lance.base = dev->base_addr;
 	lp->lance.init_block = (struct lance_init_block *)(lp->ram); /* CPU addr */
 	lp->lance.lance_init_block = (struct lance_init_block *)(lp->ram);                 /* LANCE addr of same RAM */
-- 
1.7.9.5
