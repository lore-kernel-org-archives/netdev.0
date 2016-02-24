From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [v2, 2/3] gianfar_ptp: replace get_of_u32 with of_property_read_u32
Date: Wed, 24 Feb 2016 17:26:55 +0800
Message-ID: <1456306016-29723-3-git-send-email-yangbo.lu@nxp.com>
References: <1456306016-29723-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt@kernel.org>,
	Andy Fleming <afleming@gmail.com>,
	Kumar Gala <galak@codeaurora.org>,
	Claudiu Manoil <claudiu.manoil@freescale.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Yangbo Lu <yangbo.lu@nxp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0096.outbound.protection.outlook.com ([65.55.169.96]:14304
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750775AbcBXJu4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 04:50:56 -0500
In-Reply-To: <1456306016-29723-1-git-send-email-yangbo.lu@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace get_of_u32 with standard helper function of_property_read_u32
since the latter can process cpu endianness.

Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
---
Changes for v2:
	- Modified commit message
	- Replaced get_of_u32 with of_property_read_u32
---
 drivers/net/ethernet/freescale/gianfar_ptp.c | 33 +++++++++++-----------------
 1 file changed, 13 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index b40fba9..5779881 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -422,19 +422,6 @@ static struct ptp_clock_info ptp_gianfar_caps = {
 	.enable		= ptp_gianfar_enable,
 };
 
-/* OF device tree */
-
-static int get_of_u32(struct device_node *node, char *str, u32 *val)
-{
-	int plen;
-	const u32 *prop = of_get_property(node, str, &plen);
-
-	if (!prop || plen != sizeof(*prop))
-		return -1;
-	*val = *prop;
-	return 0;
-}
-
 static int gianfar_ptp_probe(struct platform_device *dev)
 {
 	struct device_node *node = dev->dev.of_node;
@@ -452,15 +439,21 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 
 	etsects->caps = ptp_gianfar_caps;
 
-	if (get_of_u32(node, "fsl,cksel", &etsects->cksel))
+	if (of_property_read_u32(node, "fsl,cksel", &etsects->cksel))
 		etsects->cksel = DEFAULT_CKSEL;
 
-	if (get_of_u32(node, "fsl,tclk-period", &etsects->tclk_period) ||
-	    get_of_u32(node, "fsl,tmr-prsc", &etsects->tmr_prsc) ||
-	    get_of_u32(node, "fsl,tmr-add", &etsects->tmr_add) ||
-	    get_of_u32(node, "fsl,tmr-fiper1", &etsects->tmr_fiper1) ||
-	    get_of_u32(node, "fsl,tmr-fiper2", &etsects->tmr_fiper2) ||
-	    get_of_u32(node, "fsl,max-adj", &etsects->caps.max_adj)) {
+	if (of_property_read_u32(node,
+				 "fsl,tclk-period", &etsects->tclk_period) ||
+	    of_property_read_u32(node,
+				 "fsl,tmr-prsc", &etsects->tmr_prsc) ||
+	    of_property_read_u32(node,
+				 "fsl,tmr-add", &etsects->tmr_add) ||
+	    of_property_read_u32(node,
+				 "fsl,tmr-fiper1", &etsects->tmr_fiper1) ||
+	    of_property_read_u32(node,
+				 "fsl,tmr-fiper2", &etsects->tmr_fiper2) ||
+	    of_property_read_u32(node,
+				 "fsl,max-adj", &etsects->caps.max_adj)) {
 		pr_err("device tree node missing required elements\n");
 		goto no_node;
 	}
-- 
2.1.0.27.g96db324
