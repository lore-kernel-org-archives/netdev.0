From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 16/16] Host AP: Replaced MODULE_PARM with module_param*
Date: Sat, 13 Nov 2004 21:25:43 -0800
Message-ID: <20041114052543.GH14810@jm.kir.nu>
References: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20041108070156.GA1076@jm.kir.nu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


diff -Nru a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
--- a/drivers/net/wireless/hostap/hostap_ap.c	2004-11-13 20:56:53 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ap.c	2004-11-13 20:56:53 -08:00
@@ -18,22 +18,22 @@
 
 static int other_ap_policy[MAX_PARM_DEVICES] = { AP_OTHER_AP_SKIP_ALL,
 						 DEF_INTS };
-MODULE_PARM(other_ap_policy, PARM_MIN_MAX "i");
+module_param_array(other_ap_policy, int, NULL, 0444);
 MODULE_PARM_DESC(other_ap_policy, "Other AP beacon monitoring policy (0-3)");
 
 static int ap_max_inactivity[MAX_PARM_DEVICES] = { AP_MAX_INACTIVITY_SEC,
 						   DEF_INTS };
-MODULE_PARM(ap_max_inactivity, PARM_MIN_MAX "i");
+module_param_array(ap_max_inactivity, int, NULL, 0444);
 MODULE_PARM_DESC(ap_max_inactivity, "AP timeout (in seconds) for station "
 		 "inactivity");
 
 static int ap_bridge_packets[MAX_PARM_DEVICES] = { 1, DEF_INTS };
-MODULE_PARM(ap_bridge_packets, PARM_MIN_MAX "i");
+module_param_array(ap_bridge_packets, int, NULL, 0444);
 MODULE_PARM_DESC(ap_bridge_packets, "Bridge packets directly between "
 		 "stations");
 
 static int autom_ap_wds[MAX_PARM_DEVICES] = { 0, DEF_INTS };
-MODULE_PARM(autom_ap_wds, PARM_MIN_MAX "i");
+module_param_array(autom_ap_wds, int, NULL, 0444);
 MODULE_PARM_DESC(autom_ap_wds, "Add WDS connections to other APs "
 		 "automatically");
 
diff -Nru a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
--- a/drivers/net/wireless/hostap/hostap_cs.c	2004-11-13 20:56:53 -08:00
+++ b/drivers/net/wireless/hostap/hostap_cs.c	2004-11-13 20:56:53 -08:00
@@ -36,14 +36,14 @@
 MODULE_LICENSE("GPL");
 
 
-static unsigned int irq_mask = 0xdeb8;
-MODULE_PARM(irq_mask, "i");
+static int irq_mask = 0xdeb8;
+module_param(irq_mask, int, 0444);
 
 static int irq_list[4] = { -1 };
-MODULE_PARM(irq_list, "1-4i");
+module_param_array(irq_list, int, NULL, 0444);
 
-static int ignore_cis_vcc = 0;
-MODULE_PARM(ignore_cis_vcc, "i");
+static int ignore_cis_vcc;
+module_param(ignore_cis_vcc, int, 0444);
 MODULE_PARM_DESC(ignore_cis_vcc, "Ignore broken CIS VCC entry");
 
 
diff -Nru a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
--- a/drivers/net/wireless/hostap/hostap_hw.c	2004-11-13 20:56:53 -08:00
+++ b/drivers/net/wireless/hostap/hostap_hw.c	2004-11-13 20:56:53 -08:00
@@ -59,43 +59,43 @@
 /* #define final_version */
 
 static int mtu = 1500;
-MODULE_PARM(mtu, "i");
+module_param(mtu, int, 0444);
 MODULE_PARM_DESC(mtu, "Maximum transfer unit");
 
 static int channel[MAX_PARM_DEVICES] = { 3, DEF_INTS };
-MODULE_PARM(channel, PARM_MIN_MAX "i");
+module_param_array(channel, int, NULL, 0444);
 MODULE_PARM_DESC(channel, "Initial channel");
 
-static char *essid[MAX_PARM_DEVICES] = { "test" };
-MODULE_PARM(essid, PARM_MIN_MAX "s");
+static char essid[33] = "test";
+module_param_string(essid, essid, sizeof(essid), 0444);
 MODULE_PARM_DESC(essid, "Host AP's ESSID");
 
 static int iw_mode[MAX_PARM_DEVICES] = { IW_MODE_MASTER, DEF_INTS };
-MODULE_PARM(iw_mode, PARM_MIN_MAX "i");
+module_param_array(iw_mode, int, NULL, 0444);
 MODULE_PARM_DESC(iw_mode, "Initial operation mode");
 
 static int beacon_int[MAX_PARM_DEVICES] = { 100, DEF_INTS };
-MODULE_PARM(beacon_int, PARM_MIN_MAX "i");
+module_param_array(beacon_int, int, NULL, 0444);
 MODULE_PARM_DESC(beacon_int, "Beacon interval (1 = 1024 usec)");
 
 static int dtim_period[MAX_PARM_DEVICES] = { 1, DEF_INTS };
-MODULE_PARM(dtim_period, PARM_MIN_MAX "i");
+module_param_array(dtim_period, int, NULL, 0444);
 MODULE_PARM_DESC(dtim_period, "DTIM period");
 
 #if defined(PRISM2_PCI) && defined(PRISM2_BUS_MASTER)
 static int bus_master_threshold_rx[MAX_PARM_DEVICES] = { 100, DEF_INTS };
-MODULE_PARM(bus_master_threshold_rx, "i");
+module_param_array(bus_master_threshold_rx, int, NULL, 0444);
 MODULE_PARM_DESC(bus_master_threshold_rx, "Packet length threshold for using "
 		 "PCI bus master on RX");
 
 static int bus_master_threshold_tx[MAX_PARM_DEVICES] = { 100, DEF_INTS };
-MODULE_PARM(bus_master_threshold_tx, "i");
+module_param_array(bus_master_threshold_tx, int, NULL, 0444);
 MODULE_PARM_DESC(bus_master_threshold_tx, "Packet length threshold for using "
 		 "PCI bus master on TX");
 #endif /* PRISM2_PCI and PRISM2_BUS_MASTER */
 
-static char *dev_template = "wlan%d";
-MODULE_PARM(dev_template, "s");
+static char dev_template[16] = "wlan%d";
+module_param_string(dev_template, dev_template, sizeof(dev_template), 0444);
 MODULE_PARM_DESC(dev_template, "Prefix for network device name (default: "
 		 "wlan%d)");
 
@@ -3346,9 +3346,8 @@
 		card_idx = 0;
 	local->card_idx = card_idx;
 
-	i = essid[card_idx] == NULL ? 0 : card_idx;
-	len = strlen(essid[i]);
-	memcpy(local->essid, essid[i],
+	len = strlen(essid);
+	memcpy(local->essid, essid,
 	       len > MAX_SSID_LEN ? MAX_SSID_LEN : len);
 	local->essid[MAX_SSID_LEN] = '\0';
 	i = GET_INT_PARM(iw_mode, card_idx);
diff -Nru a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
--- a/drivers/net/wireless/hostap/hostap_plx.c	2004-11-13 20:56:53 -08:00
+++ b/drivers/net/wireless/hostap/hostap_plx.c	2004-11-13 20:56:53 -08:00
@@ -35,8 +35,8 @@
 MODULE_LICENSE("GPL");
 
 
-static int ignore_cis = 0;
-MODULE_PARM(ignore_cis, "i");
+static int ignore_cis;
+module_param(ignore_cis, int, 0444);
 MODULE_PARM_DESC(ignore_cis, "Do not verify manfid information in CIS");
 
 


-- 
Jouni Malinen                                            PGP id EFC895FA
