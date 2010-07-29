From: Sriramakrishnan <srk@ti.com>
Subject: [PATCH 3/3] TI DaVinci EMAC: Fix incorrect reference to EMAC_CTRL registers.
Date: Thu, 29 Jul 2010 18:04:00 +0530
Message-ID: <1280406840-27393-3-git-send-email-srk@ti.com>
References: <1280406840-27393-1-git-send-email-srk@ti.com>
 <1280406840-27393-2-git-send-email-srk@ti.com>
Cc: nsekhar@ti.com, anantgole@ti.com, Sriramakrishnan <srk@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:60480 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756996Ab0G2MeI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jul 2010 08:34:08 -0400
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by arroyo.ext.ti.com (8.13.7/8.13.7) with ESMTP id o6TCY5dp030215
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jul 2010 07:34:07 -0500
In-Reply-To: <1280406840-27393-2-git-send-email-srk@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The EMAC modules control registers vary as per the version of the
EMAC module. EMAC_CTRL_EWCTL,EMAC_CTRL_EWINTTCNT are available
only on EMAC_VERSION_1. The emac_dump_regs() function accesses
these indiscriminately. This patch fixes the issue.

Signed-off-by: Sriramakrishnan <srk@ti.com>
---
 drivers/net/davinci_emac.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 4ee9af6..12196ad 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -565,9 +565,11 @@ static void emac_dump_regs(struct emac_priv *priv)
 
 	/* Print important registers in EMAC */
 	dev_info(emac_dev, "EMAC Basic registers\n");
-	dev_info(emac_dev, "EMAC: EWCTL: %08X, EWINTTCNT: %08X\n",
-		emac_ctrl_read(EMAC_CTRL_EWCTL),
-		emac_ctrl_read(EMAC_CTRL_EWINTTCNT));
+	if (priv->version == EMAC_VERSION_1) {
+		dev_info(emac_dev, "EMAC: EWCTL: %08X, EWINTTCNT: %08X\n",
+			emac_ctrl_read(EMAC_CTRL_EWCTL),
+			emac_ctrl_read(EMAC_CTRL_EWINTTCNT));
+	}
 	dev_info(emac_dev, "EMAC: TXID: %08X %s, RXID: %08X %s\n",
 		emac_read(EMAC_TXIDVER),
 		((emac_read(EMAC_TXCONTROL)) ? "enabled" : "disabled"),
-- 
1.6.2.4

