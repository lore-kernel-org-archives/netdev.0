From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net v2 5/8] gianfar: Exclude PPC specific errata handling from ARM builds
Date: Tue, 7 Oct 2014 10:44:32 +0300
Message-ID: <1412667875-18225-6-git-send-email-claudiu.manoil@freescale.com>
References: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"Kim Phillips" <kim.phillips@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [157.56.110.133] ([157.56.110.133]:38352 "EHLO
	na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753269AbaJGHrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 03:47:15 -0400
In-Reply-To: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This excludes the PPC specific instructions for PPC based SoC
(MPC85xx family) version identification from ARM builds.
The PPC specific macro mfspr() from asm/reg.h is not defined
by the ARM architecture.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
v2 - none

 drivers/net/ethernet/freescale/gianfar.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index a488105..37e0604 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -88,8 +88,10 @@
 #include <linux/net_tstamp.h>
 
 #include <asm/io.h>
+#ifdef CONFIG_PPC
 #include <asm/reg.h>
 #include <asm/mpc85xx.h>
+#endif
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 #include <linux/module.h>
@@ -1063,6 +1065,7 @@ static void gfar_init_filer_table(struct gfar_private *priv)
 	}
 }
 
+#ifdef CONFIG_PPC
 static void __gfar_detect_errata_83xx(struct gfar_private *priv)
 {
 	unsigned int pvr = mfspr(SPRN_PVR);
@@ -1095,6 +1098,7 @@ static void __gfar_detect_errata_85xx(struct gfar_private *priv)
 	    ((SVR_SOC_VER(svr) == SVR_P2010) && (SVR_REV(svr) < 0x20)))
 		priv->errata |= GFAR_ERRATA_76; /* aka eTSEC 20 */
 }
+#endif
 
 static void gfar_detect_errata(struct gfar_private *priv)
 {
@@ -1103,10 +1107,12 @@ static void gfar_detect_errata(struct gfar_private *priv)
 	/* no plans to fix */
 	priv->errata |= GFAR_ERRATA_A002;
 
+#ifdef CONFIG_PPC
 	if (pvr_version_is(PVR_VER_E500V1) || pvr_version_is(PVR_VER_E500V2))
 		__gfar_detect_errata_85xx(priv);
 	else /* non-mpc85xx parts, i.e. e300 core based */
 		__gfar_detect_errata_83xx(priv);
+#endif
 
 	if (priv->errata)
 		dev_info(dev, "enabled errata workarounds, flags: 0x%x\n",
-- 
1.7.11.7
