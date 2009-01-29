From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 03/20] sfc: SFT9001: Enable robust link training
Date: Thu, 29 Jan 2009 19:17:15 +0000
Message-ID: <1233256635.3656.17.camel@achroite>
References: <1233256358.3656.9.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:52508 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751879AbZA2TRQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 14:17:16 -0500
In-Reply-To: <1233256358.3656.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable a firmware option that appears to be necessary for reliable
operation.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 9f5c8b8..0744404 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -67,6 +67,8 @@
 #define PMA_PMD_EXT_CLK312_WIDTH 1
 #define PMA_PMD_EXT_LPOWER_LBN  12
 #define PMA_PMD_EXT_LPOWER_WIDTH 1
+#define PMA_PMD_EXT_ROBUST_LBN	14
+#define PMA_PMD_EXT_ROBUST_WIDTH 1
 #define PMA_PMD_EXT_SSR_LBN	15
 #define PMA_PMD_EXT_SSR_WIDTH	1
 
@@ -284,7 +286,9 @@ static int tenxpress_init(struct efx_nic *efx)
 					 PMA_PMD_XCONTROL_REG);
 		reg |= ((1 << PMA_PMD_EXT_GMII_EN_LBN) |
 			(1 << PMA_PMD_EXT_CLK_OUT_LBN) |
-			(1 << PMA_PMD_EXT_CLK312_LBN));
+			(1 << PMA_PMD_EXT_CLK312_LBN) |
+			(1 << PMA_PMD_EXT_ROBUST_LBN));
+
 		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
 				    PMA_PMD_XCONTROL_REG, reg);
 		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_C22EXT,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

