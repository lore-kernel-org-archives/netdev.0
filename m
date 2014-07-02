From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH v2 net-next 08/13] at86rf230: rework irq_pol setting
Date: Wed,  2 Jul 2014 17:10:05 +0200
Message-ID: <1404313810-30232-9-git-send-email-alex.aring@gmail.com>
References: <1404313810-30232-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, stilwellt@openlabs.co,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:57990 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587AbaGBPK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 11:10:27 -0400
Received: by mail-wi0-f172.google.com with SMTP id hi2so9789684wib.5
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 08:10:25 -0700 (PDT)
In-Reply-To: <1404313810-30232-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch rework the irq_pol register setting for rising and falling
interrupt settings only. The default behaviour should be rising flag.

Also use IRQ_TYPE_* defines instead of IRQF_* defines. There is no
functionality change but irq_get_trigger_type returns IRQ_TYPE_* defines.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 492fb7e..2340750 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1276,7 +1276,7 @@ static struct at86rf2xx_chip_data at86rf212_data = {
 
 static int at86rf230_hw_init(struct at86rf230_local *lp)
 {
-	int rc, irq_pol, irq_type;
+	int rc, irq_pol, irq_type = IRQ_ACTIVE_HIGH;
 	unsigned int dvdd;
 	u8 csma_seed[2];
 
@@ -1285,11 +1285,8 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 		return rc;
 
 	irq_type = irq_get_trigger_type(lp->spi->irq);
-	/* configure irq polarity, defaults to high active */
-	if (irq_type & (IRQF_TRIGGER_FALLING | IRQF_TRIGGER_LOW))
-		irq_pol = IRQ_ACTIVE_LOW;
-	else
-		irq_pol = IRQ_ACTIVE_HIGH;
+	if (irq_type == IRQ_TYPE_EDGE_FALLING)
+		irq_type = IRQ_ACTIVE_LOW;
 
 	rc = at86rf230_write_subreg(lp, SR_IRQ_POLARITY, irq_pol);
 	if (rc)
-- 
2.0.1
