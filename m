From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: [PATCH] can: sja1000: use cpu endian
Date: Mon, 08 Apr 2013 15:48:52 +0200
Message-ID: <1365428932.5760.52.camel@lovely>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	Bill Pemberton <wfp5p@virginia.edu>,
	Andreas Larsson <andreas@gaisler.com>,
	linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Hans J. Koch" <hjk@hansjkoch.de>, Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:40644 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935940Ab3DHNs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 09:48:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
---
 drivers/net/can/sja1000/sja1000_of_platform.c |   26 ++++++++++++------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/net/can/sja1000/sja1000_of_platform.c
index 6433b81..83a13d2 100644
--- a/drivers/net/can/sja1000/sja1000_of_platform.c
+++ b/drivers/net/can/sja1000/sja1000_of_platform.c
@@ -97,7 +97,7 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
 	struct sja1000_priv *priv;
 	struct resource res;
 	const u32 *prop;
-	int err, irq, res_size, prop_size;
+	int err, irq, res_size;
 	void __iomem *base;
 
 	err = of_address_to_resource(np, 0, &res);
@@ -138,27 +138,27 @@ static int sja1000_ofp_probe(struct platform_device *ofdev)
 	priv->read_reg = sja1000_ofp_read_reg;
 	priv->write_reg = sja1000_ofp_write_reg;
 
-	prop = of_get_property(np, "nxp,external-clock-frequency", &prop_size);
-	if (prop && (prop_size ==  sizeof(u32)))
-		priv->can.clock.freq = *prop / 2;
+	prop = of_get_property(np, "nxp,external-clock-frequency", NULL);
+	if (prop)
+		priv->can.clock.freq = be32_to_cpup(prop) / 2;
 	else
 		priv->can.clock.freq = SJA1000_OFP_CAN_CLOCK; /* default */
 
-	prop = of_get_property(np, "nxp,tx-output-mode", &prop_size);
-	if (prop && (prop_size == sizeof(u32)))
-		priv->ocr |= *prop & OCR_MODE_MASK;
+	prop = of_get_property(np, "nxp,tx-output-mode", NULL);
+	if (prop)
+		priv->ocr |= be32_to_cpup(prop) & OCR_MODE_MASK;
 	else
 		priv->ocr |= OCR_MODE_NORMAL; /* default */
 
-	prop = of_get_property(np, "nxp,tx-output-config", &prop_size);
-	if (prop && (prop_size == sizeof(u32)))
-		priv->ocr |= (*prop << OCR_TX_SHIFT) & OCR_TX_MASK;
+	prop = of_get_property(np, "nxp,tx-output-config", NULL);
+	if (prop)
+		priv->ocr |= (be32_to_cpup(prop) << OCR_TX_SHIFT) & OCR_TX_MASK;
 	else
 		priv->ocr |= OCR_TX0_PULLDOWN; /* default */
 
-	prop = of_get_property(np, "nxp,clock-out-frequency", &prop_size);
-	if (prop && (prop_size == sizeof(u32)) && *prop) {
-		u32 divider = priv->can.clock.freq * 2 / *prop;
+	prop = of_get_property(np, "nxp,clock-out-frequency", NULL);
+	if (prop) {
+		u32 divider = priv->can.clock.freq * 2 / be32_to_cpup(prop);
 
 		if (divider > 1)
 			priv->cdr |= divider / 2 - 1;
-- 
1.7.2.5
