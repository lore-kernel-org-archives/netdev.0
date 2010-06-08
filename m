From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2010-06-08
Date: Tue, 8 Jun 2010 15:02:14 -0400
Message-ID: <20100608190214.GD2422@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is a flurry of fixes intended for 2.6.35.  Most of them are small
and obvious, but there are a few exceptions...I'll include some text from
the iwlwifi pull request:

	We include four fixes. This series includes the overdue 3945 fix to
	internal scanning. The system hang issue fixed by this patch is
	encountered by many people, see:
	http://thread.gmane.org/gmane.linux.kernel/994562
	http://thread.gmane.org/gmane.linux.kernel.wireless.general/51343
	http://thread.gmane.org/gmane.linux.kernel.wireless.general/51614
	http://thread.gmane.org/gmane.linux.kernel/992191/focus=51561
	
	We include a second fix for iwl3945 that enables a workaround to detect
	and
	recover when the command queue, or a transmit queue, becomes stuck.
	Unfortunately users seem to be running into this issue more frequently
	now.
	The bugs related to this issue is noted in the commit message.
	
	A third fix addresses a lockdep warning.
	
	We also include an update to the MAINTAINERS file that we would like to
	include in 2.6.35 since Wey-Yi will be maintainer during this
	kernel's stabilization as well as thereafter.

The iwlwifi bits are bigger than I would like to see, but the fixes
seem worthwhile.  Also included is a revert of a hostap patch that
introduced failures with some devices, a NULL pointer dereference fix,
a memory leak fix, a fix for an incorrect check of function pointer,
a USB ID for p54, and a fix for an association failure 'corner case'
from Johannes.

Please let me know if there are problems!

Thanks,

John
---

The following changes since commit 035320d54758e21227987e3aae0d46e7a04f4ddc:
  Eric Dumazet (1):
        ipmr: dont corrupt lists

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Abhijeet Kolekar (1):
      iwl3945: fix internal scan

Bob Copeland (1):
      ath5k: retain promiscuous setting

Bruno Randolf (1):
      ath5k: fix NULL pointer in antenna configuration

Emmanuel Grumbach (1):
      iwlwifi: move sysfs_create_group to post request firmware

Grazvydas Ignotas (1):
      wl1251: fix a memory leak in probe

Holger Schurig (1):
      mac80211: fix function pointer check

Jason Dravet (1):
      p54usb: Add device ID for Dell WLA3310 USB

Johannes Berg (3):
      mac80211: process station blockack action frames from work
      iwlwifi: add missing rcu_read_lock
      mac80211: fix deauth before assoc

John W. Linville (1):
      Revert "wireless: hostap, fix oops due to early probing interrupt"

Reinette Chatre (1):
      iwl3945: enable stuck queue detection on 3945

Tobias Doerffel (1):
      ath5k: depend on CONFIG_PM_SLEEP for suspend/resume functions

Wey-Yi Guy (1):
      iwlwifi: add name to Maintainers list

Zhu Yi (1):
      wireless: remove my name from the maintainer list

 MAINTAINERS                                 |    5 +-
 drivers/net/wireless/ath/ath5k/base.c       |   12 +-
 drivers/net/wireless/ath/ath5k/phy.c        |    7 +
 drivers/net/wireless/hostap/hostap_hw.c     |    9 -
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c  |   30 +---
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c   |    2 +
 drivers/net/wireless/iwlwifi/iwl-agn.c      |  318 +++++++++++++-------------
 drivers/net/wireless/iwlwifi/iwl-core.c     |   39 ++++
 drivers/net/wireless/iwlwifi/iwl-core.h     |    2 +
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   56 +++++-
 drivers/net/wireless/p54/p54usb.c           |    1 +
 drivers/net/wireless/wl12xx/wl1251_sdio.c   |    1 +
 net/mac80211/driver-ops.h                   |    2 +-
 net/mac80211/mlme.c                         |   92 +++++++-
 net/mac80211/rx.c                           |    3 +
 16 files changed, 362 insertions(+), 218 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 22a49e6..83be538 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2966,7 +2966,6 @@ F:	drivers/net/ixgb/
 F:	drivers/net/ixgbe/
 
 INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT
-M:	Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
@@ -2976,7 +2975,6 @@ F:	Documentation/networking/README.ipw2100
 F:	drivers/net/wireless/ipw2x00/ipw2100.*
 
 INTEL PRO/WIRELESS 2915ABG NETWORK CONNECTION SUPPORT
-M:	Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
@@ -3007,8 +3005,8 @@ F:	drivers/net/wimax/i2400m/
 F:	include/linux/wimax/i2400m.h
 
 INTEL WIRELESS WIFI LINK (iwlwifi)
-M:	Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
+M:	Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 W:	http://intellinuxwireless.org
@@ -3018,7 +3016,6 @@ F:	drivers/net/wireless/iwlwifi/
 
 INTEL WIRELESS MULTICOMM 3200 WIFI (iwmc3200wifi)
 M:	Samuel Ortiz <samuel.ortiz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
-M:	Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
 M:	Intel Linux Wireless <ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 S:	Supported
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 2978359..648972d 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -195,7 +195,7 @@ static const struct ieee80211_rate ath5k_rates[] = {
 static int __devinit	ath5k_pci_probe(struct pci_dev *pdev,
 				const struct pci_device_id *id);
 static void __devexit	ath5k_pci_remove(struct pci_dev *pdev);
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int		ath5k_pci_suspend(struct device *dev);
 static int		ath5k_pci_resume(struct device *dev);
 
@@ -203,7 +203,7 @@ static SIMPLE_DEV_PM_OPS(ath5k_pm_ops, ath5k_pci_suspend, ath5k_pci_resume);
 #define ATH5K_PM_OPS	(&ath5k_pm_ops)
 #else
 #define ATH5K_PM_OPS	NULL
-#endif /* CONFIG_PM */
+#endif /* CONFIG_PM_SLEEP */
 
 static struct pci_driver ath5k_pci_driver = {
 	.name		= KBUILD_MODNAME,
@@ -708,7 +708,7 @@ ath5k_pci_remove(struct pci_dev *pdev)
 	ieee80211_free_hw(hw);
 }
 
-#ifdef CONFIG_PM
+#ifdef CONFIG_PM_SLEEP
 static int ath5k_pci_suspend(struct device *dev)
 {
 	struct ieee80211_hw *hw = pci_get_drvdata(to_pci_dev(dev));
@@ -734,7 +734,7 @@ static int ath5k_pci_resume(struct device *dev)
 	ath5k_led_enable(sc);
 	return 0;
 }
-#endif /* CONFIG_PM */
+#endif /* CONFIG_PM_SLEEP */
 
 
 /***********************\
@@ -3140,13 +3140,15 @@ static void ath5k_configure_filter(struct ieee80211_hw *hw,
 
 	if (changed_flags & (FIF_PROMISC_IN_BSS | FIF_OTHER_BSS)) {
 		if (*new_flags & FIF_PROMISC_IN_BSS) {
-			rfilt |= AR5K_RX_FILTER_PROM;
 			__set_bit(ATH_STAT_PROMISC, sc->status);
 		} else {
 			__clear_bit(ATH_STAT_PROMISC, sc->status);
 		}
 	}
 
+	if (test_bit(ATH_STAT_PROMISC, sc->status))
+		rfilt |= AR5K_RX_FILTER_PROM;
+
 	/* Note, AR5K_RX_FILTER_MCAST is already enabled */
 	if (*new_flags & FIF_ALLMULTI) {
 		mfilt[0] =  ~0;
diff --git a/drivers/net/wireless/ath/ath5k/phy.c b/drivers/net/wireless/ath/ath5k/phy.c
index 1b81c47..492cbb1 100644
--- a/drivers/net/wireless/ath/ath5k/phy.c
+++ b/drivers/net/wireless/ath/ath5k/phy.c
@@ -1814,6 +1814,13 @@ ath5k_hw_set_antenna_mode(struct ath5k_hw *ah, u8 ant_mode)
 	u8 def_ant, tx_ant, ee_mode;
 	u32 sta_id1 = 0;
 
+	/* if channel is not initialized yet we can't set the antennas
+	 * so just store the mode. it will be set on the next reset */
+	if (channel == NULL) {
+		ah->ah_ant_mode = ant_mode;
+		return;
+	}
+
 	def_ant = ah->ah_def_ant;
 
 	ATH5K_TRACE(ah->ah_sc);
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index d707328..ff9b5c8 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -2618,15 +2618,6 @@ static irqreturn_t prism2_interrupt(int irq, void *dev_id)
 	int events = 0;
 	u16 ev;
 
-	/* Detect early interrupt before driver is fully configued */
-	if (!dev->base_addr) {
-		if (net_ratelimit()) {
-			printk(KERN_DEBUG "%s: Interrupt, but dev not configured\n",
-			       dev->name);
-		}
-		return IRQ_HANDLED;
-	}
-
 	iface = netdev_priv(dev);
 	local = iface->local;
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index 068f7f8..c44a303 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -2852,6 +2852,7 @@ static struct iwl_lib_ops iwl3945_lib = {
 	.isr = iwl_isr_legacy,
 	.config_ap = iwl3945_config_ap,
 	.manage_ibss_station = iwl3945_manage_ibss_station,
+	.recover_from_tx_stall = iwl_bg_monitor_recover,
 	.check_plcp_health = iwl3945_good_plcp_health,
 
 	.debugfs_ops = {
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
index 1004cfc..0f292a2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-lib.c
@@ -1119,10 +1119,9 @@ static int iwl_get_single_channel_for_scan(struct iwl_priv *priv,
 					   struct iwl_scan_channel *scan_ch)
 {
 	const struct ieee80211_supported_band *sband;
-	const struct iwl_channel_info *ch_info;
 	u16 passive_dwell = 0;
 	u16 active_dwell = 0;
-	int i, added = 0;
+	int added = 0;
 	u16 channel = 0;
 
 	sband = iwl_get_hw_mode(priv, band);
@@ -1137,32 +1136,7 @@ static int iwl_get_single_channel_for_scan(struct iwl_priv *priv,
 	if (passive_dwell <= active_dwell)
 		passive_dwell = active_dwell + 1;
 
-	/* only scan single channel, good enough to reset the RF */
-	/* pick the first valid not in-use channel */
-	if (band == IEEE80211_BAND_5GHZ) {
-		for (i = 14; i < priv->channel_count; i++) {
-			if (priv->channel_info[i].channel !=
-			    le16_to_cpu(priv->staging_rxon.channel)) {
-				channel = priv->channel_info[i].channel;
-				ch_info = iwl_get_channel_info(priv,
-					band, channel);
-				if (is_channel_valid(ch_info))
-					break;
-			}
-		}
-	} else {
-		for (i = 0; i < 14; i++) {
-			if (priv->channel_info[i].channel !=
-			    le16_to_cpu(priv->staging_rxon.channel)) {
-					channel =
-						priv->channel_info[i].channel;
-					ch_info = iwl_get_channel_info(priv,
-						band, channel);
-					if (is_channel_valid(ch_info))
-						break;
-			}
-		}
-	}
+	channel = iwl_get_single_channel_number(priv, band);
 	if (channel) {
 		scan_ch->channel = cpu_to_le16(channel);
 		scan_ch->type = SCAN_CHANNEL_TYPE_PASSIVE;
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
index c402bfc..a732f10 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
@@ -1125,6 +1125,7 @@ static void iwlagn_tx_status(struct iwl_priv *priv, struct sk_buff *skb)
 	struct ieee80211_sta *sta;
 	struct iwl_station_priv *sta_priv;
 
+	rcu_read_lock();
 	sta = ieee80211_find_sta(priv->vif, hdr->addr1);
 	if (sta) {
 		sta_priv = (void *)sta->drv_priv;
@@ -1133,6 +1134,7 @@ static void iwlagn_tx_status(struct iwl_priv *priv, struct sk_buff *skb)
 		    atomic_dec_return(&sta_priv->pending_frames) == 0)
 			ieee80211_sta_block_awake(priv->hw, sta, false);
 	}
+	rcu_read_unlock();
 
 	ieee80211_tx_status_irqsafe(priv->hw, skb);
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index aef4f71..7726e67 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -1484,6 +1484,156 @@ bool iwl_good_ack_health(struct iwl_priv *priv,
 }
 
 
+/*****************************************************************************
+ *
+ * sysfs attributes
+ *
+ *****************************************************************************/
+
+#ifdef CONFIG_IWLWIFI_DEBUG
+
+/*
+ * The following adds a new attribute to the sysfs representation
+ * of this device driver (i.e. a new file in /sys/class/net/wlan0/device/)
+ * used for controlling the debug level.
+ *
+ * See the level definitions in iwl for details.
+ *
+ * The debug_level being managed using sysfs below is a per device debug
+ * level that is used instead of the global debug level if it (the per
+ * device debug level) is set.
+ */
+static ssize_t show_debug_level(struct device *d,
+				struct device_attribute *attr, char *buf)
+{
+	struct iwl_priv *priv = dev_get_drvdata(d);
+	return sprintf(buf, "0x%08X\n", iwl_get_debug_level(priv));
+}
+static ssize_t store_debug_level(struct device *d,
+				struct device_attribute *attr,
+				 const char *buf, size_t count)
+{
+	struct iwl_priv *priv = dev_get_drvdata(d);
+	unsigned long val;
+	int ret;
+
+	ret = strict_strtoul(buf, 0, &val);
+	if (ret)
+		IWL_ERR(priv, "%s is not in hex or decimal form.\n", buf);
+	else {
+		priv->debug_level = val;
+		if (iwl_alloc_traffic_mem(priv))
+			IWL_ERR(priv,
+				"Not enough memory to generate traffic log\n");
+	}
+	return strnlen(buf, count);
+}
+
+static DEVICE_ATTR(debug_level, S_IWUSR | S_IRUGO,
+			show_debug_level, store_debug_level);
+
+
+#endif /* CONFIG_IWLWIFI_DEBUG */
+
+
+static ssize_t show_temperature(struct device *d,
+				struct device_attribute *attr, char *buf)
+{
+	struct iwl_priv *priv = dev_get_drvdata(d);
+
+	if (!iwl_is_alive(priv))
+		return -EAGAIN;
+
+	return sprintf(buf, "%d\n", priv->temperature);
+}
+
+static DEVICE_ATTR(temperature, S_IRUGO, show_temperature, NULL);
+
+static ssize_t show_tx_power(struct device *d,
+			     struct device_attribute *attr, char *buf)
+{
+	struct iwl_priv *priv = dev_get_drvdata(d);
+
+	if (!iwl_is_ready_rf(priv))
+		return sprintf(buf, "off\n");
+	else
+		return sprintf(buf, "%d\n", priv->tx_power_user_lmt);
+}
+
+static ssize_t store_tx_power(struct device *d,
+			      struct device_attribute *attr,
+			      const char *buf, size_t count)
+{
+	struct iwl_priv *priv = dev_get_drvdata(d);
+	unsigned long val;
+	int ret;
+
+	ret = strict_strtoul(buf, 10, &val);
+	if (ret)
+		IWL_INFO(priv, "%s is not in decimal form.\n", buf);
+	else {
+		ret = iwl_set_tx_power(priv, val, false);
+		if (ret)
+			IWL_ERR(priv, "failed setting tx power (0x%d).\n",
+				ret);
+		else
+			ret = count;
+	}
+	return ret;
+}
+
+static DEVICE_ATTR(tx_power, S_IWUSR | S_IRUGO, show_tx_power, store_tx_power);
+
+static ssize_t show_rts_ht_protection(struct device *d,
+			     struct device_attribute *attr, char *buf)
+{
+	struct iwl_priv *priv = dev_get_drvdata(d);
+
+	return sprintf(buf, "%s\n",
+		priv->cfg->use_rts_for_ht ? "RTS/CTS" : "CTS-to-self");
+}
+
+static ssize_t store_rts_ht_protection(struct device *d,
+			      struct device_attribute *attr,
+			      const char *buf, size_t count)
+{
+	struct iwl_priv *priv = dev_get_drvdata(d);
+	unsigned long val;
+	int ret;
+
+	ret = strict_strtoul(buf, 10, &val);
+	if (ret)
+		IWL_INFO(priv, "Input is not in decimal form.\n");
+	else {
+		if (!iwl_is_associated(priv))
+			priv->cfg->use_rts_for_ht = val ? true : false;
+		else
+			IWL_ERR(priv, "Sta associated with AP - "
+				"Change protection mechanism is not allowed\n");
+		ret = count;
+	}
+	return ret;
+}
+
+static DEVICE_ATTR(rts_ht_protection, S_IWUSR | S_IRUGO,
+			show_rts_ht_protection, store_rts_ht_protection);
+
+
+static struct attribute *iwl_sysfs_entries[] = {
+	&dev_attr_temperature.attr,
+	&dev_attr_tx_power.attr,
+	&dev_attr_rts_ht_protection.attr,
+#ifdef CONFIG_IWLWIFI_DEBUG
+	&dev_attr_debug_level.attr,
+#endif
+	NULL
+};
+
+static struct attribute_group iwl_attribute_group = {
+	.name = NULL,		/* put in device directory */
+	.attrs = iwl_sysfs_entries,
+};
+
 /******************************************************************************
  *
  * uCode download functions
@@ -1965,6 +2115,13 @@ static void iwl_ucode_callback(const struct firmware *ucode_raw, void *context)
 	if (err)
 		IWL_ERR(priv, "failed to create debugfs files. Ignoring error: %d\n", err);
 
+	err = sysfs_create_group(&priv->pci_dev->dev.kobj,
+					&iwl_attribute_group);
+	if (err) {
+		IWL_ERR(priv, "failed to create sysfs device attributes\n");
+		goto out_unbind;
+	}
+
 	/* We have our copies now, allow OS release its copies */
 	release_firmware(ucode_raw);
 	complete(&priv->_agn.firmware_loading_complete);
@@ -3264,141 +3421,6 @@ static int iwlagn_mac_sta_add(struct ieee80211_hw *hw,
 
 /*****************************************************************************
  *
- * sysfs attributes
- *
- *****************************************************************************/
-
-#ifdef CONFIG_IWLWIFI_DEBUG
-
-/*
- * The following adds a new attribute to the sysfs representation
- * of this device driver (i.e. a new file in /sys/class/net/wlan0/device/)
- * used for controlling the debug level.
- *
- * See the level definitions in iwl for details.
- *
- * The debug_level being managed using sysfs below is a per device debug
- * level that is used instead of the global debug level if it (the per
- * device debug level) is set.
- */
-static ssize_t show_debug_level(struct device *d,
-				struct device_attribute *attr, char *buf)
-{
-	struct iwl_priv *priv = dev_get_drvdata(d);
-	return sprintf(buf, "0x%08X\n", iwl_get_debug_level(priv));
-}
-static ssize_t store_debug_level(struct device *d,
-				struct device_attribute *attr,
-				 const char *buf, size_t count)
-{
-	struct iwl_priv *priv = dev_get_drvdata(d);
-	unsigned long val;
-	int ret;
-
-	ret = strict_strtoul(buf, 0, &val);
-	if (ret)
-		IWL_ERR(priv, "%s is not in hex or decimal form.\n", buf);
-	else {
-		priv->debug_level = val;
-		if (iwl_alloc_traffic_mem(priv))
-			IWL_ERR(priv,
-				"Not enough memory to generate traffic log\n");
-	}
-	return strnlen(buf, count);
-}
-
-static DEVICE_ATTR(debug_level, S_IWUSR | S_IRUGO,
-			show_debug_level, store_debug_level);
-
-
-#endif /* CONFIG_IWLWIFI_DEBUG */
-
-
-static ssize_t show_temperature(struct device *d,
-				struct device_attribute *attr, char *buf)
-{
-	struct iwl_priv *priv = dev_get_drvdata(d);
-
-	if (!iwl_is_alive(priv))
-		return -EAGAIN;
-
-	return sprintf(buf, "%d\n", priv->temperature);
-}
-
-static DEVICE_ATTR(temperature, S_IRUGO, show_temperature, NULL);
-
-static ssize_t show_tx_power(struct device *d,
-			     struct device_attribute *attr, char *buf)
-{
-	struct iwl_priv *priv = dev_get_drvdata(d);
-
-	if (!iwl_is_ready_rf(priv))
-		return sprintf(buf, "off\n");
-	else
-		return sprintf(buf, "%d\n", priv->tx_power_user_lmt);
-}
-
-static ssize_t store_tx_power(struct device *d,
-			      struct device_attribute *attr,
-			      const char *buf, size_t count)
-{
-	struct iwl_priv *priv = dev_get_drvdata(d);
-	unsigned long val;
-	int ret;
-
-	ret = strict_strtoul(buf, 10, &val);
-	if (ret)
-		IWL_INFO(priv, "%s is not in decimal form.\n", buf);
-	else {
-		ret = iwl_set_tx_power(priv, val, false);
-		if (ret)
-			IWL_ERR(priv, "failed setting tx power (0x%d).\n",
-				ret);
-		else
-			ret = count;
-	}
-	return ret;
-}
-
-static DEVICE_ATTR(tx_power, S_IWUSR | S_IRUGO, show_tx_power, store_tx_power);
-
-static ssize_t show_rts_ht_protection(struct device *d,
-			     struct device_attribute *attr, char *buf)
-{
-	struct iwl_priv *priv = dev_get_drvdata(d);
-
-	return sprintf(buf, "%s\n",
-		priv->cfg->use_rts_for_ht ? "RTS/CTS" : "CTS-to-self");
-}
-
-static ssize_t store_rts_ht_protection(struct device *d,
-			      struct device_attribute *attr,
-			      const char *buf, size_t count)
-{
-	struct iwl_priv *priv = dev_get_drvdata(d);
-	unsigned long val;
-	int ret;
-
-	ret = strict_strtoul(buf, 10, &val);
-	if (ret)
-		IWL_INFO(priv, "Input is not in decimal form.\n");
-	else {
-		if (!iwl_is_associated(priv))
-			priv->cfg->use_rts_for_ht = val ? true : false;
-		else
-			IWL_ERR(priv, "Sta associated with AP - "
-				"Change protection mechanism is not allowed\n");
-		ret = count;
-	}
-	return ret;
-}
-
-static DEVICE_ATTR(rts_ht_protection, S_IWUSR | S_IRUGO,
-			show_rts_ht_protection, store_rts_ht_protection);
-
-
-/*****************************************************************************
- *
  * driver setup and teardown
  *
  *****************************************************************************/
@@ -3550,21 +3572,6 @@ static void iwl_uninit_drv(struct iwl_priv *priv)
 	kfree(priv->scan_cmd);
 }
 
-static struct attribute *iwl_sysfs_entries[] = {
-	&dev_attr_temperature.attr,
-	&dev_attr_tx_power.attr,
-	&dev_attr_rts_ht_protection.attr,
-#ifdef CONFIG_IWLWIFI_DEBUG
-	&dev_attr_debug_level.attr,
-#endif
-	NULL
-};
-
-static struct attribute_group iwl_attribute_group = {
-	.name = NULL,		/* put in device directory */
-	.attrs = iwl_sysfs_entries,
-};
-
 static struct ieee80211_ops iwl_hw_ops = {
 	.tx = iwl_mac_tx,
 	.start = iwl_mac_start,
@@ -3750,11 +3757,6 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		IWL_ERR(priv, "Error allocating IRQ %d\n", priv->pci_dev->irq);
 		goto out_disable_msi;
 	}
-	err = sysfs_create_group(&pdev->dev.kobj, &iwl_attribute_group);
-	if (err) {
-		IWL_ERR(priv, "failed to create sysfs device attributes\n");
-		goto out_free_irq;
-	}
 
 	iwl_setup_deferred_work(priv);
 	iwl_setup_rx_handlers(priv);
@@ -3788,15 +3790,13 @@ static int iwl_pci_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	err = iwl_request_firmware(priv, true);
 	if (err)
-		goto out_remove_sysfs;
+		goto out_destroy_workqueue;
 
 	return 0;
 
- out_remove_sysfs:
+ out_destroy_workqueue:
 	destroy_workqueue(priv->workqueue);
 	priv->workqueue = NULL;
-	sysfs_remove_group(&pdev->dev.kobj, &iwl_attribute_group);
- out_free_irq:
 	free_irq(priv->pci_dev->irq, priv);
 	iwl_free_isr_ict(priv);
  out_disable_msi:
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.c b/drivers/net/wireless/iwlwifi/iwl-core.c
index 5a7eca8..426e955 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.c
+++ b/drivers/net/wireless/iwlwifi/iwl-core.c
@@ -854,6 +854,45 @@ void iwl_set_rxon_chain(struct iwl_priv *priv)
 }
 EXPORT_SYMBOL(iwl_set_rxon_chain);
 
+/* Return valid channel */
+u8 iwl_get_single_channel_number(struct iwl_priv *priv,
+				  enum ieee80211_band band)
+{
+	const struct iwl_channel_info *ch_info;
+	int i;
+	u8 channel = 0;
+
+	/* only scan single channel, good enough to reset the RF */
+	/* pick the first valid not in-use channel */
+	if (band == IEEE80211_BAND_5GHZ) {
+		for (i = 14; i < priv->channel_count; i++) {
+			if (priv->channel_info[i].channel !=
+			    le16_to_cpu(priv->staging_rxon.channel)) {
+				channel = priv->channel_info[i].channel;
+				ch_info = iwl_get_channel_info(priv,
+					band, channel);
+				if (is_channel_valid(ch_info))
+					break;
+			}
+		}
+	} else {
+		for (i = 0; i < 14; i++) {
+			if (priv->channel_info[i].channel !=
+			    le16_to_cpu(priv->staging_rxon.channel)) {
+					channel =
+						priv->channel_info[i].channel;
+					ch_info = iwl_get_channel_info(priv,
+						band, channel);
+					if (is_channel_valid(ch_info))
+						break;
+			}
+		}
+	}
+
+	return channel;
+}
+EXPORT_SYMBOL(iwl_get_single_channel_number);
+
 /**
  * iwl_set_rxon_channel - Set the phymode and channel values in staging RXON
  * @phymode: MODE_IEEE80211A sets to 5.2GHz; all else set to 2.4GHz
diff --git a/drivers/net/wireless/iwlwifi/iwl-core.h b/drivers/net/wireless/iwlwifi/iwl-core.h
index 7e5a5ba..31775bd 100644
--- a/drivers/net/wireless/iwlwifi/iwl-core.h
+++ b/drivers/net/wireless/iwlwifi/iwl-core.h
@@ -343,6 +343,8 @@ int iwl_check_rxon_cmd(struct iwl_priv *priv);
 int iwl_full_rxon_required(struct iwl_priv *priv);
 void iwl_set_rxon_chain(struct iwl_priv *priv);
 int iwl_set_rxon_channel(struct iwl_priv *priv, struct ieee80211_channel *ch);
+u8 iwl_get_single_channel_number(struct iwl_priv *priv,
+				  enum ieee80211_band band);
 void iwl_set_rxon_ht(struct iwl_priv *priv, struct iwl_ht_config *ht_conf);
 u8 iwl_is_ht40_tx_allowed(struct iwl_priv *priv,
 			 struct ieee80211_sta_ht_cap *sta_ht_inf);
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 3e5bffb..6c353ca 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -1844,6 +1844,49 @@ static void iwl3945_irq_tasklet(struct iwl_priv *priv)
 #endif
 }
 
+static int iwl3945_get_single_channel_for_scan(struct iwl_priv *priv,
+					       struct ieee80211_vif *vif,
+					       enum ieee80211_band band,
+					       struct iwl3945_scan_channel *scan_ch)
+{
+	const struct ieee80211_supported_band *sband;
+	u16 passive_dwell = 0;
+	u16 active_dwell = 0;
+	int added = 0;
+	u8 channel = 0;
+
+	sband = iwl_get_hw_mode(priv, band);
+	if (!sband) {
+		IWL_ERR(priv, "invalid band\n");
+		return added;
+	}
+
+	active_dwell = iwl_get_active_dwell_time(priv, band, 0);
+	passive_dwell = iwl_get_passive_dwell_time(priv, band, vif);
+
+	if (passive_dwell <= active_dwell)
+		passive_dwell = active_dwell + 1;
+
+
+	channel = iwl_get_single_channel_number(priv, band);
+
+	if (channel) {
+		scan_ch->channel = channel;
+		scan_ch->type = 0;	/* passive */
+		scan_ch->active_dwell = cpu_to_le16(active_dwell);
+		scan_ch->passive_dwell = cpu_to_le16(passive_dwell);
+		/* Set txpower levels to defaults */
+		scan_ch->tpc.dsp_atten = 110;
+		if (band == IEEE80211_BAND_5GHZ)
+			scan_ch->tpc.tx_gain = ((1 << 5) | (3 << 3)) | 3;
+		else
+			scan_ch->tpc.tx_gain = ((1 << 5) | (5 << 3));
+		added++;
+	} else
+		IWL_ERR(priv, "no valid channel found\n");
+	return added;
+}
+
 static int iwl3945_get_channels_for_scan(struct iwl_priv *priv,
 					 enum ieee80211_band band,
 				     u8 is_active, u8 n_probes,
@@ -2992,9 +3035,16 @@ void iwl3945_request_scan(struct iwl_priv *priv, struct ieee80211_vif *vif)
 	/* select Rx antennas */
 	scan->flags |= iwl3945_get_antenna_flags(priv);
 
-	scan->channel_count =
-		iwl3945_get_channels_for_scan(priv, band, is_active, n_probes,
-			(void *)&scan->data[le16_to_cpu(scan->tx_cmd.len)], vif);
+	if (priv->is_internal_short_scan) {
+		scan->channel_count =
+			iwl3945_get_single_channel_for_scan(priv, vif, band,
+				(void *)&scan->data[le16_to_cpu(
+				scan->tx_cmd.len)]);
+	} else {
+		scan->channel_count =
+			iwl3945_get_channels_for_scan(priv, band, is_active, n_probes,
+				(void *)&scan->data[le16_to_cpu(scan->tx_cmd.len)], vif);
+	}
 
 	if (scan->channel_count == 0) {
 		IWL_DEBUG_SCAN(priv, "channel count %d\n", scan->channel_count);
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index d5b197b..7307325 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -80,6 +80,7 @@ static struct usb_device_id p54u_table[] __devinitdata = {
 	{USB_DEVICE(0x1413, 0x5400)},   /* Telsey 802.11g USB2.0 Adapter */
 	{USB_DEVICE(0x1435, 0x0427)},	/* Inventel UR054G */
 	{USB_DEVICE(0x2001, 0x3704)},	/* DLink DWL-G122 rev A2 */
+	{USB_DEVICE(0x413c, 0x5513)},	/* Dell WLA3310 USB Wireless Adapter */
 	{USB_DEVICE(0x413c, 0x8102)},	/* Spinnaker DUT */
 	{USB_DEVICE(0x413c, 0x8104)},	/* Cohiba Proto board */
 	{}
diff --git a/drivers/net/wireless/wl12xx/wl1251_sdio.c b/drivers/net/wireless/wl12xx/wl1251_sdio.c
index d234285..c561332 100644
--- a/drivers/net/wireless/wl12xx/wl1251_sdio.c
+++ b/drivers/net/wireless/wl12xx/wl1251_sdio.c
@@ -259,6 +259,7 @@ disable:
 	sdio_disable_func(func);
 release:
 	sdio_release_host(func);
+	wl1251_free_hw(wl);
 	return ret;
 }
 
diff --git a/net/mac80211/driver-ops.h b/net/mac80211/driver-ops.h
index 4f22713..9c1da08 100644
--- a/net/mac80211/driver-ops.h
+++ b/net/mac80211/driver-ops.h
@@ -349,7 +349,7 @@ static inline int drv_get_survey(struct ieee80211_local *local, int idx,
 				struct survey_info *survey)
 {
 	int ret = -EOPNOTSUPP;
-	if (local->ops->conf_tx)
+	if (local->ops->get_survey)
 		ret = local->ops->get_survey(&local->hw, idx, survey);
 	/* trace_drv_get_survey(local, idx, survey, ret); */
 	return ret;
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 0839c4e..f803f8b 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -1692,14 +1692,52 @@ static void ieee80211_sta_rx_queued_mgmt(struct ieee80211_sub_if_data *sdata,
 			rma = ieee80211_rx_mgmt_disassoc(sdata, mgmt, skb->len);
 			break;
 		case IEEE80211_STYPE_ACTION:
-			if (mgmt->u.action.category != WLAN_CATEGORY_SPECTRUM_MGMT)
+			switch (mgmt->u.action.category) {
+			case WLAN_CATEGORY_BACK: {
+				struct ieee80211_local *local = sdata->local;
+				int len = skb->len;
+				struct sta_info *sta;
+
+				rcu_read_lock();
+				sta = sta_info_get(sdata, mgmt->sa);
+				if (!sta) {
+					rcu_read_unlock();
+					break;
+				}
+
+				local_bh_disable();
+
+				switch (mgmt->u.action.u.addba_req.action_code) {
+				case WLAN_ACTION_ADDBA_REQ:
+					if (len < (IEEE80211_MIN_ACTION_SIZE +
+						   sizeof(mgmt->u.action.u.addba_req)))
+						break;
+					ieee80211_process_addba_request(local, sta, mgmt, len);
+					break;
+				case WLAN_ACTION_ADDBA_RESP:
+					if (len < (IEEE80211_MIN_ACTION_SIZE +
+						   sizeof(mgmt->u.action.u.addba_resp)))
+						break;
+					ieee80211_process_addba_resp(local, sta, mgmt, len);
+					break;
+				case WLAN_ACTION_DELBA:
+					if (len < (IEEE80211_MIN_ACTION_SIZE +
+						   sizeof(mgmt->u.action.u.delba)))
+						break;
+					ieee80211_process_delba(sdata, sta, mgmt, len);
+					break;
+				}
+				local_bh_enable();
+				rcu_read_unlock();
 				break;
-
-			ieee80211_sta_process_chanswitch(sdata,
-					&mgmt->u.action.u.chan_switch.sw_elem,
-					(void *)ifmgd->associated->priv,
-					rx_status->mactime);
-			break;
+				}
+			case WLAN_CATEGORY_SPECTRUM_MGMT:
+				ieee80211_sta_process_chanswitch(sdata,
+						&mgmt->u.action.u.chan_switch.sw_elem,
+						(void *)ifmgd->associated->priv,
+						rx_status->mactime);
+				break;
+			}
 		}
 		mutex_unlock(&ifmgd->mtx);
 
@@ -1722,9 +1760,45 @@ static void ieee80211_sta_rx_queued_mgmt(struct ieee80211_sub_if_data *sdata,
 	mutex_unlock(&ifmgd->mtx);
 
 	if (skb->len >= 24 + 2 /* mgmt + deauth reason */ &&
-	    (fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_DEAUTH)
-		cfg80211_send_deauth(sdata->dev, (u8 *)mgmt, skb->len);
+	    (fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_DEAUTH) {
+		struct ieee80211_local *local = sdata->local;
+		struct ieee80211_work *wk;
+
+		mutex_lock(&local->work_mtx);
+		list_for_each_entry(wk, &local->work_list, list) {
+			if (wk->sdata != sdata)
+				continue;
+
+			if (wk->type != IEEE80211_WORK_ASSOC)
+				continue;
+
+			if (memcmp(mgmt->bssid, wk->filter_ta, ETH_ALEN))
+				continue;
+			if (memcmp(mgmt->sa, wk->filter_ta, ETH_ALEN))
+				continue;
 
+			/*
+			 * Printing the message only here means we can't
+			 * spuriously print it, but it also means that it
+			 * won't be printed when the frame comes in before
+			 * we even tried to associate or in similar cases.
+			 *
+			 * Ultimately, I suspect cfg80211 should print the
+			 * messages instead.
+			 */
+			printk(KERN_DEBUG
+			       "%s: deauthenticated from %pM (Reason: %u)\n",
+			       sdata->name, mgmt->bssid,
+			       le16_to_cpu(mgmt->u.deauth.reason_code));
+
+			list_del_rcu(&wk->list);
+			free_work(wk);
+			break;
+		}
+		mutex_unlock(&local->work_mtx);
+
+		cfg80211_send_deauth(sdata->dev, (u8 *)mgmt, skb->len);
+	}
  out:
 	kfree_skb(skb);
 }
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 5e0b654..be9abc2 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1944,6 +1944,9 @@ ieee80211_rx_h_action(struct ieee80211_rx_data *rx)
 		if (len < IEEE80211_MIN_ACTION_SIZE + 1)
 			break;
 
+		if (sdata->vif.type == NL80211_IFTYPE_STATION)
+			return ieee80211_sta_rx_mgmt(sdata, rx->skb);
+
 		switch (mgmt->u.action.u.addba_req.action_code) {
 		case WLAN_ACTION_ADDBA_REQ:
 			if (len < (IEEE80211_MIN_ACTION_SIZE +
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
