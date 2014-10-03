From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net 1/8] net/fsl_pq_mdio: Fix asm/ucc.h compile error for ARM
Date: Fri, 3 Oct 2014 19:02:42 +0300
Message-ID: <1412352169-14414-2-git-send-email-claudiu.manoil@freescale.com>
References: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0130.outbound.protection.outlook.com ([65.55.169.130]:15840
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752725AbaJCQl2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Oct 2014 12:41:28 -0400
In-Reply-To: <1412352169-14414-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The UCC specific code included in fsl_pq_mdio.c (with
function calls from asm/ucc.h) is already guarded
by these config options, so this ARM build fix provides
consistency with the rest UCC specific code.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 583e71a..89b3fea 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -28,7 +28,9 @@
 #include <linux/of_device.h>
 
 #include <asm/io.h>
+#if defined(CONFIG_UCC_GETH) || defined(CONFIG_UCC_GETH_MODULE)
 #include <asm/ucc.h>	/* for ucc_set_qe_mux_mii_mng() */
+#endif
 
 #include "gianfar.h"
 
-- 
1.7.11.7
