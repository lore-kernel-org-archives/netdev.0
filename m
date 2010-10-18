From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] sfc: make functions static
Date: Mon, 18 Oct 2010 08:27:31 -0700
Message-ID: <20101018082731.36cd65e4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Steve Hodgson <shodgson@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38671 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755332Ab0JRP1d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 11:27:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make local functions and variable static. Do some rearrangement
of the string table stuff to put it where it gets used.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---

 drivers/net/sfc/efx.c         |   16 +++-------------
 drivers/net/sfc/efx.h         |   10 +---------
 drivers/net/sfc/ethtool.c     |   10 +++++-----
 drivers/net/sfc/falcon_xmac.c |    2 +-
 drivers/net/sfc/mac.h         |    1 -
 drivers/net/sfc/mcdi.c        |    4 ++--
 drivers/net/sfc/mcdi.h        |    2 --
 drivers/net/sfc/mcdi_phy.c    |    3 ++-
 drivers/net/sfc/net_driver.h  |    5 -----
 drivers/net/sfc/nic.c         |    2 +-
 drivers/net/sfc/selftest.c    |   10 ++++++++++
 drivers/net/sfc/siena.c       |    2 +-
 12 files changed, 26 insertions(+), 41 deletions(-)

--- a/drivers/net/sfc/efx.c	2010-10-15 16:26:45.752054196 -0700
+++ b/drivers/net/sfc/efx.c	2010-10-15 16:41:10.902928754 -0700
@@ -68,14 +68,6 @@ const char *efx_loopback_mode_names[] =
 	[LOOPBACK_PHYXS_WS]  	= "PHYXS_WS",
 };
 
-/* Interrupt mode names (see INT_MODE())) */
-const unsigned int efx_interrupt_mode_max = EFX_INT_MODE_MAX;
-const char *efx_interrupt_mode_names[] = {
-	[EFX_INT_MODE_MSIX]   = "MSI-X",
-	[EFX_INT_MODE_MSI]    = "MSI",
-	[EFX_INT_MODE_LEGACY] = "legacy",
-};
-
 const unsigned int efx_reset_type_max = RESET_TYPE_MAX;
 const char *efx_reset_type_names[] = {
 	[RESET_TYPE_INVISIBLE]     = "INVISIBLE",
@@ -128,7 +120,7 @@ static int napi_weight = 64;
  * - Check the on-board hardware monitor;
  * - Poll the link state and reconfigure the hardware as necessary.
  */
-unsigned int efx_monitor_interval = 1 * HZ;
+static unsigned int efx_monitor_interval = 1 * HZ;
 
 /* This controls whether or not the driver will initialise devices
  * with invalid MAC addresses stored in the EEPROM or flash.  If true,
@@ -2180,10 +2172,8 @@ int efx_port_dummy_op_int(struct efx_nic
 	return 0;
 }
 void efx_port_dummy_op_void(struct efx_nic *efx) {}
-void efx_port_dummy_op_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
-{
-}
-bool efx_port_dummy_op_poll(struct efx_nic *efx)
+
+static bool efx_port_dummy_op_poll(struct efx_nic *efx)
 {
 	return false;
 }
--- a/drivers/net/sfc/efx.h	2010-10-15 16:33:49.707120362 -0700
+++ b/drivers/net/sfc/efx.h	2010-10-15 16:38:52.625979128 -0700
@@ -88,10 +88,6 @@ extern int efx_reconfigure_port(struct e
 extern int __efx_reconfigure_port(struct efx_nic *efx);
 
 /* Ethtool support */
-extern int efx_ethtool_get_settings(struct net_device *net_dev,
-				    struct ethtool_cmd *ecmd);
-extern int efx_ethtool_set_settings(struct net_device *net_dev,
-				    struct ethtool_cmd *ecmd);
 extern const struct ethtool_ops efx_ethtool_ops;
 
 /* Reset handling */
@@ -107,9 +103,7 @@ extern void efx_init_irq_moderation(stru
 /* Dummy PHY ops for PHY drivers */
 extern int efx_port_dummy_op_int(struct efx_nic *efx);
 extern void efx_port_dummy_op_void(struct efx_nic *efx);
-extern void
-efx_port_dummy_op_set_id_led(struct efx_nic *efx, enum efx_led_mode mode);
-extern bool efx_port_dummy_op_poll(struct efx_nic *efx);
+
 
 /* MTD */
 #ifdef CONFIG_SFC_MTD
@@ -122,8 +116,6 @@ static inline void efx_mtd_rename(struct
 static inline void efx_mtd_remove(struct efx_nic *efx) {}
 #endif
 
-extern unsigned int efx_monitor_interval;
-
 static inline void efx_schedule_channel(struct efx_channel *channel)
 {
 	netif_vdbg(channel->efx, intr, channel->efx->net_dev,
--- a/drivers/net/sfc/ethtool.c	2010-10-15 16:30:43.840446292 -0700
+++ b/drivers/net/sfc/ethtool.c	2010-10-15 16:33:11.385745045 -0700
@@ -187,8 +187,8 @@ static int efx_ethtool_phys_id(struct ne
 }
 
 /* This must be called with rtnl_lock held. */
-int efx_ethtool_get_settings(struct net_device *net_dev,
-			     struct ethtool_cmd *ecmd)
+static int efx_ethtool_get_settings(struct net_device *net_dev,
+				    struct ethtool_cmd *ecmd)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_link_state *link_state = &efx->link_state;
@@ -211,8 +211,8 @@ int efx_ethtool_get_settings(struct net_
 }
 
 /* This must be called with rtnl_lock held. */
-int efx_ethtool_set_settings(struct net_device *net_dev,
-			     struct ethtool_cmd *ecmd)
+static int efx_ethtool_set_settings(struct net_device *net_dev,
+				    struct ethtool_cmd *ecmd)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	int rc;
@@ -891,7 +891,7 @@ static int efx_ethtool_set_wol(struct ne
 	return efx->type->set_wol(efx, wol->wolopts);
 }
 
-extern int efx_ethtool_reset(struct net_device *net_dev, u32 *flags)
+static int efx_ethtool_reset(struct net_device *net_dev, u32 *flags)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	enum reset_type method;
--- a/drivers/net/sfc/falcon_xmac.c	2010-10-15 16:31:54.590987837 -0700
+++ b/drivers/net/sfc/falcon_xmac.c	2010-10-15 16:32:04.819355160 -0700
@@ -143,7 +143,7 @@ static bool falcon_xmac_link_ok(struct e
 		 efx_mdio_phyxgxs_lane_sync(efx));
 }
 
-void falcon_reconfigure_xmac_core(struct efx_nic *efx)
+static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 {
 	unsigned int max_frame_len;
 	efx_oword_t reg;
--- a/drivers/net/sfc/mcdi.c	2010-10-15 16:32:14.415699761 -0700
+++ b/drivers/net/sfc/mcdi.c	2010-10-15 16:32:24.576064590 -0700
@@ -1093,8 +1093,8 @@ int efx_mcdi_reset_mc(struct efx_nic *ef
 	return rc;
 }
 
-int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
-			    const u8 *mac, int *id_out)
+static int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
+				   const u8 *mac, int *id_out)
 {
 	u8 inbuf[MC_CMD_WOL_FILTER_SET_IN_LEN];
 	u8 outbuf[MC_CMD_WOL_FILTER_SET_OUT_LEN];
--- a/drivers/net/sfc/mcdi_phy.c	2010-10-15 16:32:37.700535811 -0700
+++ b/drivers/net/sfc/mcdi_phy.c	2010-10-15 16:32:49.312952707 -0700
@@ -713,7 +713,8 @@ static int efx_mcdi_phy_run_tests(struct
 	return 0;
 }
 
-const char *efx_mcdi_phy_test_name(struct efx_nic *efx, unsigned int index)
+static const char *efx_mcdi_phy_test_name(struct efx_nic *efx,
+					  unsigned int index)
 {
 	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 
--- a/drivers/net/sfc/net_driver.h	2010-10-15 16:28:56.320581376 -0700
+++ b/drivers/net/sfc/net_driver.h	2010-10-15 16:36:37.289130428 -0700
@@ -387,11 +387,6 @@ extern const unsigned int efx_loopback_m
 #define LOOPBACK_MODE(efx) \
 	STRING_TABLE_LOOKUP((efx)->loopback_mode, efx_loopback_mode)
 
-extern const char *efx_interrupt_mode_names[];
-extern const unsigned int efx_interrupt_mode_max;
-#define INT_MODE(efx) \
-	STRING_TABLE_LOOKUP(efx->interrupt_mode, efx_interrupt_mode)
-
 extern const char *efx_reset_type_names[];
 extern const unsigned int efx_reset_type_max;
 #define RESET_TYPE(type) \
--- a/drivers/net/sfc/nic.c	2010-10-15 16:33:00.257345589 -0700
+++ b/drivers/net/sfc/nic.c	2010-10-15 16:33:09.229667656 -0700
@@ -653,7 +653,7 @@ void efx_nic_eventq_read_ack(struct efx_
 }
 
 /* Use HW to insert a SW defined event */
-void efx_generate_event(struct efx_channel *channel, efx_qword_t *event)
+static void efx_generate_event(struct efx_channel *channel, efx_qword_t *event)
 {
 	efx_oword_t drv_ev_reg;
 
--- a/drivers/net/sfc/siena.c	2010-10-15 16:33:22.902158396 -0700
+++ b/drivers/net/sfc/siena.c	2010-10-15 16:33:34.690581475 -0700
@@ -129,7 +129,7 @@ static int siena_probe_port(struct efx_n
 	return 0;
 }
 
-void siena_remove_port(struct efx_nic *efx)
+static void siena_remove_port(struct efx_nic *efx)
 {
 	efx->phy_op->remove(efx);
 	efx_nic_free_buffer(efx, &efx->stats_buffer);
--- a/drivers/net/sfc/mac.h	2010-10-15 16:37:35.923231638 -0700
+++ b/drivers/net/sfc/mac.h	2010-10-15 16:38:35.625370285 -0700
@@ -15,7 +15,6 @@
 
 extern struct efx_mac_operations falcon_xmac_operations;
 extern struct efx_mac_operations efx_mcdi_mac_operations;
-extern void falcon_reconfigure_xmac_core(struct efx_nic *efx);
 extern int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 			      u32 dma_len, int enable, int clear);
 
--- a/drivers/net/sfc/mcdi.h	2010-10-15 16:39:01.902311312 -0700
+++ b/drivers/net/sfc/mcdi.h	2010-10-15 16:39:14.482761784 -0700
@@ -121,8 +121,6 @@ extern int efx_mcdi_handle_assertion(str
 extern void efx_mcdi_set_id_led(struct efx_nic *efx, enum efx_led_mode mode);
 extern int efx_mcdi_reset_port(struct efx_nic *efx);
 extern int efx_mcdi_reset_mc(struct efx_nic *efx);
-extern int efx_mcdi_wol_filter_set(struct efx_nic *efx, u32 type,
-				   const u8 *mac, int *id_out);
 extern int efx_mcdi_wol_filter_set_magic(struct efx_nic *efx,
 					 const u8 *mac, int *id_out);
 extern int efx_mcdi_wol_filter_get_magic(struct efx_nic *efx, int *id_out);
--- a/drivers/net/sfc/selftest.c	2010-10-15 16:38:07.788373215 -0700
+++ b/drivers/net/sfc/selftest.c	2010-10-15 16:38:32.453256674 -0700
@@ -48,6 +48,16 @@ static const unsigned char payload_sourc
 static const char payload_msg[] =
 	"Hello world! This is an Efx loopback test in progress!";
 
+/* Interrupt mode names */
+static const unsigned int efx_interrupt_mode_max = EFX_INT_MODE_MAX;
+static const char *efx_interrupt_mode_names[] = {
+	[EFX_INT_MODE_MSIX]   = "MSI-X",
+	[EFX_INT_MODE_MSI]    = "MSI",
+	[EFX_INT_MODE_LEGACY] = "legacy",
+};
+#define INT_MODE(efx) \
+	STRING_TABLE_LOOKUP(efx->interrupt_mode, efx_interrupt_mode)
+
 /**
  * efx_loopback_state - persistent state during a loopback selftest
  * @flush:		Drop all packets in efx_loopback_rx_packet
