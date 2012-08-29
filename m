From: Timur Tabi <timur@freescale.com>
Subject: [PATCH 7/7] [v2] net/fsl_pq_mdio: add support for the Fman 1G MDIO controller
Date: Wed, 29 Aug 2012 13:08:03 -0500
Message-ID: <1346263683-3664-7-git-send-email-timur@freescale.com>
References: <1346263683-3664-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co1ehsobe002.messaging.microsoft.com ([216.32.180.185]:13297
	"EHLO co1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754468Ab2H2SIi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 14:08:38 -0400
In-Reply-To: <1346263683-3664-1-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MDIO controller on the Frame Manager (Fman) is compatible with the
QE and Gianfar MDIO controllers, but we don't care about the TBI because
the Ethernet drivers (FMD) take care of programming it.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index ebd4638..c93a056 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -342,6 +342,15 @@ static struct of_device_id fsl_pq_mdio_match[] = {
 		},
 	},
 #endif
+	/* No Kconfig option for Fman support yet */
+	{
+		.compatible = "fsl,fman-mdio",
+		.data = &(struct fsl_pq_mdio_data) {
+			.mii_offset = 0,
+			/* Fman TBI operations are handled elsewhere */
+		},
+	},
+
 	{},
 };
 MODULE_DEVICE_TABLE(of, fsl_pq_mdio_match);
-- 
1.7.3.4
