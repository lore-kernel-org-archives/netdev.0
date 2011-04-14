From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] sfc: make function tables const
Date: Thu, 14 Apr 2011 08:50:12 -0700
Message-ID: <20110414085012.3e45d7b4@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org
To: Steve Hodgson <shodgson@solarflare.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44770 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757904Ab1DNPuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Apr 2011 11:50:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy, mac, and board information structures should be const.
Since tables contain function pointer this improves security
(at least theoretically).

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/sfc/efx.c          |    6 +++---
 drivers/net/sfc/falcon.c       |    4 ++--
 drivers/net/sfc/falcon_xmac.c  |    2 +-
 drivers/net/sfc/mac.h          |    4 ++--
 drivers/net/sfc/mcdi_mac.c     |    2 +-
 drivers/net/sfc/mcdi_phy.c     |    2 +-
 drivers/net/sfc/net_driver.h   |    6 +++---
 drivers/net/sfc/nic.h          |    6 +++---
 drivers/net/sfc/phy.h          |    8 ++++----
 drivers/net/sfc/qt202x_phy.c   |    2 +-
 drivers/net/sfc/siena.c        |    2 +-
 drivers/net/sfc/tenxpress.c    |    2 +-
 drivers/net/sfc/txc43128_phy.c |    2 +-
 13 files changed, 24 insertions(+), 24 deletions(-)

--- a/drivers/net/sfc/efx.c	2011-04-14 08:33:56.762355851 -0700
+++ b/drivers/net/sfc/efx.c	2011-04-14 08:43:13.544925178 -0700
@@ -2245,7 +2245,7 @@ static bool efx_port_dummy_op_poll(struc
 	return false;
 }
 
-static struct efx_phy_operations efx_dummy_phy_operations = {
+static const struct efx_phy_operations efx_dummy_phy_operations = {
 	.init		 = efx_port_dummy_op_int,
 	.reconfigure	 = efx_port_dummy_op_int,
 	.poll		 = efx_port_dummy_op_poll,
@@ -2261,7 +2261,7 @@ static struct efx_phy_operations efx_dum
 /* This zeroes out and then fills in the invariants in a struct
  * efx_nic (including all sub-structures).
  */
-static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
+static int efx_init_struct(struct efx_nic *efx, const struct efx_nic_type *type,
 			   struct pci_dev *pci_dev, struct net_device *net_dev)
 {
 	int i;
@@ -2451,7 +2451,7 @@ static int efx_pci_probe_main(struct efx
 static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 				   const struct pci_device_id *entry)
 {
-	struct efx_nic_type *type = (struct efx_nic_type *) entry->driver_data;
+	const struct efx_nic_type *type = (const struct efx_nic_type *) entry->driver_data;
 	struct net_device *net_dev;
 	struct efx_nic *efx;
 	int i, rc;
--- a/drivers/net/sfc/mcdi_phy.c	2011-04-14 08:34:22.730711864 -0700
+++ b/drivers/net/sfc/mcdi_phy.c	2011-04-14 08:35:55.387770007 -0700
@@ -739,7 +739,7 @@ static const char *efx_mcdi_phy_test_nam
 	return NULL;
 }
 
-struct efx_phy_operations efx_mcdi_phy_ops = {
+const struct efx_phy_operations efx_mcdi_phy_ops = {
 	.probe		= efx_mcdi_phy_probe,
 	.init 	 	= efx_port_dummy_op_int,
 	.reconfigure	= efx_mcdi_phy_reconfigure,
--- a/drivers/net/sfc/net_driver.h	2011-04-14 08:34:34.814856688 -0700
+++ b/drivers/net/sfc/net_driver.h	2011-04-14 08:40:03.118873109 -0700
@@ -773,10 +773,10 @@ struct efx_nic {
 
 	struct efx_buffer stats_buffer;
 
-	struct efx_mac_operations *mac_op;
+	const struct efx_mac_operations *mac_op;
 
 	unsigned int phy_type;
-	struct efx_phy_operations *phy_op;
+	const struct efx_phy_operations *phy_op;
 	void *phy_data;
 	struct mdio_if_info mdio;
 	unsigned int mdio_bus;
@@ -897,7 +897,7 @@ struct efx_nic_type {
 	void (*resume_wol)(struct efx_nic *efx);
 	int (*test_registers)(struct efx_nic *efx);
 	int (*test_nvram)(struct efx_nic *efx);
-	struct efx_mac_operations *default_mac_ops;
+	const struct efx_mac_operations *default_mac_ops;
 
 	int revision;
 	unsigned int mem_map_size;
--- a/drivers/net/sfc/phy.h	2011-04-14 08:34:45.574982389 -0700
+++ b/drivers/net/sfc/phy.h	2011-04-14 08:35:08.507246412 -0700
@@ -13,14 +13,14 @@
 /****************************************************************************
  * 10Xpress (SFX7101) PHY
  */
-extern struct efx_phy_operations falcon_sfx7101_phy_ops;
+extern const struct efx_phy_operations falcon_sfx7101_phy_ops;
 
 extern void tenxpress_set_id_led(struct efx_nic *efx, enum efx_led_mode mode);
 
 /****************************************************************************
  * AMCC/Quake QT202x PHYs
  */
-extern struct efx_phy_operations falcon_qt202x_phy_ops;
+extern const struct efx_phy_operations falcon_qt202x_phy_ops;
 
 /* These PHYs provide various H/W control states for LEDs */
 #define QUAKE_LED_LINK_INVAL	(0)
@@ -39,7 +39,7 @@ extern void falcon_qt202x_set_led(struct
 /****************************************************************************
 * Transwitch CX4 retimer
 */
-extern struct efx_phy_operations falcon_txc_phy_ops;
+extern const struct efx_phy_operations falcon_txc_phy_ops;
 
 #define TXC_GPIO_DIR_INPUT	0
 #define TXC_GPIO_DIR_OUTPUT	1
@@ -50,7 +50,7 @@ extern void falcon_txc_set_gpio_val(stru
 /****************************************************************************
  * Siena managed PHYs
  */
-extern struct efx_phy_operations efx_mcdi_phy_ops;
+extern const struct efx_phy_operations efx_mcdi_phy_ops;
 
 extern int efx_mcdi_mdio_read(struct efx_nic *efx, unsigned int bus,
 			      unsigned int prtad, unsigned int devad,
--- a/drivers/net/sfc/qt202x_phy.c	2011-04-14 08:35:21.647395047 -0700
+++ b/drivers/net/sfc/qt202x_phy.c	2011-04-14 08:35:25.715440799 -0700
@@ -449,7 +449,7 @@ static void qt202x_phy_remove(struct efx
 	efx->phy_data = NULL;
 }
 
-struct efx_phy_operations falcon_qt202x_phy_ops = {
+const struct efx_phy_operations falcon_qt202x_phy_ops = {
 	.probe		 = qt202x_phy_probe,
 	.init		 = qt202x_phy_init,
 	.reconfigure	 = qt202x_phy_reconfigure,
--- a/drivers/net/sfc/tenxpress.c	2011-04-14 08:35:29.783486390 -0700
+++ b/drivers/net/sfc/tenxpress.c	2011-04-14 08:35:54.967764761 -0700
@@ -478,7 +478,7 @@ static void sfx7101_set_npage_adv(struct
 			  advertising & ADVERTISED_10000baseT_Full);
 }
 
-struct efx_phy_operations falcon_sfx7101_phy_ops = {
+const struct efx_phy_operations falcon_sfx7101_phy_ops = {
 	.probe		  = tenxpress_phy_probe,
 	.init             = tenxpress_phy_init,
 	.reconfigure      = tenxpress_phy_reconfigure,
--- a/drivers/net/sfc/txc43128_phy.c	2011-04-14 08:35:48.539694644 -0700
+++ b/drivers/net/sfc/txc43128_phy.c	2011-04-14 08:35:52.619739671 -0700
@@ -545,7 +545,7 @@ static void txc43128_get_settings(struct
 	mdio45_ethtool_gset(&efx->mdio, ecmd);
 }
 
-struct efx_phy_operations falcon_txc_phy_ops = {
+const struct efx_phy_operations falcon_txc_phy_ops = {
 	.probe		= txc43128_phy_probe,
 	.init		= txc43128_phy_init,
 	.reconfigure	= txc43128_phy_reconfigure,
--- a/drivers/net/sfc/falcon_xmac.c	2011-04-14 08:38:51.094018275 -0700
+++ b/drivers/net/sfc/falcon_xmac.c	2011-04-14 08:38:57.022090260 -0700
@@ -362,7 +362,7 @@ void falcon_poll_xmac(struct efx_nic *ef
 	falcon_ack_status_intr(efx);
 }
 
-struct efx_mac_operations falcon_xmac_operations = {
+const struct efx_mac_operations falcon_xmac_operations = {
 	.reconfigure	= falcon_reconfigure_xmac,
 	.update_stats	= falcon_update_stats_xmac,
 	.check_fault	= falcon_xmac_check_fault,
--- a/drivers/net/sfc/mac.h	2011-04-14 08:39:27.806461103 -0700
+++ b/drivers/net/sfc/mac.h	2011-04-14 08:39:36.686565988 -0700
@@ -13,8 +13,8 @@
 
 #include "net_driver.h"
 
-extern struct efx_mac_operations falcon_xmac_operations;
-extern struct efx_mac_operations efx_mcdi_mac_operations;
+extern const struct efx_mac_operations falcon_xmac_operations;
+extern const struct efx_mac_operations efx_mcdi_mac_operations;
 extern int efx_mcdi_mac_stats(struct efx_nic *efx, dma_addr_t dma_addr,
 			      u32 dma_len, int enable, int clear);
 
--- a/drivers/net/sfc/mcdi_mac.c	2011-04-14 08:39:00.734136111 -0700
+++ b/drivers/net/sfc/mcdi_mac.c	2011-04-14 08:39:06.630207635 -0700
@@ -138,7 +138,7 @@ static bool efx_mcdi_mac_check_fault(str
 }
 
 
-struct efx_mac_operations efx_mcdi_mac_operations = {
+const struct efx_mac_operations efx_mcdi_mac_operations = {
 	.reconfigure	= efx_mcdi_mac_reconfigure,
 	.update_stats	= efx_port_dummy_op_void,
 	.check_fault 	= efx_mcdi_mac_check_fault,
--- a/drivers/net/sfc/falcon.c	2011-04-14 08:43:16.856958923 -0700
+++ b/drivers/net/sfc/falcon.c	2011-04-14 08:43:26.809060907 -0700
@@ -1703,7 +1703,7 @@ static int falcon_set_wol(struct efx_nic
  **************************************************************************
  */
 
-struct efx_nic_type falcon_a1_nic_type = {
+const struct efx_nic_type falcon_a1_nic_type = {
 	.probe = falcon_probe_nic,
 	.remove = falcon_remove_nic,
 	.init = falcon_init_nic,
@@ -1744,7 +1744,7 @@ struct efx_nic_type falcon_a1_nic_type =
 	.reset_world_flags = ETH_RESET_IRQ,
 };
 
-struct efx_nic_type falcon_b0_nic_type = {
+const struct efx_nic_type falcon_b0_nic_type = {
 	.probe = falcon_probe_nic,
 	.remove = falcon_remove_nic,
 	.init = falcon_init_nic,
--- a/drivers/net/sfc/nic.h	2011-04-14 08:43:37.417167767 -0700
+++ b/drivers/net/sfc/nic.h	2011-04-14 08:43:50.801302635 -0700
@@ -150,9 +150,9 @@ struct siena_nic_data {
 	int wol_filter_id;
 };
 
-extern struct efx_nic_type falcon_a1_nic_type;
-extern struct efx_nic_type falcon_b0_nic_type;
-extern struct efx_nic_type siena_a0_nic_type;
+extern const struct efx_nic_type falcon_a1_nic_type;
+extern const struct efx_nic_type falcon_b0_nic_type;
+extern const struct efx_nic_type siena_a0_nic_type;
 
 /**************************************************************************
  *
--- a/drivers/net/sfc/siena.c	2011-04-14 08:43:55.377348789 -0700
+++ b/drivers/net/sfc/siena.c	2011-04-14 08:44:24.561640141 -0700
@@ -581,7 +581,7 @@ static void siena_init_wol(struct efx_ni
  **************************************************************************
  */
 
-struct efx_nic_type siena_a0_nic_type = {
+const struct efx_nic_type siena_a0_nic_type = {
 	.probe = siena_probe_nic,
 	.remove = siena_remove_nic,
 	.init = siena_init_nic,
