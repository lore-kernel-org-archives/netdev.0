From: Jouni Malinen <jkmaline@cc.hut.fi>
Subject: [PATCH wireless-2.6 0/12] Host AP update
Date: Sun, 7 Nov 2004 23:01:57 -0800
Message-ID: <20041108070156.GA1076@jm.kir.nu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jkmaline@cc.hut.fi
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff,

Here's an update to Host AP code in wireless-2.6 tree. This brings in
number of small fixes from my CVS repository. This messages has the
changes in BitKeeper format from bksend and following 12 messages have
the patches one by one as unified diffs.

I have couple of additional patches pending for wireless-2.6 updates
(wireless extensions 17 and 18; changes to PCI API in Linux
2.6.10-rc1). I'll send WE17 and PCI changes once you update
wireless-2.6. WE18 change requires an update to wireless extensions,
so it may need to wait somewhat longer or we could start testing WE18
in wireless-2.6 if that is desired.

I keep getting questions about getting Host AP driver to linux-2.6
tree. What would be needed to make this happen? I would assume this
would be easiest to do this from wireless-2.6 tree once the new
patches are in. Any other changes that would be required to get the
driver in suitable state for merging into Linux 2.6 releases?



You can import this changeset into BK by piping this whole message to:
'| bk receive [path to repository]' or apply the patch as usual.

===================================================================


ChangeSet@1.1873, 2004-11-07 22:28:31-08:00, jkmaline@cc.hut.fi
  Host AP: Fix netif_carrier_off() in non-client modes
  
  Connection status is reported properly only in client modes, so do not
  try to set netif_carrier_off() in non-client modes. Previously, Master
  mode may end up being in state where netif_carrier was left off and
  this may break things like bridging.
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1872, 2004-11-07 22:25:11-08:00, jkmaline@cc.hut.fi
  Host AP: Fix PRISM2_IO_DEBUG
  
  From Mark Glines <mark@glines.org>:
  I just noticed PRISM2_IO_DEBUG doesn't work.  This patch gets it
  working again.  I checked the development CVS snapshot, looks like
  its still broken there.
  
  jkm: in addition, fix the other PRISM2_IO_DEBUG function
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1871, 2004-11-07 22:21:13-08:00, jkmaline@cc.hut.fi
  Host AP: Use void * instead of unsigned long with {read,write}{b,w}
  
  Start using void * instead of unsigned long with {read,write}{b,w} to
  silence compiler warning with Linux 2.6.9-rc2.
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1870, 2004-11-07 22:17:27-08:00, jkmaline@cc.hut.fi
  Host AP: Fix card enabling after firmware download
  
  Fix card enabling after firmware download in case any of the
  netdevs were up when the download was started.
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1869, 2004-11-07 22:13:57-08:00, jkmaline@cc.hut.fi
  Host AP: Do not bridge packets to unauthorized ports
  
  Fix inner-BSS bridge (ap_bridge_packets=1) not to bridge packets to
  unauthorized ports when IEEE 802.1X/WPA is used (i.e., require that
  the STA completes authentication before capturing packets in the inner
  bridge); previously, only association status was used and an attacker
  could have capture packets to any MAC address even without having
  proper credentials for using the network (although, the packets were
  dropped because the controlled port for the STA was unauthorized).
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1868, 2004-11-07 22:10:36-08:00, jkmaline@cc.hut.fi
  Host AP: Fix compilation with PRISM2_NO_STATION_MODES defined.
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1867, 2004-11-07 22:03:38-08:00, jkmaline@cc.hut.fi
  Host AP: Prevent STAs from associating using AP address
  
  Prevent STAs from authenticating with AP address (i.e., spoofing AP
  MAC address). The inner bridge implementation intercepts packets
  before they are passed to Linux net stack, so using AP MAC address
  would prevent AP from seeing the packet properly.
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1866, 2004-11-07 21:59:51-08:00, jkmaline@cc.hut.fi
  Host AP: Fix hw address changing for wifi# interface
   
  Update wifi# interface MAC address when changing addresses. Without
  this, MAC address change does not work correctly with the new
  interface design (wifi#/wlan0#).
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1865, 2004-11-07 21:56:29-08:00, jkmaline@cc.hut.fi
  Host AP: Remove ioctl debug messages
  
  Remove debug message from unsupported ioctls. Some of common ioctls
  triggered these (e.g., SIOCGMIIPHY, SIOCGMIIREG, SIOCSMIIREG,
  SIOCDEVPRIVATE) and filled debug logs with unwanted messages.
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1864, 2004-11-07 21:49:46-08:00, jkmaline@cc.hut.fi
  Host AP: Ignore (Re)AssocResp messages silently
  
  Ignore (Re)AssocResp silently since these are not currently needed but
  are still received when WPA/RSN mode is enabled.
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1863, 2004-11-07 21:34:28-08:00, jkmaline@cc.hut.fi
  Host AP: Fix interface packet counters
  
  Fix wlan#/wifi# interface packet counters (both are supposed to see
  data packets once; wlan# was counting TX twice and wifi# did not count
  TX or RX at all for most cases).
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>

ChangeSet@1.1862, 2004-11-07 20:24:23-08:00, jkmaline@cc.hut.fi
  Host AP: Disable EAPOL TX/RX debug messages
  
  Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>


 hostap.c          |    1 +
 hostap_80211_rx.c |   12 +++++++++++-
 hostap_80211_tx.c |   12 ++++++------
 hostap_ap.c       |   22 +++++++++++++++++++++-
 hostap_ap.h       |    1 +
 hostap_hw.c       |   12 +++++++++---
 hostap_ioctl.c    |   20 +++++++++++---------
 hostap_pci.c      |   22 ++++++++++++----------
 hostap_plx.c      |   19 +++++++++----------
 hostap_wlan.h     |    8 +++++---
 10 files changed, 86 insertions(+), 43 deletions(-)


diff -Nru a/drivers/net/wireless/hostap/hostap.c b/drivers/net/wireless/hostap/hostap.c
--- a/drivers/net/wireless/hostap/hostap.c	2004-11-07 22:34:54 -08:00
+++ b/drivers/net/wireless/hostap/hostap.c	2004-11-07 22:34:54 -08:00
@@ -808,6 +808,7 @@
 		iface = list_entry(ptr, struct hostap_interface, list);
 		memcpy(iface->dev->dev_addr, addr->sa_data, ETH_ALEN);
 	}
+	memcpy(local->dev->dev_addr, addr->sa_data, ETH_ALEN);
 	read_unlock_bh(&local->iface_lock);
 
 	return 0;
diff -Nru a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-07 22:34:54 -08:00
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c	2004-11-07 22:34:54 -08:00
@@ -475,6 +475,13 @@
 		    stype == WLAN_FC_STYPE_PROBE_RESP)) {
 		hostap_rx_sta_beacon(local, skb, stype);
 		return -1;
+	} else if (type == WLAN_FC_TYPE_MGMT &&
+		   (stype == WLAN_FC_STYPE_ASSOC_RESP ||
+		    stype == WLAN_FC_STYPE_REASSOC_RESP)) {
+		/* Ignore (Re)AssocResp silently since these are not currently
+		 * needed but are still received when WPA/RSN mode is enabled.
+		 */
+		return -1;
 	} else {
 		printk(KERN_DEBUG "%s: hostap_rx_frame_mgmt: dropped unhandled"
 		       " management frame in non-Host AP mode (type=%d:%d)\n",
@@ -689,6 +696,9 @@
 	void *sta = NULL;
 	int keyidx = 0;
 
+	iface->stats.rx_packets++;
+	iface->stats.rx_bytes += skb->len;
+
 	/* dev is the master radio device; change this to be the default
 	 * virtual interface (this may be changed to WDS device below) */
 	dev = local->ddev;
@@ -1025,7 +1035,7 @@
 			if (skb2 == NULL)
 				printk(KERN_DEBUG "%s: skb_clone failed for "
 				       "multicast frame\n", dev->name);
-		} else if (hostap_is_sta_assoc(local->ap, dst)) {
+		} else if (hostap_is_sta_authorized(local->ap, dst)) {
 			/* send frame directly to the associated STA using
 			 * wireless media and not passing to higher layers */
 			local->ap->bridged_unicast++;
diff -Nru a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c	2004-11-07 22:34:54 -08:00
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c	2004-11-07 22:34:54 -08:00
@@ -379,7 +379,7 @@
 		printk(KERN_DEBUG "%s: hostap_master_start_xmit: short skb "
 		       "(len=%d)\n", dev->name, skb->len);
 		ret = 0;
-		meta->iface->stats.tx_dropped++;
+		iface->stats.tx_dropped++;
 		goto fail;
 	}
 
@@ -405,13 +405,13 @@
 			hostap_dump_tx_80211(dev->name, skb);
 
 			ret = 0; /* drop packet */
-			meta->iface->stats.tx_dropped++;
+			iface->stats.tx_dropped++;
 			goto fail;
 		}
 		break;
 	case AP_TX_DROP:
 		ret = 0; /* drop packet */
-		meta->iface->stats.tx_dropped++;
+		iface->stats.tx_dropped++;
 		goto fail;
 	case AP_TX_RETRY:
 		goto fail;
@@ -488,11 +488,11 @@
 
 	if (local->func->tx == NULL || local->func->tx(skb, dev)) {
 		ret = 0;
-		meta->iface->stats.tx_dropped++;
+		iface->stats.tx_dropped++;
 	} else {
 		ret = 0;
-		meta->iface->stats.tx_packets++;
-		meta->iface->stats.tx_bytes += skb->len;
+		iface->stats.tx_packets++;
+		iface->stats.tx_bytes += skb->len;
 	}
 
  fail:
diff -Nru a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
--- a/drivers/net/wireless/hostap/hostap_ap.c	2004-11-07 22:34:53 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ap.c	2004-11-07 22:34:53 -08:00
@@ -1329,7 +1329,8 @@
 	status_code = __le16_to_cpu(*pos);
 	pos++;
 
-	if (ap_control_mac_deny(&ap->mac_restrictions, hdr->addr2)) {
+	if (memcmp(dev->dev_addr, hdr->addr2, ETH_ALEN) == 0 ||
+	    ap_control_mac_deny(&ap->mac_restrictions, hdr->addr2)) {
 		txt = "authentication denied";
 		resp = WLAN_STATUS_UNSPECIFIED_FAILURE;
 		goto fail;
@@ -3060,6 +3061,24 @@
 
 
 /* Called only as a tasklet (software IRQ) */
+int hostap_is_sta_authorized(struct ap_data *ap, u8 *sta_addr)
+{
+	struct sta_info *sta;
+	int ret = 0;
+
+	spin_lock(&ap->sta_table_lock);
+	sta = ap_get_sta(ap, sta_addr);
+	if (sta != NULL && (sta->flags & WLAN_STA_ASSOC) && !sta->ap &&
+	    ((sta->flags & WLAN_STA_AUTHORIZED) ||
+	     ap->local->ieee_802_1x == 0))
+		ret = 1;
+	spin_unlock(&ap->sta_table_lock);
+
+	return ret;
+}
+
+
+/* Called only as a tasklet (software IRQ) */
 int hostap_add_sta(struct ap_data *ap, u8 *sta_addr)
 {
 	struct sta_info *sta;
@@ -3218,6 +3237,7 @@
 EXPORT_SYMBOL(hostap_update_sta_ps);
 EXPORT_SYMBOL(hostap_handle_sta_rx);
 EXPORT_SYMBOL(hostap_is_sta_assoc);
+EXPORT_SYMBOL(hostap_is_sta_authorized);
 EXPORT_SYMBOL(hostap_add_sta);
 EXPORT_SYMBOL(hostap_update_rates);
 EXPORT_SYMBOL(hostap_add_wds_links);
diff -Nru a/drivers/net/wireless/hostap/hostap_ap.h b/drivers/net/wireless/hostap/hostap_ap.h
--- a/drivers/net/wireless/hostap/hostap_ap.h	2004-11-07 22:34:54 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ap.h	2004-11-07 22:34:54 -08:00
@@ -255,6 +255,7 @@
 			     struct hostap_ieee80211_hdr *hdr,
 			     struct prism2_crypt_data **crypt, void **sta_ptr);
 int hostap_is_sta_assoc(struct ap_data *ap, u8 *sta_addr);
+int hostap_is_sta_authorized(struct ap_data *ap, u8 *sta_addr);
 int hostap_add_sta(struct ap_data *ap, u8 *sta_addr);
 int hostap_update_rx_stats(struct ap_data *ap,
 			   struct hostap_ieee80211_hdr *hdr,
diff -Nru a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
--- a/drivers/net/wireless/hostap/hostap_hw.c	2004-11-07 22:34:53 -08:00
+++ b/drivers/net/wireless/hostap/hostap_hw.c	2004-11-07 22:34:53 -08:00
@@ -1483,7 +1483,10 @@
 	if (prism2_hw_init2(dev, initial))
 		return 1;
 
-	if (!local->pri_only && !initial) {
+	/* Enable firmware if secondary image is loaded and at least one of the
+	 * netdevices is up. */
+	if (!local->pri_only &&
+	    (initial == 0 || (initial == 2 && local->num_dev_open > 0))) {
 		if (!local->dev_enabled)
 			prism2_callback(local, PRISM2_CALLBACK_ENABLE);
 		local->dev_enabled = 1;
@@ -3396,8 +3399,11 @@
 					   "", dev_template);
 
 	if (local->ddev) {
-		netif_carrier_off(local->dev);
-		netif_carrier_off(local->ddev);
+		if (local->iw_mode == IW_MODE_INFRA ||
+		    local->iw_mode == IW_MODE_ADHOC) {
+			netif_carrier_off(local->dev);
+			netif_carrier_off(local->ddev);
+		}
 		hostap_init_proc(local);
 		hostap_init_ap_proc(local);
 		return 0;
diff -Nru a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
--- a/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-07 22:34:54 -08:00
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c	2004-11-07 22:34:54 -08:00
@@ -597,6 +597,7 @@
 }
 
 
+#ifndef PRISM2_NO_STATION_MODES
 static int hostap_join_ap(struct net_device *dev)
 {
 	struct hostap_interface *iface = dev->priv;
@@ -634,6 +635,7 @@
 
 	return 0;
 }
+#endif /* PRISM2_NO_STATION_MODES */
 
 
 static int prism2_ioctl_siwap(struct net_device *dev,
@@ -1106,6 +1108,13 @@
 	if (double_reset && local->func->reset_port(dev))
 		return -EINVAL;
 
+	if (local->iw_mode != IW_MODE_INFRA && local->iw_mode != IW_MODE_ADHOC)
+	{
+		/* netif_carrier is used only in client modes for now, so make
+		 * sure carrier is on when moving to non-client modes. */
+		netif_carrier_on(local->dev);
+		netif_carrier_on(local->ddev);
+	}
 	return 0;
 }
 
@@ -1586,7 +1595,8 @@
 
 #else /* !PRISM2_NO_STATION_MODES */
 
-static inline int prism2_request_hostscan(struct net_device *dev)
+static inline int prism2_request_hostscan(struct net_device *dev,
+					  u8 *ssid, u8 ssid_len)
 {
 	return -EOPNOTSUPP;
 }
@@ -3452,14 +3462,6 @@
 		break;
 
 	default:
-		if (cmd >= SIOCSIWCOMMIT && cmd <= SIOCGIWPOWER) {
-			/* unsupport wireless extensions get through here - do
-			 * not report these to debug log */
-			ret = -EOPNOTSUPP;
-			break;
-		}
-		printk(KERN_DEBUG "%s unsupported ioctl(0x%04x)\n",
-		       dev->name, cmd);
 		ret = -EOPNOTSUPP;
 		break;
 	}
diff -Nru a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
--- a/drivers/net/wireless/hostap/hostap_pci.c	2004-11-07 22:34:53 -08:00
+++ b/drivers/net/wireless/hostap/hostap_pci.c	2004-11-07 22:34:53 -08:00
@@ -56,7 +56,7 @@
 
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTB, a, v);
-	writeb(v, dev->mem_start + a);
+	writeb(v, (void *) dev->mem_start + a);
 	spin_unlock_irqrestore(&local->lock, flags);
 }
 
@@ -68,7 +68,7 @@
 	u8 v;
 
 	spin_lock_irqsave(&local->lock, flags);
-	v = readb(dev->mem_start + a);
+	v = readb((void *) dev->mem_start + a);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INB, a, v);
 	spin_unlock_irqrestore(&local->lock, flags);
 	return v;
@@ -82,7 +82,7 @@
 
 	spin_lock_irqsave(&local->lock, flags);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_OUTW, a, v);
-	writew(v, dev->mem_start + a);
+	writew(v, (void *) dev->mem_start + a);
 	spin_unlock_irqrestore(&local->lock, flags);
 }
 
@@ -94,7 +94,7 @@
 	u16 v;
 
 	spin_lock_irqsave(&local->lock, flags);
-	v = readw(dev->mem_start + a);
+	v = readw((void *) dev->mem_start + a);
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INW, a, v);
 	spin_unlock_irqrestore(&local->lock, flags);
 	return v;
@@ -109,12 +109,14 @@
 
 #else /* PRISM2_IO_DEBUG */
 
-#define HFA384X_OUTB(v,a) writeb((v), dev->mem_start + (a))
-#define HFA384X_INB(a) (u8) readb(dev->mem_start + (a))
-#define HFA384X_OUTW(v,a) writew((v), dev->mem_start + (a))
-#define HFA384X_INW(a) (u16) readw(dev->mem_start + (a))
-#define HFA384X_OUTW_DATA(v,a) writew(cpu_to_le16(v), dev->mem_start + (a))
-#define HFA384X_INW_DATA(a) (u16) le16_to_cpu(readw(dev->mem_start + (a)))
+#define HFA384X_OUTB(v,a) writeb((v), (void *) dev->mem_start + (a))
+#define HFA384X_INB(a) (u8) readb((void *) dev->mem_start + (a))
+#define HFA384X_OUTW(v,a) writew((v), (void *) dev->mem_start + (a))
+#define HFA384X_INW(a) (u16) readw((void *) dev->mem_start + (a))
+#define HFA384X_OUTW_DATA(v,a) \
+	writew(cpu_to_le16(v), (void *) dev->mem_start + (a))
+#define HFA384X_INW_DATA(a) (u16) \
+	le16_to_cpu(readw((void *) dev->mem_start + (a)))
 
 #endif /* PRISM2_IO_DEBUG */
 
diff -Nru a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
--- a/drivers/net/wireless/hostap/hostap_plx.c	2004-11-07 22:34:53 -08:00
+++ b/drivers/net/wireless/hostap/hostap_plx.c	2004-11-07 22:34:53 -08:00
@@ -247,7 +247,7 @@
 
 	/* Set sreset bit of COR and clear it after hold time */
 
-	if (local->attr_mem == 0) {
+	if (local->attr_mem == NULL) {
 		/* TMD7160 - COR at card's first I/O addr */
 		corsave = inb(local->cor_offset);
 		outb(corsave | COR_SRESET, local->cor_offset);
@@ -271,7 +271,7 @@
 {
 	unsigned char corsave;
 
-	if (local->attr_mem == 0) {
+	if (local->attr_mem == NULL) {
 		/* TMD7160 - COR at card's first I/O addr */
 		corsave = inb(local->cor_offset);
 		outb(corsave | COR_SRESET, local->cor_offset);
@@ -306,7 +306,7 @@
 };
 
 
-static int prism2_plx_check_cis(unsigned long attr_mem, int attr_len,
+static int prism2_plx_check_cis(void *attr_mem, int attr_len,
 				unsigned int *cor_offset,
 				unsigned int *cor_index)
 {
@@ -401,7 +401,7 @@
 	unsigned int pccard_ioaddr, plx_ioaddr;
 	unsigned long pccard_attr_mem;
 	unsigned int pccard_attr_len;
-	unsigned long attr_mem = 0;
+	void *attr_mem = NULL;
 	unsigned int cor_offset, cor_index;
 	u32 reg;
 	local_info_t *local = NULL;
@@ -422,7 +422,7 @@
 
 	if (tmd7160) {
 		/* TMD7160 */
-		attr_mem = 0; /* no access to PC Card attribute memory */
+		attr_mem = NULL; /* no access to PC Card attribute memory */
 
 		printk(KERN_INFO "TMD7160 PCI/PCMCIA adapter: io=0x%x, "
 		       "irq=%d, pccard_io=0x%x\n",
@@ -448,9 +448,8 @@
 			goto fail;
 
 
-		attr_mem = (unsigned long) ioremap(pccard_attr_mem,
-						   pccard_attr_len);
-		if (!attr_mem) {
+		attr_mem = ioremap(pccard_attr_mem, pccard_attr_len);
+		if (attr_mem == NULL) {
 			printk(KERN_ERR "%s: cannot remap attr_mem\n",
 			       dev_info);
 			goto fail;
@@ -532,7 +531,7 @@
 		free_irq(dev->irq, dev);
 
 	if (attr_mem)
-		iounmap((void *) attr_mem);
+		iounmap(attr_mem);
 
 	pci_disable_device(pdev);
 
@@ -550,7 +549,7 @@
 	hfa384x_disable_interrupts(dev);
 
 	if (iface->local->attr_mem)
-		iounmap((void *) iface->local->attr_mem);
+		iounmap(iface->local->attr_mem);
 	if (dev->irq)
 		free_irq(dev->irq, dev);
 
diff -Nru a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
--- a/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-07 22:34:53 -08:00
+++ b/drivers/net/wireless/hostap/hostap_wlan.h	2004-11-07 22:34:54 -08:00
@@ -895,7 +895,7 @@
 #endif /* PRISM2_PCCARD */
 
 #ifdef PRISM2_PLX
-	unsigned long attr_mem;
+	void *attr_mem;
 	unsigned int cor_offset;
 #endif /* PRISM2_PLX */
 
@@ -1006,7 +1006,8 @@
 static inline void prism2_io_debug_add(struct net_device *dev, int cmd,
 				       int reg, int value)
 {
-	local_info_t *local = dev->priv;
+	struct hostap_interface *iface = dev->priv;
+	local_info_t *local = iface->local;
 
 	if (!local->io_debug_enabled)
 		return;
@@ -1023,7 +1024,8 @@
 
 static inline void prism2_io_debug_error(struct net_device *dev, int err)
 {
-	local_info_t *local = dev->priv;
+	struct hostap_interface *iface = dev->priv;
+	local_info_t *local = iface->local;
 	unsigned long flags;
 
 	if (!local->io_debug_enabled)

===================================================================


This BitKeeper patch contains the following changesets:
1.1862..1.1873
## Wrapped with gzip_uu ##


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
CC0QDI4> XV.,,/[_JZ@;F?:[KX0%\!)!K?C_9BI#-M%E    
 

-- 
Jouni Malinen                                            PGP id EFC895FA
