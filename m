From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 23/32] sfc: Add efx_nic_type operation for identity LED
	control
Date: Sat, 28 Nov 2009 03:50:54 +0000
Message-ID: <1259380254.2811.52.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42715 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070AbZK1Duu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:50:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c    |    6 +++---
 drivers/net/sfc/falcon.c     |    7 +++++++
 drivers/net/sfc/net_driver.h |    2 ++
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 0a2b6a4..4f5fda5 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -174,14 +174,14 @@ static int efx_ethtool_phys_id(struct net_device *net_dev, u32 count)
 	struct efx_nic *efx = netdev_priv(net_dev);
 
 	do {
-		falcon_board(efx)->type->set_id_led(efx, EFX_LED_ON);
+		efx->type->set_id_led(efx, EFX_LED_ON);
 		schedule_timeout_interruptible(HZ / 2);
 
-		falcon_board(efx)->type->set_id_led(efx, EFX_LED_OFF);
+		efx->type->set_id_led(efx, EFX_LED_OFF);
 		schedule_timeout_interruptible(HZ / 2);
 	} while (!signal_pending(current) && --count != 0);
 
-	falcon_board(efx)->type->set_id_led(efx, EFX_LED_DEFAULT);
+	efx->type->set_id_led(efx, EFX_LED_DEFAULT);
 	return 0;
 }
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index c689206..544f777 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -3249,6 +3249,11 @@ void falcon_stop_nic_stats(struct efx_nic *efx)
 	spin_unlock_bh(&efx->stats_lock);
 }
 
+static void falcon_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
+{
+	falcon_board(efx)->type->set_id_led(efx, mode);
+}
+
 /**************************************************************************
  *
  * Wake on LAN
@@ -3290,6 +3295,7 @@ struct efx_nic_type falcon_a1_nic_type = {
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
+	.set_id_led = falcon_set_id_led,
 	.push_irq_moderation = falcon_push_irq_moderation,
 	.push_multicast_hash = falcon_push_multicast_hash,
 	.reconfigure_port = falcon_reconfigure_port,
@@ -3329,6 +3335,7 @@ struct efx_nic_type falcon_b0_nic_type = {
 	.update_stats = falcon_update_nic_stats,
 	.start_stats = falcon_start_nic_stats,
 	.stop_stats = falcon_stop_nic_stats,
+	.set_id_led = falcon_set_id_led,
 	.push_irq_moderation = falcon_push_irq_moderation,
 	.push_multicast_hash = falcon_push_multicast_hash,
 	.reconfigure_port = falcon_reconfigure_port,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index e75235b..16db934 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -858,6 +858,7 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
  * @update_stats: Update statistics not provided by event handling
  * @start_stats: Start the regular fetching of statistics
  * @stop_stats: Stop the regular fetching of statistics
+ * @set_id_led: Set state of identifying LED or revert to automatic function
  * @push_irq_moderation: Apply interrupt moderation value
  * @push_multicast_hash: Apply multicast hash table
  * @reconfigure_port: Push loopback/power/txdis changes to the MAC and PHY
@@ -900,6 +901,7 @@ struct efx_nic_type {
 	void (*update_stats)(struct efx_nic *efx);
 	void (*start_stats)(struct efx_nic *efx);
 	void (*stop_stats)(struct efx_nic *efx);
+	void (*set_id_led)(struct efx_nic *efx, enum efx_led_mode mode);
 	void (*push_irq_moderation)(struct efx_channel *channel);
 	void (*push_multicast_hash)(struct efx_nic *efx);
 	int (*reconfigure_port)(struct efx_nic *efx);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

