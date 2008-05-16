From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 15/16] sfc: Added checks for heap allocation failure
Date: Fri, 16 May 2008 21:20:20 +0100
Message-ID: <20080516202020.GH28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53576 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755106AbYEPUUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:20:51 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/selftest.c  |    2 ++
 drivers/net/sfc/tenxpress.c |    2 ++
 drivers/net/sfc/xfp_phy.c   |    2 ++
 3 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index c98f350..3b2de9f 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -517,6 +517,8 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 		state->packet_count = min(1 << (i << 2), state->packet_count);
 		state->skbs = kzalloc(sizeof(state->skbs[0]) *
 				      state->packet_count, GFP_KERNEL);
+		if (!state->skbs)
+			return -ENOMEM;
 		state->flush = 0;
 
 		EFX_LOG(efx, "TX queue %d testing %s loopback with %d "
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 38e96ed..c014606 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -211,6 +211,8 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	int rc = 0;
 
 	phy_data = kzalloc(sizeof(*phy_data), GFP_KERNEL);
+	if (!phy_data)
+		return -ENOMEM;
 	efx->phy_data = phy_data;
 
 	tenxpress_set_state(efx, TENXPRESS_STATUS_NORMAL);
diff --git a/drivers/net/sfc/xfp_phy.c b/drivers/net/sfc/xfp_phy.c
index cf75fab..f3684ad 100644
--- a/drivers/net/sfc/xfp_phy.c
+++ b/drivers/net/sfc/xfp_phy.c
@@ -85,6 +85,8 @@ static int xfp_phy_init(struct efx_nic *efx)
 	int rc;
 
 	phy_data = kzalloc(sizeof(struct xfp_phy_data), GFP_KERNEL);
+	if (!phy_data)
+		return -ENOMEM;
 	efx->phy_data = phy_data;
 
 	EFX_INFO(efx, "XFP: PHY ID reg %x (OUI %x model %x revision"

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
