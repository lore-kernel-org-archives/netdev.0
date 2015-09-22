From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 14/33] arcnet: Remove assignments from ifs
Date: Tue, 22 Sep 2015 11:01:55 +0200
Message-ID: <1442912534-10821-15-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49122 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932536AbbIVJCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:41 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Move the assignment above the if like general kernel style.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020-isa.c | 4 +++-
 drivers/net/arcnet/com20020.c     | 3 ++-
 drivers/net/arcnet/com90io.c      | 3 ++-
 3 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index f3b2222..352500b 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -107,7 +107,9 @@ static int __init com20020isa_probe(struct net_device *dev)
 	}
 
 	lp->card_name = "ISA COM20020";
-	if ((err = com20020_found(dev, 0)) != 0)
+
+	err = com20020_found(dev, 0);
+	if (err != 0)
 		goto out;
 
 	return 0;
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index e813fc6..bea3862 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -140,7 +140,8 @@ int com20020_check(struct net_device *dev)
 	outb(0 | RDDATAflag | AUTOINCflag, _ADDR_HI);
 	outb(0, _ADDR_LO);
 
-	if ((status = inb(_MEMDATA)) != TESTvalue) {
+	status = inb(_MEMDATA);
+	if (status != TESTvalue) {
 		arc_printk(D_NORMAL, dev, "Signature byte not found (%02Xh != D1h).\n",
 			   status);
 		return -ENODEV;
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 32abaa8..11bc589 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -196,7 +196,8 @@ static int __init com90io_probe(struct net_device *dev)
 	outb(AUTOINCflag, _ADDR_HI);
 	outb(0, _ADDR_LO);
 
-	if ((status = inb(_MEMDATA)) != 0xd1) {
+	status = inb(_MEMDATA);
+	if (status != 0xd1) {
 		arc_printk(D_INIT_REASONS, dev, "Signature byte not found (%Xh instead).\n",
 			   status);
 		goto err_out;
-- 
2.5.1
