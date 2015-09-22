From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 19/33] arcnet: Make a char * array const char * const
Date: Tue, 22 Sep 2015 11:02:00 +0200
Message-ID: <1442912534-10821-20-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59368 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932645AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Might as well be specific about the use of this array.

Add a commment questioning the indexing too.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/com20020.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index f46e220..ddd64bb 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -42,10 +42,10 @@
 #include "arcdevice.h"
 #include "com20020.h"
 
-static char *clockrates[] = {
-	"XXXXXXX", "XXXXXXXX", "XXXXXX",
-	"2.5 Mb/s", "1.25Mb/s", "625 Kb/s", "312.5 Kb/s",
-	"156.25 Kb/s", "Reserved", "Reserved", "Reserved"
+static const char * const clockrates[] = {
+	"XXXXXXX", "XXXXXXXX", "XXXXXX", "2.5 Mb/s",
+	"1.25Mb/s", "625 Kb/s", "312.5 Kb/s", "156.25 Kb/s",
+	"Reserved", "Reserved", "Reserved"
 };
 
 static void com20020_command(struct net_device *dev, int command);
@@ -234,7 +234,12 @@ int com20020_found(struct net_device *dev, int shared)
 
 	arc_printk(D_NORMAL, dev, "Using CKP %d - data rate %s\n",
 		   lp->setup >> 1,
-		   clockrates[3 - ((lp->setup2 & 0xF0) >> 4) + ((lp->setup & 0x0F) >> 1)]);
+		   clockrates[3 -
+			      ((lp->setup2 & 0xF0) >> 4) +
+			      ((lp->setup & 0x0F) >> 1)]);
+			/* The clockrates array index looks very fragile.
+			 * It seems like it could have negative indexing.
+			 */
 
 	if (register_netdev(dev)) {
 		free_irq(dev->irq, dev);
-- 
2.5.1
