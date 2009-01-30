From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/11] sfc: SFT9001: Enable robust link training
Date: Fri, 30 Jan 2009 03:48:10 +0000
Message-ID: <20090130034810.GC15266@solarflare.com>
References: <20090129.170811.135213740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:51446 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751022AbZA3DsR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 22:48:17 -0500
Content-Disposition: inline
In-Reply-To: <20090129.170811.135213740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Enable a firmware option that appears to be necessary for reliable
operation.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 9ecb77d..19cfc31 100644
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
