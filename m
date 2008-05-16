From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 13/16] sfc: Change type of efx_nic::nic_data to struct falcon_nic_data *
Date: Fri, 16 May 2008 21:19:43 +0100
Message-ID: <20080516201943.GF28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53569 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754836AbYEPUUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:20:23 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove redundant casts and variable.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c     |    5 +----
 drivers/net/sfc/net_driver.h |    2 +-
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 475b596..ac14460 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2411,7 +2411,7 @@ int falcon_probe_nic(struct efx_nic *efx)
 
 	/* Allocate storage for hardware specific data */
 	nic_data = kzalloc(sizeof(*nic_data), GFP_KERNEL);
-	efx->nic_data = (void *) nic_data;
+	efx->nic_data = nic_data;
 
 	/* Determine number of ports etc. */
 	rc = falcon_probe_nic_variant(efx);
@@ -2481,13 +2481,10 @@ int falcon_probe_nic(struct efx_nic *efx)
  */
 int falcon_init_nic(struct efx_nic *efx)
 {
-	struct falcon_nic_data *data;
 	efx_oword_t temp;
 	unsigned thresh;
 	int rc;
 
-	data = (struct falcon_nic_data *)efx->nic_data;
-
 	/* Set up the address region register. This is only needed
 	 * for the B0 FPGA, but since we are just pushing in the
 	 * reset defaults this may as well be unconditional. */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index be09180..f4757e1 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -705,7 +705,7 @@ struct efx_nic {
 
 	unsigned n_rx_nodesc_drop_cnt;
 
-	void *nic_data;
+	struct falcon_nic_data *nic_data;
 
 	struct mutex mac_lock;
 	int port_enabled;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
