From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/2] module_param: make bool parameters really bool (net & drivers/net)
Date: Tue, 20 Dec 2011 10:38:01 +1030
Message-ID: <87fwggm7fi.fsf@rustcorp.com.au>
References: <87k45xqvfs.fsf@rustcorp.com.au> <20111215.231517.185391590658983405.davem@davemloft.net> <87ehw1nm9r.fsf@rustcorp.com.au> <20111219.162210.1739976094495078504.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe@perches.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:47621 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751223Ab1LTAKC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Dec 2011 19:10:02 -0500
In-Reply-To: <20111219.162210.1739976094495078504.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

module_param(bool) used to counter-intuitively take an int.  In
fddd5201 (mid-2009) we allowed bool or int/unsigned int using a messy
trick.

It's time to remove the int/unsigned int option.  For this version
it'll simply give a warning, but it'll break next kernel version.

(Thanks to Joe Perches for suggesting coccinelle for 0/1 -> true/false).

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 9341a2d..8a3054b 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -38,15 +38,15 @@ MODULE_ALIAS_LDISC(N_CAIF);
 /*This list is protected by the rtnl lock. */
 static LIST_HEAD(ser_list);
 
-static int ser_loop;
+static bool ser_loop;
 module_param(ser_loop, bool, S_IRUGO);
 MODULE_PARM_DESC(ser_loop, "Run in simulated loopback mode.");
 
-static int ser_use_stx = 1;
+static bool ser_use_stx = true;
 module_param(ser_use_stx, bool, S_IRUGO);
 MODULE_PARM_DESC(ser_use_stx, "STX enabled or not.");
 
-static int ser_use_fcs = 1;
+static bool ser_use_fcs = true;
 
 module_param(ser_use_fcs, bool, S_IRUGO);
 MODULE_PARM_DESC(ser_use_fcs, "FCS enabled or not.");
diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 761057b..96391c3 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -35,7 +35,7 @@ MODULE_DESCRIPTION("CAIF SPI driver");
 /* Returns the number of padding bytes for alignment. */
 #define PAD_POW2(x, pow) ((((x)&((pow)-1))==0) ? 0 : (((pow)-((x)&((pow)-1)))))
 
-static int spi_loop;
+static bool spi_loop;
 module_param(spi_loop, bool, S_IRUGO);
 MODULE_PARM_DESC(spi_loop, "SPI running in loopback mode.");
 
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index f93e2d6..ea2d942 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -63,7 +63,7 @@ MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>");
  * See Documentation/networking/can.txt for details.
  */
 
-static int echo; /* echo testing. Default: 0 (Off) */
+static bool echo; /* echo testing. Default: 0 (Off) */
 module_param(echo, bool, S_IRUGO);
 MODULE_PARM_DESC(echo, "Echo sent frames (for testing). Default: 0 (Off)");
 
diff --git a/drivers/net/ethernet/amd/amd8111e.h b/drivers/net/ethernet/amd/amd8111e.h
index 5bbb53a..8baa352 100644
--- a/drivers/net/ethernet/amd/amd8111e.h
+++ b/drivers/net/ethernet/amd/amd8111e.h
@@ -807,8 +807,8 @@ typedef enum {
 
 static int card_idx;
 static int speed_duplex[MAX_UNITS] = { 0, };
-static int coalesce[MAX_UNITS] = {1,1,1,1,1,1,1,1};
-static int dynamic_ipg[MAX_UNITS] = {0,0,0,0,0,0,0,0};
+static bool coalesce[MAX_UNITS] = { [ 0 ... MAX_UNITS-1] = true };
+static bool dynamic_ipg[MAX_UNITS] = { [ 0 ... MAX_UNITS-1] = false };
 static unsigned int chip_version;
 
 #endif /* _AMD8111E_H */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index fccbe49..7b6b43d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -243,7 +243,7 @@ module_param_array(intr_cnt, uint, NULL, 0644);
 MODULE_PARM_DESC(intr_cnt,
 		 "thresholds 1..3 for queue interrupt packet counters");
 
-static int vf_acls;
+static bool vf_acls;
 
 #ifdef CONFIG_PCI_IOV
 module_param(vf_acls, bool, 0644);
diff --git a/drivers/net/ethernet/dlink/de600.c b/drivers/net/ethernet/dlink/de600.c
index 23a6539..c24fab1 100644
--- a/drivers/net/ethernet/dlink/de600.c
+++ b/drivers/net/ethernet/dlink/de600.c
@@ -59,7 +59,7 @@ static const char version[] = "de600.c: $Revision: 1.41-2.5 $,  Bjorn Ekwall (bj
 
 #include "de600.h"
 
-static unsigned int check_lost = 1;
+static bool check_lost = true;
 module_param(check_lost, bool, 0);
 MODULE_PARM_DESC(check_lost, "If set then check for unplugged de600");
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index abefcc8..e0639eb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -49,7 +49,7 @@ enum {
 extern void __buggy_use_of_MLX4_GET(void);
 extern void __buggy_use_of_MLX4_PUT(void);
 
-static int enable_qos;
+static bool enable_qos;
 module_param(enable_qos, bool, 0444);
 MODULE_PARM_DESC(enable_qos, "Enable Quality of Service support in the HCA (default: off)");
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index e984ded..1209934 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -121,7 +121,7 @@ MODULE_PARM_DESC(log_num_vlan, "Log2 max number of VLANs per ETH port (0-7)");
 /* Log2 max number of VLANs per ETH port (0-7) */
 #define MLX4_LOG_NUM_VLANS 7
 
-static int use_prio;
+static bool use_prio;
 module_param_named(use_prio, use_prio, bool, 0444);
 MODULE_PARM_DESC(use_prio, "Enable steering by VLAN priority on ETH ports "
 		  "(0/1, default 0)");
diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index bcdbdc7..5c4983b 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -35,6 +35,7 @@
 #define DRV_VERSION	"1.5.0"
 #define DRV_RELDATE	"2010-10-09"
 
+#include <linux/types.h>
 
 /* A few user-configurable values.
    These may be modified when a driver module is loaded. */
@@ -55,7 +56,7 @@ static int rx_copybreak;
 
 /* Work-around for broken BIOSes: they are unable to get the chip back out of
    power state D3 so PXE booting fails. bootparam(7): via-rhine.avoid_D3=1 */
-static int avoid_D3;
+static bool avoid_D3;
 
 /*
  * In case you are looking for 'options[]' or 'full_duplex[]', they
@@ -2322,7 +2323,7 @@ static int __init rhine_init(void)
 #endif
 	if (dmi_check_system(rhine_dmi_table)) {
 		/* these BIOSes fail at PXE boot if chip is in D3 */
-		avoid_D3 = 1;
+		avoid_D3 = true;
 		pr_warn("Broken BIOS detected, avoid_D3 enabled\n");
 	}
 	else if (avoid_D3)
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index b45b2cc..64f403d 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -197,7 +197,7 @@ static char *driver_name = DRIVER_NAME;
 
 static int max_baud = 4000000;
 #ifdef USE_PROBE
-static int do_probe = 0;
+static bool do_probe = false;
 #endif
 
 
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 8b1c348..6c95d40 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -79,7 +79,7 @@ MODULE_AUTHOR("Daniele Peri <peri@csai.unipa.it>");
 MODULE_DESCRIPTION("SMC IrCC SIR/FIR controller driver");
 MODULE_LICENSE("GPL");
 
-static int smsc_nopnp = 1;
+static bool smsc_nopnp = true;
 module_param_named(nopnp, smsc_nopnp, bool, 0);
 MODULE_PARM_DESC(nopnp, "Do not use PNP to detect controller settings, defaults to true");
 
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 769f509..908b427 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -55,8 +55,8 @@ static const char driver_name[] = "pegasus";
 #define	BMSR_MEDIA	(BMSR_10HALF | BMSR_10FULL | BMSR_100HALF | \
 			BMSR_100FULL | BMSR_ANEGCAPABLE)
 
-static int loopback;
-static int mii_mode;
+static bool loopback;
+static bool mii_mode;
 static char *devid;
 
 static struct usb_eth_dev usb_dev_id[] = {
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
index 7d62c39..0d5da82 100644
--- a/drivers/net/usb/smsc75xx.c
+++ b/drivers/net/usb/smsc75xx.c
@@ -76,7 +76,7 @@ struct usb_context {
 	struct usbnet *dev;
 };
 
-static int turbo_mode = true;
+static bool turbo_mode = true;
 module_param(turbo_mode, bool, 0644);
 MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
 
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 56f3894..db217ad 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -59,7 +59,7 @@ struct usb_context {
 	struct usbnet *dev;
 };
 
-static int turbo_mode = true;
+static bool turbo_mode = true;
 module_param(turbo_mode, bool, 0644);
 MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
 
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 609c51f..d1c3dce 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -30,7 +30,7 @@
 static int napi_weight = 128;
 module_param(napi_weight, int, 0444);
 
-static int csum = 1, gso = 1;
+static bool csum = true, gso = true;
 module_param(csum, bool, 0444);
 module_param(gso, bool, 0444);
 
diff --git a/drivers/net/wan/sbni.c b/drivers/net/wan/sbni.c
index 783168c..d43f4ef 100644
--- a/drivers/net/wan/sbni.c
+++ b/drivers/net/wan/sbni.c
@@ -155,7 +155,7 @@ static int  emancipate( struct net_device * );
 static const char  version[] =
 	"Granch SBNI12 driver ver 5.0.1  Jun 22 2001  Denis I.Timofeev.\n";
 
-static int  skip_pci_probe	__initdata = 0;
+static bool skip_pci_probe	__initdata = false;
 static int  scandone	__initdata = 0;
 static int  num		__initdata = 0;
 
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 0b4fd05..4f77484 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -362,7 +362,7 @@ static int io=0x238;
 static int txdma=1;
 static int rxdma=3;
 static int irq=5;
-static int slow=0;
+static bool slow=false;
 
 module_param(io, int, 0);
 MODULE_PARM_DESC(io, "The I/O base of the Sealevel card");
diff --git a/drivers/net/wireless/ath/ath5k/ath5k.h b/drivers/net/wireless/ath/ath5k/ath5k.h
index e564e58..c2b2518 100644
--- a/drivers/net/wireless/ath/ath5k/ath5k.h
+++ b/drivers/net/wireless/ath/ath5k/ath5k.h
@@ -914,7 +914,7 @@ enum ath5k_dmasize {
  */
 
 #define AR5K_KEYCACHE_SIZE	8
-extern int ath5k_modparam_nohwcrypt;
+extern bool ath5k_modparam_nohwcrypt;
 
 /***********************\
  HW RELATED DEFINITIONS
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 178a4dd..d366dad 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -68,15 +68,15 @@
 #define CREATE_TRACE_POINTS
 #include "trace.h"
 
-int ath5k_modparam_nohwcrypt;
+bool ath5k_modparam_nohwcrypt;
 module_param_named(nohwcrypt, ath5k_modparam_nohwcrypt, bool, S_IRUGO);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
 
-static int modparam_all_channels;
+static bool modparam_all_channels;
 module_param_named(all_channels, modparam_all_channels, bool, S_IRUGO);
 MODULE_PARM_DESC(all_channels, "Expose all channels the device can use.");
 
-static int modparam_fastchanswitch;
+static bool modparam_fastchanswitch;
 module_param_named(fastchanswitch, modparam_fastchanswitch, bool, S_IRUGO);
 MODULE_PARM_DESC(fastchanswitch, "Enable fast channel switching for AR2413/AR5413 radios.");
 
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index 5518592..db77421 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -48,7 +48,7 @@
 #include "carl9170.h"
 #include "cmd.h"
 
-static int modparam_nohwcrypt;
+static bool modparam_nohwcrypt;
 module_param_named(nohwcrypt, modparam_nohwcrypt, bool, S_IRUGO);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware crypto offload.");
 
diff --git a/drivers/net/wireless/iwmc3200wifi/main.c b/drivers/net/wireless/iwmc3200wifi/main.c
index c3a1b5d..1f868b1 100644
--- a/drivers/net/wireless/iwmc3200wifi/main.c
+++ b/drivers/net/wireless/iwmc3200wifi/main.c
@@ -91,11 +91,11 @@ static struct iwm_conf def_iwm_conf = {
 	.mac_addr		= {0x00, 0x02, 0xb3, 0x01, 0x02, 0x03},
 };
 
-static int modparam_reset;
+static bool modparam_reset;
 module_param_named(reset, modparam_reset, bool, 0644);
 MODULE_PARM_DESC(reset, "reset on firmware errors (default 0 [not reset])");
 
-static int modparam_wimax_enable = 1;
+static bool modparam_wimax_enable = true;
 module_param_named(wimax_enable, modparam_wimax_enable, bool, 0644);
 MODULE_PARM_DESC(wimax_enable, "Enable wimax core (default 1 [wimax enabled])");
 
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index a53fbfe..e75d5c8 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -31,7 +31,7 @@
 #define MWL8K_VERSION	"0.12"
 
 /* Module parameters */
-static unsigned ap_mode_default;
+static bool ap_mode_default;
 module_param(ap_mode_default, bool, 0);
 MODULE_PARM_DESC(ap_mode_default,
 		 "Set to 1 to make ap mode the default instead of sta mode");
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index b52acc4..9fb77d0 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -121,7 +121,7 @@ module_param(orinoco_debug, int, 0644);
 MODULE_PARM_DESC(orinoco_debug, "Debug level");
 #endif
 
-static int suppress_linkstatus; /* = 0 */
+static bool suppress_linkstatus; /* = 0 */
 module_param(suppress_linkstatus, bool, 0644);
 MODULE_PARM_DESC(suppress_linkstatus, "Don't log link status changes");
 
diff --git a/drivers/net/wireless/p54/main.c b/drivers/net/wireless/p54/main.c
index db4d9a0..af2ca1a 100644
--- a/drivers/net/wireless/p54/main.c
+++ b/drivers/net/wireless/p54/main.c
@@ -27,7 +27,7 @@
 #include "p54.h"
 #include "lmac.h"
 
-static int modparam_nohwcrypt;
+static bool modparam_nohwcrypt;
 module_param_named(nohwcrypt, modparam_nohwcrypt, bool, S_IRUGO);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
 MODULE_AUTHOR("Michael Wu <flamingice@sourmilk.net>");
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 53c5f87..de7d41f 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -39,7 +39,7 @@
 /*
  * Allow hardware encryption to be disabled.
  */
-static int modparam_nohwcrypt;
+static bool modparam_nohwcrypt;
 module_param_named(nohwcrypt, modparam_nohwcrypt, bool, S_IRUGO);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
 
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless/rt2x00/rt2800pci.c
index da48c8a..4941a1a 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -50,7 +50,7 @@
 /*
  * Allow hardware encryption to be disabled.
  */
-static int modparam_nohwcrypt = 0;
+static bool modparam_nohwcrypt = false;
 module_param_named(nohwcrypt, modparam_nohwcrypt, bool, S_IRUGO);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
 
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless/rt2x00/rt2800usb.c
index 3778763..b1df1a7 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -45,7 +45,7 @@
 /*
  * Allow hardware encryption to be disabled.
  */
-static int modparam_nohwcrypt;
+static bool modparam_nohwcrypt;
 module_param_named(nohwcrypt, modparam_nohwcrypt, bool, S_IRUGO);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
 
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index bf55b4a..e0c6d11 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -41,7 +41,7 @@
 /*
  * Allow hardware encryption to be disabled.
  */
-static int modparam_nohwcrypt = 0;
+static bool modparam_nohwcrypt = false;
 module_param_named(nohwcrypt, modparam_nohwcrypt, bool, S_IRUGO);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
 
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index cfb19db..1c69c73 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -40,7 +40,7 @@
 /*
  * Allow hardware encryption to be disabled.
  */
-static int modparam_nohwcrypt;
+static bool modparam_nohwcrypt;
 module_param_named(nohwcrypt, modparam_nohwcrypt, bool, S_IRUGO);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
 
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 085dccd..9b7d60c 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1488,7 +1488,7 @@ struct rtl_intf_ops {
 
 struct rtl_mod_params {
 	/* default: 0 = using hardware encryption */
-	int sw_crypto;
+	bool sw_crypto;
 
 	/* default: 0 = DBG_EMERG (0)*/
 	int debug;
diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2cap.h
index 30719eb..72632f1 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -791,7 +791,7 @@ static inline __u8 __ctrl_size(struct l2cap_chan *chan)
 		return L2CAP_ENH_HDR_SIZE - L2CAP_HDR_SIZE;
 }
 
-extern int disable_ertm;
+extern bool disable_ertm;
 
 int l2cap_init_sockets(void);
 void l2cap_cleanup_sockets(void);
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index ad0e31b..07e2cb1 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -235,7 +235,7 @@ extern struct sctp_globals {
 
 	/* Flag to indicate whether computing and verifying checksum
 	 * is disabled. */
-        int checksum_disable;
+        bool checksum_disable;
 
 	/* Threshold for rwnd update SACKS.  Receive buffer shifted this many
 	 * bits is an indicator of when to send and window update SACK.
diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index 42d53b8..a779ec7 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -56,8 +56,8 @@
 
 #define VERSION "1.3"
 
-static int compress_src = 1;
-static int compress_dst = 1;
+static bool compress_src = true;
+static bool compress_dst = true;
 
 static LIST_HEAD(bnep_session_list);
 static DECLARE_RWSEM(bnep_session_sem);
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 35cb56e..918dc09 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -45,7 +45,7 @@
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
 
-static int enable_le;
+static bool enable_le;
 
 /* Handle HCI Event packets */
 
diff --git a/net/bluetooth/hci_sock.c b/net/bluetooth/hci_sock.c
index f6afe3d..78746cf 100644
--- a/net/bluetooth/hci_sock.c
+++ b/net/bluetooth/hci_sock.c
@@ -49,7 +49,7 @@
 #include <net/bluetooth/bluetooth.h>
 #include <net/bluetooth/hci_core.h>
 
-static int enable_mgmt;
+static bool enable_mgmt;
 
 /* ----- HCI socket interface ----- */
 
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index 014fdec..26dc3f6 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -56,7 +56,7 @@
 #include <net/bluetooth/l2cap.h>
 #include <net/bluetooth/smp.h>
 
-int disable_ertm;
+bool disable_ertm;
 
 static u32 l2cap_feat_mask = L2CAP_FEAT_FIXED_CHAN;
 static u8 l2cap_fixed_chan[8] = { L2CAP_FC_L2CAP, };
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index 8743f36..e5ddef0 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -51,8 +51,8 @@
 
 #define VERSION "1.11"
 
-static int disable_cfc;
-static int l2cap_ertm;
+static bool disable_cfc;
+static bool l2cap_ertm;
 static int channel_mtu = -1;
 static unsigned int l2cap_mtu = RFCOMM_MAX_L2CAP_MTU;
 
diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index a324b00..a0d11b8 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -51,7 +51,7 @@
 #include <net/bluetooth/hci_core.h>
 #include <net/bluetooth/sco.h>
 
-static int disable_esco;
+static bool disable_esco;
 
 static const struct proto_ops sco_sock_ops;
 
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 67164bb..f053198 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -29,7 +29,7 @@
 
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
-static int ccid2_debug;
+static bool ccid2_debug;
 #define ccid2_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid2_debug, format, ##a)
 #else
 #define ccid2_pr_debug(format, a...)
@@ -174,7 +174,7 @@ out:
 /*
  *	Congestion window validation (RFC 2861).
  */
-static int ccid2_do_cwv = 1;
+static bool ccid2_do_cwv = true;
 module_param(ccid2_do_cwv, bool, 0644);
 MODULE_PARM_DESC(ccid2_do_cwv, "Perform RFC2861 Congestion Window Validation");
 
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 3d604e1..5606273 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -38,7 +38,7 @@
 #include <asm/unaligned.h>
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
-static int ccid3_debug;
+static bool ccid3_debug;
 #define ccid3_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid3_debug, format, ##a)
 #else
 #define ccid3_pr_debug(format, a...)
diff --git a/net/dccp/ccids/lib/tfrc.c b/net/dccp/ccids/lib/tfrc.c
index 1f94b7e..62b5828 100644
--- a/net/dccp/ccids/lib/tfrc.c
+++ b/net/dccp/ccids/lib/tfrc.c
@@ -8,7 +8,7 @@
 #include "tfrc.h"
 
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
-int tfrc_debug;
+bool tfrc_debug;
 module_param(tfrc_debug, bool, 0644);
 MODULE_PARM_DESC(tfrc_debug, "Enable TFRC debug messages");
 #endif
diff --git a/net/dccp/ccids/lib/tfrc.h b/net/dccp/ccids/lib/tfrc.h
index f8ee3f5..ed698c4 100644
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -21,7 +21,7 @@
 #include "packet_history.h"
 
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
-extern int tfrc_debug;
+extern bool tfrc_debug;
 #define tfrc_pr_debug(format, a...)	DCCP_PR_DEBUG(tfrc_debug, format, ##a)
 #else
 #define tfrc_pr_debug(format, a...)
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 5818032..29d6bb6 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -39,7 +39,7 @@
 						  "%s: " fmt, __func__, ##a)
 
 #ifdef CONFIG_IP_DCCP_DEBUG
-extern int dccp_debug;
+extern bool dccp_debug;
 #define dccp_pr_debug(format, a...)	  DCCP_PR_DEBUG(dccp_debug, format, ##a)
 #define dccp_pr_debug_cat(format, a...)   DCCP_PRINTK(dccp_debug, format, ##a)
 #define dccp_debug(fmt, a...)		  dccp_pr_debug_cat(KERN_DEBUG fmt, ##a)
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index e742f90..7065c0a 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1099,7 +1099,7 @@ module_param(thash_entries, int, 0444);
 MODULE_PARM_DESC(thash_entries, "Number of ehash buckets");
 
 #ifdef CONFIG_IP_DCCP_DEBUG
-int dccp_debug;
+bool dccp_debug;
 module_param(dccp_debug, bool, 0644);
 MODULE_PARM_DESC(dccp_debug, "Enable debug messages");
 
diff --git a/net/ipv4/netfilter/ipt_ULOG.c b/net/ipv4/netfilter/ipt_ULOG.c
index b550815..ba5756d 100644
--- a/net/ipv4/netfilter/ipt_ULOG.c
+++ b/net/ipv4/netfilter/ipt_ULOG.c
@@ -65,7 +65,7 @@ static unsigned int flushtimeout = 10;
 module_param(flushtimeout, uint, 0600);
 MODULE_PARM_DESC(flushtimeout, "buffer flush timeout (hundredths of a second)");
 
-static int nflog = 1;
+static bool nflog = true;
 module_param(nflog, bool, 0400);
 MODULE_PARM_DESC(nflog, "register as internal netfilter logging module");
 
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index c37641e..0e58f09 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -52,7 +52,7 @@ iptable_filter_hook(unsigned int hook, struct sk_buff *skb,
 static struct nf_hook_ops *filter_ops __read_mostly;
 
 /* Default to forward because I got too much mail already. */
-static int forward = NF_ACCEPT;
+static bool forward = NF_ACCEPT;
 module_param(forward, bool, 0000);
 
 static int __net_init iptable_filter_net_init(struct net *net)
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index c9e37c8..a8f6da9 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -44,7 +44,7 @@ ip6table_filter_hook(unsigned int hook, struct sk_buff *skb,
 static struct nf_hook_ops *filter_ops __read_mostly;
 
 /* Default to forward because I got too much mail already. */
-static int forward = NF_ACCEPT;
+static bool forward = NF_ACCEPT;
 module_param(forward, bool, 0000);
 
 static int __net_init ip6table_filter_net_init(struct net *net)
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 7791176..579617c 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -67,7 +67,7 @@ static void *ckey;
 static void *skey;
 
 /* Module parameters */
-static int eth;   /* Use "eth" or "irlan" name for devices */
+static bool eth;   /* Use "eth" or "irlan" name for devices */
 static int access = ACCESS_PEER; /* PEER, DIRECT or HOSTED */
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/netfilter/nf_conntrack_acct.c b/net/netfilter/nf_conntrack_acct.c
index 369df3f..bffa6b0 100644
--- a/net/netfilter/nf_conntrack_acct.c
+++ b/net/netfilter/nf_conntrack_acct.c
@@ -18,7 +18,7 @@
 #include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_conntrack_acct.h>
 
-static int nf_ct_acct __read_mostly;
+static bool nf_ct_acct __read_mostly;
 
 module_param_named(acct, nf_ct_acct, bool, 0644);
 MODULE_PARM_DESC(acct, "Enable connection tracking flow accounting.");
diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 6f5801e..8c5c95c 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -42,7 +42,7 @@ static u_int16_t ports[MAX_PORTS];
 static unsigned int ports_c;
 module_param_array(ports, ushort, &ports_c, 0400);
 
-static int loose;
+static bool loose;
 module_param(loose, bool, 0600);
 
 unsigned int (*nf_nat_ftp_hook)(struct sk_buff *skb,
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 813ad39..722291f 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -42,7 +42,7 @@ static int gkrouted_only __read_mostly = 1;
 module_param(gkrouted_only, int, 0600);
 MODULE_PARM_DESC(gkrouted_only, "only accept calls from gatekeeper");
 
-static int callforward_filter __read_mostly = 1;
+static bool callforward_filter __read_mostly = true;
 module_param(callforward_filter, bool, 0600);
 MODULE_PARM_DESC(callforward_filter, "only create call forwarding expectations "
 				     "if both endpoints are on different sides "
diff --git a/net/netfilter/nf_conntrack_timestamp.c b/net/netfilter/nf_conntrack_timestamp.c
index af7dd31..e8d27af 100644
--- a/net/netfilter/nf_conntrack_timestamp.c
+++ b/net/netfilter/nf_conntrack_timestamp.c
@@ -15,7 +15,7 @@
 #include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_conntrack_timestamp.h>
 
-static int nf_ct_tstamp __read_mostly;
+static bool nf_ct_tstamp __read_mostly;
 
 module_param_named(tstamp, nf_ct_tstamp, bool, 0644);
 MODULE_PARM_DESC(tstamp, "Enable connection tracking flow timestamping.");
