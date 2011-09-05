From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 2/5] sfc: Use consistent types for interrupt
 coalescing parameters
Date: Mon, 05 Sep 2011 18:41:44 +0100
Message-ID: <1315244504.3028.14.camel@bwh-desktop>
References: <1315231921.3028.11.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>,
	Ripduman Sohan <ripduman.sohan@cl.cam.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59948 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922Ab1IERlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2011 13:41:47 -0400
In-Reply-To: <1315231921.3028.11.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c     |   10 +++++-----
 drivers/net/ethernet/sfc/efx.h     |    4 ++--
 drivers/net/ethernet/sfc/ethtool.c |    3 ++-
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index b6b0e71..097ed8b 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1556,18 +1556,18 @@ static void efx_remove_all(struct efx_nic *efx)
  *
  **************************************************************************/
 
-static unsigned irq_mod_ticks(int usecs, int resolution)
+static unsigned int irq_mod_ticks(unsigned int usecs, unsigned int resolution)
 {
-	if (usecs <= 0)
-		return 0; /* cannot receive interrupts ahead of time :-) */
+	if (usecs == 0)
+		return 0;
 	if (usecs < resolution)
 		return 1; /* never round down to 0 */
 	return usecs / resolution;
 }
 
 /* Set interrupt moderation parameters */
-void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs, int rx_usecs,
-			     bool rx_adaptive)
+void efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
+			     unsigned int rx_usecs, bool rx_adaptive)
 {
 	struct efx_channel *channel;
 	unsigned tx_ticks = irq_mod_ticks(tx_usecs, EFX_IRQ_MOD_RESOLUTION);
diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index b0d1209..8f5acae 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -111,8 +111,8 @@ extern int efx_reset_up(struct efx_nic *efx, enum reset_type method, bool ok);
 
 /* Global */
 extern void efx_schedule_reset(struct efx_nic *efx, enum reset_type type);
-extern void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs,
-				    int rx_usecs, bool rx_adaptive);
+extern void efx_init_irq_moderation(struct efx_nic *efx, unsigned int tx_usecs,
+				    unsigned int rx_usecs, bool rx_adaptive);
 
 /* Dummy PHY ops for PHY drivers */
 extern int efx_port_dummy_op_int(struct efx_nic *efx);
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index 6de2715..dedaa2c 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -625,7 +625,8 @@ static int efx_ethtool_set_coalesce(struct net_device *net_dev,
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_channel *channel;
-	unsigned tx_usecs, rx_usecs, adaptive;
+	unsigned int tx_usecs, rx_usecs;
+	bool adaptive;
 
 	if (coalesce->use_adaptive_tx_coalesce)
 		return -EINVAL;
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
