From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 02/16] sfc: Removed casts to void
Date: Fri, 16 May 2008 21:14:27 +0100
Message-ID: <20080516201427.GU28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53518 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752648AbYEPUQM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:16:12 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c         |    4 ++--
 drivers/net/sfc/falcon.c      |    2 +-
 drivers/net/sfc/falcon_xmac.c |    4 ++--
 drivers/net/sfc/sfe4001.c     |   14 +++++++-------
 drivers/net/sfc/tenxpress.c   |    2 +-
 5 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 418f2e5..48aae47 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -265,7 +265,7 @@ void efx_process_channel_now(struct efx_channel *channel)
 	napi_disable(&channel->napi_str);
 
 	/* Poll the channel */
-	(void) efx_process_channel(channel, efx->type->evq_size);
+	efx_process_channel(channel, efx->type->evq_size);
 
 	/* Ack the eventq. This may cause an interrupt to be generated
 	 * when they are reenabled */
@@ -1688,7 +1688,7 @@ static int efx_reset(struct efx_nic *efx)
 	if (method == RESET_TYPE_DISABLE) {
 		/* Reinitialise the device anyway so the driver unload sequence
 		 * can talk to the external SRAM */
-		(void) falcon_init_nic(efx);
+		falcon_init_nic(efx);
 		rc = -EIO;
 		goto fail4;
 	}
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index b57cc68..c58f8a3 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -2647,7 +2647,7 @@ void falcon_remove_nic(struct efx_nic *efx)
 
 	falcon_free_buffer(efx, &efx->irq_status);
 
-	(void) falcon_reset_hw(efx, RESET_TYPE_ALL);
+	falcon_reset_hw(efx, RESET_TYPE_ALL);
 
 	/* Release the second function after the reset */
 	if (nic_data->pci_dev2) {
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index a74b793..d2978d4 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -454,7 +454,7 @@ static int falcon_check_xaui_link_up(struct efx_nic *efx)
 
 		EFX_LOG(efx, "%s Clobbering XAUI (%d tries left).\n",
 			__func__, tries);
-		(void) falcon_reset_xaui(efx);
+		falcon_reset_xaui(efx);
 		udelay(200);
 		tries--;
 	}
@@ -572,7 +572,7 @@ int falcon_check_xmac(struct efx_nic *efx)
 	xaui_link_ok = falcon_xaui_link_ok(efx);
 
 	if (EFX_WORKAROUND_5147(efx) && !xaui_link_ok)
-		(void) falcon_reset_xaui(efx);
+		falcon_reset_xaui(efx);
 
 	/* Call the PHY check_hw routine */
 	rc = efx->phy_op->check_hw(efx);
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index 725d1a5..66a0d14 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -116,18 +116,18 @@ void sfe4001_poweroff(struct efx_nic *efx)
 
 	/* Turn off all power rails */
 	out = 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+	efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
 
 	/* Disable port 1 outputs on IO expander */
 	cfg = 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P1_CONFIG, &cfg, 1);
+	efx_i2c_write(i2c, PCA9539, P1_CONFIG, &cfg, 1);
 
 	/* Disable port 0 outputs on IO expander */
 	cfg = 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P0_CONFIG, &cfg, 1);
+	efx_i2c_write(i2c, PCA9539, P0_CONFIG, &cfg, 1);
 
 	/* Clear any over-temperature alert */
-	(void) efx_i2c_read(i2c, MAX6647, RSL, &in, 1);
+	efx_i2c_read(i2c, MAX6647, RSL, &in, 1);
 }
 
 /* The P0_EN_3V3X line on SFE4001 boards (from A2 onward) is connected
@@ -253,14 +253,14 @@ done:
 fail3:
 	/* Turn off all power rails */
 	out = 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
+	efx_i2c_write(i2c, PCA9539, P0_OUT, &out, 1);
 	/* Disable port 1 outputs on IO expander */
 	out = 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P1_CONFIG, &out, 1);
+	efx_i2c_write(i2c, PCA9539, P1_CONFIG, &out, 1);
 fail2:
 	/* Disable port 0 outputs on IO expander */
 	out = 0xff;
-	(void) efx_i2c_write(i2c, PCA9539, P0_CONFIG, &out, 1);
+	efx_i2c_write(i2c, PCA9539, P0_CONFIG, &out, 1);
 fail1:
 	return rc;
 }
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index b1cd6de..38e96ed 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -376,7 +376,7 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 	 * perform a special software reset */
 	if ((phy_data->tx_disabled && !efx->tx_disabled) ||
 	    loop_change) {
-		(void) tenxpress_special_reset(efx);
+		tenxpress_special_reset(efx);
 		falcon_reset_xaui(efx);
 	}
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
