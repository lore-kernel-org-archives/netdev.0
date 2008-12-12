From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 09/33] sfc: Restore phy_flash_cfg module parameter
Date: Fri, 12 Dec 2008 12:51:48 +0000
Message-ID: <20081212125147.GI10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:34238 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754101AbYLLMvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:51:50 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed for recovery in case a PHY firmware upgrade is aborted.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 127b4da..15ae2fc 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -129,6 +129,10 @@ static unsigned int rss_cpus;
 module_param(rss_cpus, uint, 0444);
 MODULE_PARM_DESC(rss_cpus, "Number of CPUs to use for Receive-Side Scaling");
 
+static int phy_flash_cfg;
+module_param(phy_flash_cfg, int, 0644);
+MODULE_PARM_DESC(phy_flash_cfg, "Set PHYs into reflash mode initially");
+
 /**************************************************************************
  *
  * Utility functions and prototypes
@@ -609,6 +613,9 @@ static int efx_probe_port(struct efx_nic *efx)
 	if (rc)
 		goto err;
 
+	if (phy_flash_cfg)
+		efx->phy_mode = PHY_MODE_SPECIAL;
+
 	/* Sanity check MAC address */
 	if (is_valid_ether_addr(efx->mac_address)) {
 		memcpy(efx->net_dev->dev_addr, efx->mac_address, ETH_ALEN);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
