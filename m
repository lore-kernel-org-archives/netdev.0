From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net v2 1/8] net/fsl_pq_mdio: Fix asm/ucc.h compile error for ARM
Date: Tue, 7 Oct 2014 10:44:28 +0300
Message-ID: <1412667875-18225-2-git-send-email-claudiu.manoil@freescale.com>
References: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"Kim Phillips" <kim.phillips@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [157.56.111.105] ([157.56.111.105]:44910 "EHLO
	na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752784AbaJGHrH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 03:47:07 -0400
In-Reply-To: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The UCC specific code included in fsl_pq_mdio.c (with
function calls from asm/ucc.h) is already guarded
by these config options, so this ARM build fix only
provides consistency with the rest UCC specific code.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
v2 - used IS_ENABLED() instead of 2 ifdef's

 drivers/net/ethernet/freescale/fsl_pq_mdio.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 583e71a..32136f0 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -28,7 +28,9 @@
 #include <linux/of_device.h>
 
 #include <asm/io.h>
+#if IS_ENABLED(CONFIG_UCC_GETH)
 #include <asm/ucc.h>	/* for ucc_set_qe_mux_mii_mng() */
+#endif
 
 #include "gianfar.h"
 
-- 
1.7.11.7
