From: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Subject: [PATCH] gianfar: Enable eTSEC-106 erratum w/a for MPC8548E Rev2
Date: Thu, 3 Mar 2016 09:07:51 +0900
Message-ID: <20160303.090751.336624849.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Claudiu Manoil <claudiu.manoil@freescale.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms2.toshiba-tops.co.jp ([61.200.21.4]:54697 "EHLO
	dmz-ms2.toshiba-tops.co.jp" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753739AbcCCASF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2016 19:18:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable workaround for MPC8548E erratum eTSEC 106,
"Excess delays when transmitting TOE=1 large frames".
(see commit 53fad77375ce "gianfar: Enable eTSEC-20 erratum w/a
for P2020 Rev1")

This erratum was fixed in Rev 3.1.x.

Signed-off-by: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
---
 drivers/net/ethernet/freescale/gianfar.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 2aa7b40..b9ecf19 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -1111,8 +1111,10 @@ static void __gfar_detect_errata_85xx(struct gfar_private *priv)
 
 	if ((SVR_SOC_VER(svr) == SVR_8548) && (SVR_REV(svr) == 0x20))
 		priv->errata |= GFAR_ERRATA_12;
+	/* P2020/P1010 Rev 1; MPC8548 Rev 2 */
 	if (((SVR_SOC_VER(svr) == SVR_P2020) && (SVR_REV(svr) < 0x20)) ||
-	    ((SVR_SOC_VER(svr) == SVR_P2010) && (SVR_REV(svr) < 0x20)))
+	    ((SVR_SOC_VER(svr) == SVR_P2010) && (SVR_REV(svr) < 0x20)) ||
+	    ((SVR_SOC_VER(svr) == SVR_8548) && (SVR_REV(svr) < 0x31)))
 		priv->errata |= GFAR_ERRATA_76; /* aka eTSEC 20 */
 }
 #endif
-- 
