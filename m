From: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
Subject: [PATCH] powerpc/83xx: gianfar_ptp: select 1588 clock source through dts file
Date: Wed, 18 Sep 2013 17:21:04 +0400
Message-ID: <1379510464-25420-1-git-send-email-aida.mynzhasova@skitlab.ru>
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.skitlab.ru ([217.65.220.135]:36437 "EHLO mail.skitlab.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750942Ab3IRN3n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 09:29:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IEEE 1588 timer reference clock source is determined through hard-coded
value in gianfar_ptp driver by default. This patch allows to select ptp
clock source by means of device tree file node.

For instance:

	fsl,cksel = <0>;

for using external (TSEC_TMR_CLK input) high precision timer
reference clock.

Other acceptable values:

	<1> : eTSEC system clock
	<2> : eTSEC1 transmit clock
	<3> : RTC clock input

Signed-off-by: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
---
 drivers/net/ethernet/freescale/gianfar_ptp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
index 098f133..e006a09 100644
--- a/drivers/net/ethernet/freescale/gianfar_ptp.c
+++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
@@ -452,7 +452,9 @@ static int gianfar_ptp_probe(struct platform_device *dev)
 	err = -ENODEV;
 
 	etsects->caps = ptp_gianfar_caps;
-	etsects->cksel = DEFAULT_CKSEL;
+
+	if (get_of_u32(node, "fsl,cksel", &etsects->cksel))
+		etsects->cksel = DEFAULT_CKSEL;
 
 	if (get_of_u32(node, "fsl,tclk-period", &etsects->tclk_period) ||
 	    get_of_u32(node, "fsl,tmr-prsc", &etsects->tmr_prsc) ||
-- 
1.8.1.2
