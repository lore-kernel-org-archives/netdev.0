From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] can: sja1000: fix compilation on x86
Date: Fri, 14 Dec 2012 22:33:44 +0100
Message-ID: <1355520824-23175-2-git-send-email-mkl@pengutronix.de>
References: <1355520824-23175-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, sfr@canb.auug.org.au,
	davem@davemloft.net, Marc Kleine-Budde <mkl@pengutronix.de>,
	Andreas Larsson <andreas@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37799 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932326Ab2LNVeH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 16:34:07 -0500
In-Reply-To: <1355520824-23175-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit:
04df251 can: sja1000: Make sja1000_of_platform selectable and compilable on SPARC
the driver can be activated on non powerpc platform like x86 or sparc. Without
this patch the driver fails to compile on platform that don't define NO_IRQ,
like x86.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Andreas Larsson <andreas@gaisler.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/sja1000/sja1000_of_platform.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 0f59170..38d37c8 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -121,7 +121,7 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
 	}
 
 	irq = irq_of_parse_and_map(np, 0);
-	if (irq == NO_IRQ) {
+	if (irq <= 0) {
 		dev_err(&ofdev->dev, "no irq found\n");
 		err = -ENODEV;
 		goto exit_unmap_mem;
-- 
1.7.10.4
