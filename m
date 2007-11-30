From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'fixes-jgarzik' branch of wireless-2.6
Date: Thu, 29 Nov 2007 22:29:17 -0500
Message-ID: <20071130032917.GA29165@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2678 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934823AbXK3D3m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 22:29:42 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

A few fixes intended for 2.6.24...

Let me know if there are any problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6.git fixes-jgarzik

---

The following changes since commit d9f8bcbf67a0ee67c8cb0734f003dfe916bb5248:
  Linus Torvalds (1):
        Linux 2.6.24-rc3

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git fixes-jgarzik

David Woodhouse (1):
      libertas: Don't set NETIF_F_IPV6_CSUM in dev->features

Holger Schurig (1):
      libertas: let more than one MAC event through

Joe Perches (1):
      drivers/net/wireless: Add missing "space"

Joonwoo Park (2):
      iwlwifi 3945 Fix race conditional panic.
      iwlwifi 4965 Fix race conditional panic.

Saleem Abdulrasool (1):
      iwlwifi: fix possible NULL dereference in iwl_set_rate()

Stefano Brivio (1):
      b43/b43legacy: fix left-over URLs and ifdefs

Tomas Winkler (1):
      iwlwifi: fix iwl_mac_add_interface handler

 drivers/net/wireless/b43/main.c             |    2 +-
 drivers/net/wireless/b43/phy.c              |    2 +-
 drivers/net/wireless/b43legacy/dma.c        |    2 +-
 drivers/net/wireless/b43legacy/main.c       |    2 +-
 drivers/net/wireless/b43legacy/phy.c        |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c  |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   16 ++++++++++++----
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   13 ++++++++++---
 drivers/net/wireless/libertas/if_cs.c       |    3 ++-
 drivers/net/wireless/libertas/main.c        |    4 ----
 drivers/net/wireless/libertas/wext.c        |    2 +-
 drivers/net/wireless/netwave_cs.c           |    2 +-
 drivers/net/wireless/p54usb.c               |    2 +-
 13 files changed, 33 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index 2b17c1d..b45eecc 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -1566,7 +1566,7 @@ static void b43_release_firmware(struct b43_wldev *dev)
 static void b43_print_fw_helptext(struct b43_wl *wl)
 {
 	b43err(wl, "You must go to "
-	       "http://linuxwireless.org/en/users/Drivers/bcm43xx#devicefirmware "
+	       "http://linuxwireless.org/en/users/Drivers/b43#devicefirmware "
 	       "and download the correct firmware (version 4).\n");
 }
 
diff --git a/drivers/net/wireless/b43/phy.c b/drivers/net/wireless/b43/phy.c
index 3d4ed64..7ff091e 100644
--- a/drivers/net/wireless/b43/phy.c
+++ b/drivers/net/wireless/b43/phy.c
@@ -2214,7 +2214,7 @@ int b43_phy_init_tssi2dbm_table(struct b43_wldev *dev)
 		}
 		dyn_tssi2dbm = kmalloc(64, GFP_KERNEL);
 		if (dyn_tssi2dbm == NULL) {
-			b43err(dev->wl, "Could not allocate memory"
+			b43err(dev->wl, "Could not allocate memory "
 			       "for tssi2dbm table\n");
 			return -ENOMEM;
 		}
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index 8cb3dc4..83161d9 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -996,7 +996,7 @@ int b43legacy_dma_init(struct b43legacy_wldev *dev)
 
 	err = ssb_dma_set_mask(dev->dev, dmamask);
 	if (err) {
-#ifdef BCM43XX_PIO
+#ifdef CONFIG_B43LEGACY_PIO
 		b43legacywarn(dev->wl, "DMA for this device not supported. "
 			"Falling back to PIO\n");
 		dev->__using_pio = 1;
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 3bde1e9..32d5e17 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -1419,7 +1419,7 @@ static void b43legacy_release_firmware(struct b43legacy_wldev *dev)
 static void b43legacy_print_fw_helptext(struct b43legacy_wl *wl)
 {
 	b43legacyerr(wl, "You must go to http://linuxwireless.org/en/users/"
-		     "Drivers/bcm43xx#devicefirmware "
+		     "Drivers/b43#devicefirmware "
 		     "and download the correct firmware (version 3).\n");
 }
 
diff --git a/drivers/net/wireless/b43legacy/phy.c b/drivers/net/wireless/b43legacy/phy.c
index 22a4b3d..491e518 100644
--- a/drivers/net/wireless/b43legacy/phy.c
+++ b/drivers/net/wireless/b43legacy/phy.c
@@ -2020,7 +2020,7 @@ int b43legacy_phy_init_tssi2dbm_table(struct b43legacy_wldev *dev)
 			phy->idle_tssi = 62;
 		dyn_tssi2dbm = kmalloc(64, GFP_KERNEL);
 		if (dyn_tssi2dbm == NULL) {
-			b43legacyerr(dev->wl, "Could not allocate memory"
+			b43legacyerr(dev->wl, "Could not allocate memory "
 			       "for tssi2dbm table\n");
 			return -ENOMEM;
 		}
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index b37f1e3..af3de33 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -2149,7 +2149,7 @@ int bcm43xx_phy_init_tssi2dbm_table(struct bcm43xx_private *bcm)
 		}
 		dyn_tssi2dbm = kmalloc(64, GFP_KERNEL);
 		if (dyn_tssi2dbm == NULL) {
-			printk(KERN_ERR PFX "Could not allocate memory"
+			printk(KERN_ERR PFX "Could not allocate memory "
 					    "for tssi2dbm table\n");
 			return -ENOMEM;
 		}
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 465da4f..4bdf237 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -2915,6 +2915,10 @@ static void iwl_set_rate(struct iwl_priv *priv)
 	int i;
 
 	hw = iwl_get_hw_mode(priv, priv->phymode);
+	if (!hw) {
+		IWL_ERROR("Failed to set rate: unable to get hw mode\n");
+		return;
+	}
 
 	priv->active_rate = 0;
 	priv->active_rate_basic = 0;
@@ -6936,13 +6940,10 @@ static int iwl_mac_add_interface(struct ieee80211_hw *hw,
 	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_MAC80211("enter: id %d, type %d\n", conf->if_id, conf->type);
-	if (conf->mac_addr)
-		IWL_DEBUG_MAC80211("enter: MAC %s\n",
-				   print_mac(mac, conf->mac_addr));
 
 	if (priv->interface_id) {
 		IWL_DEBUG_MAC80211("leave - interface_id != 0\n");
-		return 0;
+		return -EOPNOTSUPP;
 	}
 
 	spin_lock_irqsave(&priv->lock, flags);
@@ -6951,6 +6952,12 @@ static int iwl_mac_add_interface(struct ieee80211_hw *hw,
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	mutex_lock(&priv->mutex);
+
+	if (conf->mac_addr) {
+		IWL_DEBUG_MAC80211("Set: %s\n", print_mac(mac, conf->mac_addr));
+		memcpy(priv->mac_addr, conf->mac_addr, ETH_ALEN);
+	}
+
 	iwl_set_mode(priv, conf->type);
 
 	IWL_DEBUG_MAC80211("leave\n");
@@ -8270,6 +8277,7 @@ static void iwl_cancel_deferred_work(struct iwl_priv *priv)
 {
 	iwl_hw_cancel_deferred_work(priv);
 
+	cancel_delayed_work_sync(&priv->init_alive_start);
 	cancel_delayed_work(&priv->scan_check);
 	cancel_delayed_work(&priv->alive_start);
 	cancel_delayed_work(&priv->post_associate);
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 9918780..8f85564 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -3003,6 +3003,10 @@ static void iwl_set_rate(struct iwl_priv *priv)
 	int i;
 
 	hw = iwl_get_hw_mode(priv, priv->phymode);
+	if (!hw) {
+		IWL_ERROR("Failed to set rate: unable to get hw mode\n");
+		return;
+	}
 
 	priv->active_rate = 0;
 	priv->active_rate_basic = 0;
@@ -7326,9 +7330,6 @@ static int iwl_mac_add_interface(struct ieee80211_hw *hw,
 	DECLARE_MAC_BUF(mac);
 
 	IWL_DEBUG_MAC80211("enter: id %d, type %d\n", conf->if_id, conf->type);
-	if (conf->mac_addr)
-		IWL_DEBUG_MAC80211("enter: MAC %s\n",
-				   print_mac(mac, conf->mac_addr));
 
 	if (priv->interface_id) {
 		IWL_DEBUG_MAC80211("leave - interface_id != 0\n");
@@ -7341,6 +7342,11 @@ static int iwl_mac_add_interface(struct ieee80211_hw *hw,
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	mutex_lock(&priv->mutex);
+
+	if (conf->mac_addr) {
+		IWL_DEBUG_MAC80211("Set %s\n", print_mac(mac, conf->mac_addr));
+		memcpy(priv->mac_addr, conf->mac_addr, ETH_ALEN);
+	}
 	iwl_set_mode(priv, conf->type);
 
 	IWL_DEBUG_MAC80211("leave\n");
@@ -8864,6 +8870,7 @@ static void iwl_cancel_deferred_work(struct iwl_priv *priv)
 {
 	iwl_hw_cancel_deferred_work(priv);
 
+	cancel_delayed_work_sync(&priv->init_alive_start);
 	cancel_delayed_work(&priv->scan_check);
 	cancel_delayed_work(&priv->alive_start);
 	cancel_delayed_work(&priv->post_associate);
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index ec89dab..ba4fc2b 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -170,7 +170,8 @@ static int if_cs_poll_while_fw_download(struct if_cs_card *card, uint addr, u8 r
 #define IF_CS_H_IC_TX_OVER		0x0001
 #define IF_CS_H_IC_RX_OVER		0x0002
 #define IF_CS_H_IC_DNLD_OVER		0x0004
-#define IF_CS_H_IC_HOST_EVENT		0x0008
+#define IF_CS_H_IC_POWER_DOWN		0x0008
+#define IF_CS_H_IC_HOST_EVENT		0x0010
 #define IF_CS_H_IC_MASK			0x001f
 
 #define IF_CS_H_INT_MASK		0x00000004
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 5ead083..1823b48 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -1165,8 +1165,6 @@ wlan_private *libertas_add_card(void *card, struct device *dmdev)
 #ifdef	WIRELESS_EXT
 	dev->wireless_handlers = (struct iw_handler_def *)&libertas_handler_def;
 #endif
-#define NETIF_F_DYNALLOC 16
-	dev->features |= NETIF_F_DYNALLOC;
 	dev->flags |= IFF_BROADCAST | IFF_MULTICAST;
 	dev->set_multicast_list = libertas_set_multicast_list;
 
@@ -1348,8 +1346,6 @@ int libertas_add_mesh(wlan_private *priv, struct device *dev)
 #ifdef	WIRELESS_EXT
 	mesh_dev->wireless_handlers = (struct iw_handler_def *)&mesh_handler_def;
 #endif
-#define NETIF_F_DYNALLOC 16
-
 	/* Register virtual mesh interface */
 	ret = register_netdev(mesh_dev);
 	if (ret) {
diff --git a/drivers/net/wireless/libertas/wext.c b/drivers/net/wireless/libertas/wext.c
index c6f5aa3..395b788 100644
--- a/drivers/net/wireless/libertas/wext.c
+++ b/drivers/net/wireless/libertas/wext.c
@@ -1528,7 +1528,7 @@ static int wlan_set_encodeext(struct net_device *dev,
 			&& (ext->key_len != KEY_LEN_WPA_TKIP))
 		    || ((alg == IW_ENCODE_ALG_CCMP)
 		        && (ext->key_len != KEY_LEN_WPA_AES))) {
-				lbs_deb_wext("invalid size %d for key of alg"
+				lbs_deb_wext("invalid size %d for key of alg "
 				       "type %d\n",
 				       ext->key_len,
 				       alg);
diff --git a/drivers/net/wireless/netwave_cs.c b/drivers/net/wireless/netwave_cs.c
index 2402cb8..d2fa079 100644
--- a/drivers/net/wireless/netwave_cs.c
+++ b/drivers/net/wireless/netwave_cs.c
@@ -806,7 +806,7 @@ static int netwave_pcmcia_config(struct pcmcia_device *link) {
     for (i = 0; i < 6; i++) 
 	dev->dev_addr[i] = readb(ramBase + NETWAVE_EREG_PA + i);
 
-    printk(KERN_INFO "%s: Netwave: port %#3lx, irq %d, mem %lx"
+    printk(KERN_INFO "%s: Netwave: port %#3lx, irq %d, mem %lx, "
 	   "id %c%c, hw_addr %s\n",
 	   dev->name, dev->base_addr, dev->irq,
 	   (u_long) ramBase,
diff --git a/drivers/net/wireless/p54usb.c b/drivers/net/wireless/p54usb.c
index 755482a..60d286e 100644
--- a/drivers/net/wireless/p54usb.c
+++ b/drivers/net/wireless/p54usb.c
@@ -308,7 +308,7 @@ static int p54u_read_eeprom(struct ieee80211_hw *dev)
 
 	buf = kmalloc(0x2020, GFP_KERNEL);
 	if (!buf) {
-		printk(KERN_ERR "prism54usb: cannot allocate memory for"
+		printk(KERN_ERR "prism54usb: cannot allocate memory for "
 		       "eeprom readback!\n");
 		return -ENOMEM;
 	}
-- 
John W. Linville
linville@tuxdriver.com
