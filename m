From: Carlos =?utf-8?q?Mart=C3=ADn?= <carlos@cmartin.tk>
Subject: [PATCH] ACX: swap netdevice_t for struct net_device
Date: Sun, 15 Jan 2006 00:43:34 +0100
Message-ID: <200601150043.34890.carlos@cmartin.tk>
Reply-To: acx100-devel@lists.sourceforge.net
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_myYyDtaBcleARtD"
Cc: netdev@vger.kernel.org, Denis Vlasenko <vda@ilport.com.ua>
Return-path: <acx100-devel-admin@lists.sourceforge.net>
To: acx100-devel@lists.sourceforge.net
Sender: acx100-devel-admin@lists.sourceforge.net
Errors-To: acx100-devel-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:acx100-devel@lists.sourceforge.net>
List-Help: <mailto:acx100-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/acx100-devel>,
	<mailto:acx100-devel-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=acx100-devel>
List-Id: netdev.vger.kernel.org

--Boundary-00=_myYyDtaBcleARtD
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi,

 Does netdevice_t serve any actual purpose now? It used to be for 2.2/2.4=20
compatibility, but we don't have that anymore.

 Attached patch does a s/netdevice_t/struct net_device/g on all the files t=
hat=20
required it. It's against 20060114

   cmn
=2D-=20
Carlos Mart=C3=ADn       http://www.cmartin.tk

"Erdbeben? Sicherlich etwas, das mit Erdberen zu tun hat." -- me, paraphras=
ed

--Boundary-00=_myYyDtaBcleARtD
Content-Type: text/x-diff;
  charset="utf-8";
  name="acx-kill-netdevice_t.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="acx-kill-netdevice_t.patch"

diff --git a/acx_func.h b/acx_func.h
index fb55e29..6798b79 100644
--- a/acx_func.h
+++ b/acx_func.h
@@ -352,7 +352,7 @@ acx_up_helper(wlandevice_t *priv, const 
 ** IRQ -> acxpci_l_clean_txdesc -> acx_wake_queue
 ** Review carefully all callsites */
 static inline void
-acx_stop_queue(netdevice_t *dev, const char *msg)
+acx_stop_queue(struct net_device *dev, const char *msg)
 {
 	if (netif_queue_stopped(dev))
 		return;
@@ -363,14 +363,14 @@ acx_stop_queue(netdevice_t *dev, const c
 }
 
 static inline int
-acx_queue_stopped(netdevice_t *dev)
+acx_queue_stopped(struct net_device *dev)
 {
 	return netif_queue_stopped(dev);
 }
 
 /*
 static inline void
-acx_start_queue(netdevice_t *dev, const char *msg)
+acx_start_queue(struct net_device *dev, const char *msg)
 {
 	netif_start_queue(dev);
 	if (msg)
@@ -379,7 +379,7 @@ acx_start_queue(netdevice_t *dev, const 
 */
 
 static inline void
-acx_wake_queue(netdevice_t *dev, const char *msg)
+acx_wake_queue(struct net_device *dev, const char *msg)
 {
 	netif_wake_queue(dev);
 	if (msg)
@@ -387,7 +387,7 @@ acx_wake_queue(netdevice_t *dev, const c
 }
 
 static inline void
-acx_carrier_off(netdevice_t *dev, const char *msg)
+acx_carrier_off(struct net_device *dev, const char *msg)
 {
 	netif_carrier_off(dev);
 	if (msg)
@@ -395,7 +395,7 @@ acx_carrier_off(netdevice_t *dev, const 
 }
 
 static inline void
-acx_carrier_on(netdevice_t *dev, const char *msg)
+acx_carrier_on(struct net_device *dev, const char *msg)
 {
 	netif_carrier_on(dev);
 	if (msg)
@@ -601,7 +601,7 @@ void acx_l_update_ratevector(wlandevice_
 void acx_init_task_scheduler(wlandevice_t *priv);
 void acx_schedule_task(wlandevice_t *priv, unsigned int set_flag);
 
-int acx_e_ioctl_old(netdevice_t *dev, struct ifreq *ifr, int cmd);
+int acx_e_ioctl_old(struct net_device *dev, struct ifreq *ifr, int cmd);
 
 client_t *acx_l_sta_list_get(wlandevice_t *priv, const u8 *address);
 void acx_l_sta_list_del(wlandevice_t *priv, client_t *clt);
@@ -634,7 +634,7 @@ const char* acx_get_packet_type_string(u
 #endif
 const char* acx_cmd_status_str(unsigned int state);
 
-int acx_i_start_xmit(struct sk_buff *skb, netdevice_t *dev);
+int acx_i_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
 void great_inquisitor(wlandevice_t *priv);
 
@@ -642,8 +642,8 @@ void acx_s_get_firmware_version(wlandevi
 void acx_display_hardware_details(wlandevice_t *priv);
 
 int acx_e_change_mtu(struct net_device *dev, int mtu);
-struct net_device_stats* acx_e_get_stats(netdevice_t *dev);
-struct iw_statistics* acx_e_get_wireless_stats(netdevice_t *dev);
+struct net_device_stats* acx_e_get_stats(struct net_device *dev);
+struct iw_statistics* acx_e_get_wireless_stats(struct net_device *dev);
 
 int __init acxpci_e_init_module(void);
 int __init acxusb_e_init_module(void);
diff --git a/common.c b/common.c
index 80fe316..b42f296 100644
--- a/common.c
+++ b/common.c
@@ -755,14 +755,14 @@ acx_e_change_mtu(struct net_device *dev,
 ** acx_e_get_stats, acx_e_get_wireless_stats
 */
 struct net_device_stats*
-acx_e_get_stats(netdevice_t *dev)
+acx_e_get_stats(struct net_device *dev)
 {
 	wlandevice_t *priv = netdev_priv(dev);
 	return &priv->stats;
 }
 
 struct iw_statistics*
-acx_e_get_wireless_stats(netdevice_t *dev)
+acx_e_get_wireless_stats(struct net_device *dev)
 {
 	wlandevice_t *priv = netdev_priv(dev);
 	return &priv->wstats;
@@ -2801,7 +2801,7 @@ acx_l_handle_txrate_auto(wlandevice_t *p
 ** Called by network core. Can be called outside of process context.
 */
 int
-acx_i_start_xmit(struct sk_buff *skb, netdevice_t *dev)
+acx_i_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	wlandevice_t *priv = netdev_priv(dev);
 	tx_t *tx;
@@ -3839,7 +3839,7 @@ acx_l_process_data_frame_client(wlandevi
 {
 	const u8 *da, *bssid;
 	const wlan_hdr_t *hdr;
-	netdevice_t *dev = priv->netdev;
+	struct net_device *dev = priv->netdev;
 	int result = NOT_OK;
 
 	FN_ENTER;
@@ -6492,7 +6492,7 @@ acx_s_after_interrupt_recalib(wlandevice
 static void
 acx_e_after_interrupt_task(void *data)
 {
-	netdevice_t *dev = (netdevice_t *) data;
+	struct net_device *dev = (struct net_device *) data;
 	wlandevice_t *priv = netdev_priv(dev);
 
 	FN_ENTER;
diff --git a/pci.c b/pci.c
index 4bc7b58..de0ddb3 100644
--- a/pci.c
+++ b/pci.c
@@ -95,14 +95,14 @@
 
 /***********************************************************************
 */
-static void acxpci_i_tx_timeout(netdevice_t *dev);
+static void acxpci_i_tx_timeout(struct net_device *dev);
 static irqreturn_t acxpci_i_interrupt(int irq, void *dev_id, struct pt_regs *regs);
-static void acxpci_i_set_multicast_list(netdevice_t *dev);
+static void acxpci_i_set_multicast_list(struct net_device *dev);
 
-static int acxpci_e_open(netdevice_t *dev);
-static int acxpci_e_close(netdevice_t *dev);
-static void acxpci_s_up(netdevice_t *dev);
-static void acxpci_s_down(netdevice_t *dev);
+static int acxpci_e_open(struct net_device *dev);
+static int acxpci_e_close(struct net_device *dev);
+static void acxpci_s_up(struct net_device *dev);
+static void acxpci_s_down(struct net_device *dev);
 
 
 /***********************************************************************
@@ -177,7 +177,7 @@ write_flush(wlandevice_t *priv)
 /***********************************************************************
 */
 typedef struct acx_device {
-	netdevice_t *newest;
+	struct net_device *newest;
 } acx_device_t;
 
 /* if this driver was only about PCI devices, then we probably wouldn't
@@ -1965,7 +1965,7 @@ enable_acx_irq(wlandevice_t *priv)
 }
 
 static void
-acxpci_s_up(netdevice_t *dev)
+acxpci_s_up(struct net_device *dev)
 {
 	wlandevice_t *priv = netdev_priv(dev);
 	unsigned long flags;
@@ -2026,7 +2026,7 @@ disable_acx_irq(wlandevice_t *priv)
 }
 
 static void
-acxpci_s_down(netdevice_t *dev)
+acxpci_s_down(struct net_device *dev)
 {
 	wlandevice_t *priv = netdev_priv(dev);
 	unsigned long flags;
@@ -2091,7 +2091,7 @@ acxpci_s_down(netdevice_t *dev)
 **	<0	driver reported error
 */
 static int
-acxpci_e_open(netdevice_t *dev)
+acxpci_e_open(struct net_device *dev)
 {
 	wlandevice_t *priv = netdev_priv(dev);
 	int result = OK;
@@ -2142,7 +2142,7 @@ done:
 **	<0	driver reported error
 */
 static int
-acxpci_e_close(netdevice_t *dev)
+acxpci_e_close(struct net_device *dev)
 {
 	wlandevice_t *priv = netdev_priv(dev);
 
@@ -2182,7 +2182,7 @@ acxpci_e_close(netdevice_t *dev)
 ** Called from network core. Must not sleep!
 */
 static void
-acxpci_i_tx_timeout(netdevice_t *dev)
+acxpci_i_tx_timeout(struct net_device *dev)
 {
 	wlandevice_t *priv = netdev_priv(dev);
 	unsigned long flags;
@@ -2231,7 +2231,7 @@ acxpci_i_tx_timeout(netdevice_t *dev)
 ** FIXME: most likely needs refinement
 */
 static void
-acxpci_i_set_multicast_list(netdevice_t *dev)
+acxpci_i_set_multicast_list(struct net_device *dev)
 {
 	wlandevice_t *priv = netdev_priv(dev);
 	unsigned long flags;
@@ -2512,7 +2512,7 @@ acxpci_i_interrupt(int irq, void *dev_id
 	register u16 irqtype;
 	u16 unmasked;
 
-	priv = (wlandevice_t *) (((netdevice_t *) dev_id)->priv);
+	priv = (wlandevice_t *) (((struct net_device *) dev_id)->priv);
 
 	/* LOCKING: can just spin_lock() since IRQs are disabled anyway.
 	 * I am paranoid */
diff --git a/wlan_compat.h b/wlan_compat.h
index 8a3b399..9a6ea6b 100644
--- a/wlan_compat.h
+++ b/wlan_compat.h
@@ -219,9 +219,6 @@
 #define __WLAN_PRAGMA_PACK1__
 #define __WLAN_PRAGMA_PACKDFLT__
 
-#undef netdevice_t
-typedef struct net_device netdevice_t;
-
 /* Interrupt handler backwards compatibility stuff */
 #ifndef IRQ_NONE
 #define IRQ_NONE

--Boundary-00=_myYyDtaBcleARtD--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
