From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 net-next 08/13] at86rf230: rework
	irq_pol setting
Date: Thu,  3 Jul 2014 00:20:50 +0200
Message-ID: <1404339655-8456-9-git-send-email-alex.aring@gmail.com>
References: <1404339655-8456-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1404339655-8456-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch rework the irq_pol register setting for rising and falling
interrupt settings only. The default behaviour should be rising flag.

Also use IRQ_TYPE_* defines instead of IRQF_* defines. There is no
functionality change but irq_get_trigger_type returns IRQ_TYPE_* defines.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 492fb7e..46db6f8 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -1276,7 +1276,7 @@ static struct at86rf2xx_chip_data at86rf212_data = {
 
 static int at86rf230_hw_init(struct at86rf230_local *lp)
 {
-	int rc, irq_pol, irq_type;
+	int rc, irq_type, irq_pol = IRQ_ACTIVE_HIGH;
 	unsigned int dvdd;
 	u8 csma_seed[2];
 
@@ -1285,11 +1285,8 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 		return rc;
 
 	irq_type = irq_get_trigger_type(lp->spi->irq);
-	/* configure irq polarity, defaults to high active */
-	if (irq_type & (IRQF_TRIGGER_FALLING | IRQF_TRIGGER_LOW))
+	if (irq_type == IRQ_TYPE_EDGE_FALLING)
 		irq_pol = IRQ_ACTIVE_LOW;
-	else
-		irq_pol = IRQ_ACTIVE_HIGH;
 
 	rc = at86rf230_write_subreg(lp, SR_IRQ_POLARITY, irq_pol);
 	if (rc)
-- 
2.0.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
