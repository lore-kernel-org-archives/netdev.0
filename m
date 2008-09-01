From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 48/52] sfc: Stop generating bogus events in tenxpress_check_hw()
Date: Mon, 1 Sep 2008 12:50:01 +0100
Message-ID: <20080901115000.GO7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:35018 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757215AbYIALuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:50:05 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mdio_clause45_links_ok() correctly checks efx_phy_mode_disabled(), so
tenxpress_link_ok() doesn't need to.

From: Steve Hodgson <shodgson@solarflare.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/tenxpress.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 2ad3d8d..d507c93 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -377,8 +377,7 @@ static int tenxpress_phy_check_hw(struct efx_nic *efx)
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
 	bool link_ok;
 
-	link_ok = (phy_data->phy_mode == PHY_MODE_NORMAL &&
-		   tenxpress_link_ok(efx, true));
+	link_ok = tenxpress_link_ok(efx, true);
 
 	if (link_ok != efx->link_up)
 		falcon_xmac_sim_phy_event(efx);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

