From: domen@coderock.org
Subject: [patch 1/1] net/3c59x: module_param conversions
Date: Sat, 25 Dec 2004 15:15:06 +0100
Message-ID: <20041225141457.00AB84DC0B3@golobica.uni-mb.si>
Cc: netdev@oss.sgi.com, domen@coderock.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Convert 3c59x.c to new module parameter api.
Variables are moved before module_param*.

Compile and run tested.

Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/3c59x.c |   72 ++++++++++++++++++++++---------------------
 1 files changed, 37 insertions(+), 35 deletions(-)

diff -puN drivers/net/3c59x.c~module_param-drivers_net_3c59x.c drivers/net/3c59x.c
--- kj/drivers/net/3c59x.c~module_param-drivers_net_3c59x.c	2004-12-25 01:35:27.000000000 +0100
+++ kj-domen/drivers/net/3c59x.c	2004-12-25 01:35:27.000000000 +0100
@@ -273,26 +273,48 @@ static int vortex_debug = 1;
 static char version[] __devinitdata =
 DRV_NAME ": Donald Becker and others. www.scyld.com/network/vortex.html\n";
 
+
+/* This driver uses 'options' to pass the media type, full-duplex flag, etc. */
+/* Option count limit only -- unlimited interfaces are supported. */
+#define MAX_UNITS 8
+static int options[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1,};
+static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+static int hw_checksums[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+static int flow_ctrl[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+static int enable_wol[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
+static int global_options = -1;
+static int global_full_duplex = -1;
+static int global_enable_wol = -1;
+
+/* #define dev_alloc_skb dev_alloc_skb_debug */
+
+/* Variables to work-around the Compaq PCI BIOS32 problem. */
+static int compaq_ioaddr, compaq_irq, compaq_device_id = 0x5900;
+static struct net_device *compaq_net_device;
+
+static int vortex_cards_found;
+
+
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("3Com 3c59x/3c9xx ethernet driver "
 					DRV_VERSION " " DRV_RELDATE);
 MODULE_LICENSE("GPL");
 
-MODULE_PARM(debug, "i");
-MODULE_PARM(global_options, "i");
-MODULE_PARM(options, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(global_full_duplex, "i");
-MODULE_PARM(full_duplex, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(hw_checksums, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(flow_ctrl, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(global_enable_wol, "i");
-MODULE_PARM(enable_wol, "1-" __MODULE_STRING(8) "i");
-MODULE_PARM(rx_copybreak, "i");
-MODULE_PARM(max_interrupt_work, "i");
-MODULE_PARM(compaq_ioaddr, "i");
-MODULE_PARM(compaq_irq, "i");
-MODULE_PARM(compaq_device_id, "i");
-MODULE_PARM(watchdog, "i");
+module_param(debug, int, 0644);
+module_param(global_options, int, 0);
+module_param_array(options, int, NULL, 0);
+module_param(global_full_duplex, int, 0);
+module_param_array(full_duplex, int, NULL, 0);
+module_param_array(hw_checksums, int, NULL, 0);
+module_param_array(flow_ctrl, int, NULL, 0);
+module_param(global_enable_wol, int, 0);
+module_param_array(enable_wol, int, NULL, 0);
+module_param(rx_copybreak, int, 0);
+module_param(max_interrupt_work, int, 0);
+module_param(compaq_ioaddr, int, 0);
+module_param(compaq_irq, int, 0);
+module_param(compaq_device_id, int, 0);
+module_param(watchdog, int, 0);
 MODULE_PARM_DESC(debug, "3c59x debug level (0-6)");
 MODULE_PARM_DESC(options, "3c59x: Bits 0-3: media type, bit 4: bus mastering, bit 9: full duplex");
 MODULE_PARM_DESC(global_options, "3c59x: same as options, but applies to all NICs if options is unset");
@@ -909,26 +931,6 @@ static void acpi_set_WOL(struct net_devi
 static struct ethtool_ops vortex_ethtool_ops;
 static void set_8021q_mode(struct net_device *dev, int enable);
 
-
-/* This driver uses 'options' to pass the media type, full-duplex flag, etc. */
-/* Option count limit only -- unlimited interfaces are supported. */
-#define MAX_UNITS 8
-static int options[MAX_UNITS] = { -1, -1, -1, -1, -1, -1, -1, -1,};
-static int full_duplex[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int hw_checksums[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int flow_ctrl[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int enable_wol[MAX_UNITS] = {-1, -1, -1, -1, -1, -1, -1, -1};
-static int global_options = -1;
-static int global_full_duplex = -1;
-static int global_enable_wol = -1;
-
-/* #define dev_alloc_skb dev_alloc_skb_debug */
-
-/* Variables to work-around the Compaq PCI BIOS32 problem. */
-static int compaq_ioaddr, compaq_irq, compaq_device_id = 0x5900;
-static struct net_device *compaq_net_device;
-
-static int vortex_cards_found;
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_vortex(struct net_device *dev)
_
