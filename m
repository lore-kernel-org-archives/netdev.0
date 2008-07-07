From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-07-07
Date: Mon, 7 Jul 2008 15:58:22 -0400
Message-ID: <20080707195822.GA30335@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TbUS6COTz9TKg@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

I have a few more fixes for 2.6.26 -- they are mostly
practically-one-liners, nothing controversial.

Let me know if there are problems!

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 7f2d38eb7a42bea1c1df51bbdaa2ca0f0bdda07f:
  Oliver Hartkopp (1):
        can: add sanity checks

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Darren Jenkins (1):
      drivers/net/wireless/iwlwifi/iwl-3945.c Fix type issue on 64bit

Firat Birlik (1):
      zd1211rw: add ID for AirTies WUS-201

Guy Cohen (1):
      mac80211: move netif_carrier_on to after ieee80211_bss_info_change_notify

Ivo van Doorn (1):
      mac80211: Only flush workqueue when last interface was removed

John W. Linville (1):
      hostap_cs: correct poor NULL checks in suspend/resume routines

Michael Buesch (1):
      ssb-pcicore: Fix IRQ-vector init on embedded devices

Vladimir Koutny (1):
      mac80211: don't report selected IBSS when not found

 drivers/net/wireless/hostap/hostap_cs.c |   12 ++++++++----
 drivers/net/wireless/iwlwifi/iwl-3945.c |    4 ++--
 drivers/net/wireless/zd1211rw/zd_usb.c  |    1 +
 drivers/ssb/driver_pcicore.c            |    7 +++++++
 net/mac80211/main.c                     |    4 ++--
 net/mac80211/mlme.c                     |   13 +++++++++----
 6 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index 80039a0..3b4e55c 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -777,8 +777,10 @@ static int hostap_cs_suspend(struct pcmcia_device *link)
 	int dev_open = 0;
 	struct hostap_interface *iface = NULL;
 
-	if (dev)
-		iface = netdev_priv(dev);
+	if (!dev)
+		return -ENODEV;
+
+	iface = netdev_priv(dev);
 
 	PDEBUG(DEBUG_EXTRA, "%s: CS_EVENT_PM_SUSPEND\n", dev_info);
 	if (iface && iface->local)
@@ -798,8 +800,10 @@ static int hostap_cs_resume(struct pcmcia_device *link)
 	int dev_open = 0;
 	struct hostap_interface *iface = NULL;
 
-	if (dev)
-		iface = netdev_priv(dev);
+	if (!dev)
+		return -ENODEV;
+
+	iface = netdev_priv(dev);
 
 	PDEBUG(DEBUG_EXTRA, "%s: CS_EVENT_PM_RESUME\n", dev_info);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index f5387a7..55ac850 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -449,7 +449,7 @@ static void iwl3945_dbg_report_frame(struct iwl3945_priv *priv,
 
 	if (print_summary) {
 		char *title;
-		u32 rate;
+		int rate;
 
 		if (hundred)
 			title = "100Frames";
@@ -487,7 +487,7 @@ static void iwl3945_dbg_report_frame(struct iwl3945_priv *priv,
 		 *    but you can hack it to show more, if you'd like to. */
 		if (dataframe)
 			IWL_DEBUG_RX("%s: mhd=0x%04x, dst=0x%02x, "
-				     "len=%u, rssi=%d, chnl=%d, rate=%u, \n",
+				     "len=%u, rssi=%d, chnl=%d, rate=%d, \n",
 				     title, fc, header->addr1[5],
 				     length, rssi, channel, rate);
 		else {
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 8941f5e..6cdad97 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -64,6 +64,7 @@ static struct usb_device_id usb_ids[] = {
 	{ USB_DEVICE(0x079b, 0x0062), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x1582, 0x6003), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x050d, 0x705c), .driver_info = DEVICE_ZD1211B },
+	{ USB_DEVICE(0x083a, 0xe506), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x083a, 0x4505), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x0471, 0x1236), .driver_info = DEVICE_ZD1211B },
 	{ USB_DEVICE(0x13b1, 0x0024), .driver_info = DEVICE_ZD1211B },
diff --git a/drivers/ssb/driver_pcicore.c b/drivers/ssb/driver_pcicore.c
index d28c538..538c570 100644
--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -537,6 +537,13 @@ int ssb_pcicore_dev_irqvecs_enable(struct ssb_pcicore *pc,
 	int err = 0;
 	u32 tmp;
 
+	if (dev->bus->bustype != SSB_BUSTYPE_PCI) {
+		/* This SSB device is not on a PCI host-bus. So the IRQs are
+		 * not routed through the PCI core.
+		 * So we must not enable routing through the PCI core. */
+		goto out;
+	}
+
 	if (!pdev)
 		goto out;
 	bus = pdev->bus;
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 98c0b5e..df0836f 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -530,8 +530,6 @@ static int ieee80211_stop(struct net_device *dev)
 				local->sta_hw_scanning = 0;
 		}
 
-		flush_workqueue(local->hw.workqueue);
-
 		sdata->u.sta.flags &= ~IEEE80211_STA_PRIVACY_INVOKED;
 		kfree(sdata->u.sta.extra_ie);
 		sdata->u.sta.extra_ie = NULL;
@@ -555,6 +553,8 @@ static int ieee80211_stop(struct net_device *dev)
 
 		ieee80211_led_radio(local, 0);
 
+		flush_workqueue(local->hw.workqueue);
+
 		tasklet_disable(&local->tx_pending_tasklet);
 		tasklet_disable(&local->tasklet);
 	}
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 4d2b582..b404537 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -547,15 +547,14 @@ static void ieee80211_set_associated(struct net_device *dev,
 			sdata->bss_conf.ht_bss_conf = &conf->ht_bss_conf;
 		}
 
-		netif_carrier_on(dev);
 		ifsta->flags |= IEEE80211_STA_PREV_BSSID_SET;
 		memcpy(ifsta->prev_bssid, sdata->u.sta.bssid, ETH_ALEN);
 		memcpy(wrqu.ap_addr.sa_data, sdata->u.sta.bssid, ETH_ALEN);
 		ieee80211_sta_send_associnfo(dev, ifsta);
 	} else {
+		netif_carrier_off(dev);
 		ieee80211_sta_tear_down_BA_sessions(dev, ifsta->bssid);
 		ifsta->flags &= ~IEEE80211_STA_ASSOCIATED;
-		netif_carrier_off(dev);
 		ieee80211_reset_erp_info(dev);
 
 		sdata->bss_conf.assoc_ht = 0;
@@ -569,6 +568,10 @@ static void ieee80211_set_associated(struct net_device *dev,
 
 	sdata->bss_conf.assoc = assoc;
 	ieee80211_bss_info_change_notify(sdata, changed);
+
+	if (assoc)
+		netif_carrier_on(dev);
+
 	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
 	wireless_send_event(dev, SIOCGIWAP, &wrqu, NULL);
 }
@@ -3611,8 +3614,10 @@ static int ieee80211_sta_find_ibss(struct net_device *dev,
 	spin_unlock_bh(&local->sta_bss_lock);
 
 #ifdef CONFIG_MAC80211_IBSS_DEBUG
-	printk(KERN_DEBUG "   sta_find_ibss: selected %s current "
-	       "%s\n", print_mac(mac, bssid), print_mac(mac2, ifsta->bssid));
+	if (found)
+		printk(KERN_DEBUG "   sta_find_ibss: selected %s current "
+		       "%s\n", print_mac(mac, bssid),
+		       print_mac(mac2, ifsta->bssid));
 #endif /* CONFIG_MAC80211_IBSS_DEBUG */
 	if (found && memcmp(ifsta->bssid, bssid, ETH_ALEN) != 0 &&
 	    (bss = ieee80211_rx_bss_get(dev, bssid,
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
