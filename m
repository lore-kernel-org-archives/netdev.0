From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2012-01-17
Date: Tue, 17 Jan 2012 10:46:29 -0500
Message-ID: <20120117154629.GG12733@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IrhDeMKUP4DT/M7F"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--IrhDeMKUP4DT/M7F
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 604c4ef1c453a1b2ea2cdf04d2b49afec421ebfa

Dave,

Here is a set of fixes for 3.3.  This includes the ones that I
originally posted on Monday, the bcma ones from Linus, plus a few
more...

=46rom the Monday pull request:

"Included is a fix for a signedness bug in ipw2x00 from Dan Carpenter, a
fix for an oops when ejecting a b43 card from Guennadi Liakhovetski
(with a minor modification by me as noted in the changelog), a mac80211
regresion fix from Johannes Berg for a bug related to station
management, and a final fix for the rt2800pci spurious interrupt issue
=66rom Stanislaw Gruszka."

On top of those are the ones from Linus' "brcm80211 breakage.." thread:

	http://www.spinics.net/lists/netdev/msg185393.html
	http://www.spinics.net/lists/netdev/msg185722.html

In addition, we have a work-around/fix for a brcmfmac build issue with
gcc 4.7 from Alexandre Oliva, a fix for an "always true" check in mwl8k
=66rom Dan Carpenter, a fix for an iwlwifi build warning from Fabio
Estevam, a fix from Felix Fietkau for an ath9k regression regarding
interpretation of the rx KeyMiss flag, a fix for a bottom-half race in
mac80211 from Helmut Schaa, a fix for a mac80211 memory leak from Jesper
Juhl, a fix for an mwl8k sparse endian check from Yogesh Ashok Powar,
and a fix for a mac80211 NULL pointer dereference from Yoni Divinsky.
Also includes are some MAINTAINERS updates from Rafa=C5=82 Mi=C5=82ecki,
as well as his fix to prevent system lockups from bcma during
suspend/resume.

Please let me know if there are problems!

Thanks,

John

---
The following changes since commit 7c7c7f01cc5e3e423120a4848a73dd5e4586f2f9:

  vhost-net: add module alias (v2.1) (2012-01-13 10:12:23 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git master

Alexandre Oliva (1):
      brcmfmac: work-around gcc 4.7 build issue

Dan Carpenter (2):
      ipw2x00: signedness bug handling frame length
      mwl8k: fix condition in mwl8k_cmd_encryption_remove_key()

Fabio Estevam (1):
      wireless: iwlwifi: iwl-scan.c: Fix build warning

Felix Fietkau (1):
      ath9k_hw: fix interpretation of the rx KeyMiss flag

Guennadi Liakhovetski (1):
      wireless: b43: fix Oops on card eject during transfer

Helmut Schaa (1):
      mac80211: Fix possible race between sta_unblock and network softirq

Jesper Juhl (1):
      Net, mac80211: Fix resource leak in ieee80211_rx_h_mesh_fwding()

Johannes Berg (1):
      mac80211: fix no-op authorized transitions

Linus Torvalds (4):
      bcma: convert suspend/resume to pm_ops
      bcma: add stub for bcma_bus_suspend()
      bcma: connect the bcma bus suspend/resume to the bcma driver suspend/=
resume
      brcmsmac: remove PCI suspend/resume from bcma driver

Rafa=C5=82 Mi=C5=82ecki (3):
      MAINTAINERS: move BCMA to keep the list sorted
      MAINTAINERS: add b43 mailing list
      bcma: invalidate the mapped core over suspend/resume

Stanislaw Gruszka (1):
      rt2800pci: fix spurious interrupts generation

Yogesh Ashok Powar (1):
      mwl8k: Fixing Sparse ENDIAN CHECK warning

Yoni Divinsky (1):
      mac80211: fix tx->skb NULL pointer dereference

 MAINTAINERS                                        |   15 ++++---
 drivers/bcma/bcma_private.h                        |    1 +
 drivers/bcma/host_pci.c                            |   43 ++++++++--------=
---
 drivers/bcma/main.c                                |   24 +++++++++++
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |    5 +-
 drivers/net/wireless/ath/ath9k/mac.c               |    5 +-
 drivers/net/wireless/b43/main.c                    |    5 ++-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    2 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   40 ++--------------=
--
 drivers/net/wireless/ipw2x00/ipw2200.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |    2 +-
 drivers/net/wireless/mwl8k.c                       |    4 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |   28 ++++---------
 include/linux/bcma/bcma.h                          |    2 +-
 net/mac80211/cfg.c                                 |    2 +-
 net/mac80211/rx.c                                  |    1 +
 net/mac80211/sta_info.c                            |    6 ++-
 net/mac80211/tx.c                                  |   10 +----
 net/mac80211/wpa.c                                 |   19 +++++++++
 net/mac80211/wpa.h                                 |    2 +
 20 files changed, 108 insertions(+), 112 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 1094edf..6e68daa1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1411,6 +1411,7 @@ F:	net/ax25/
 B43 WIRELESS DRIVER
 M:	Stefano Brivio <stefano.brivio-hl5o88x/ua9eoWH0uzbU5w@public.gmane.org>
 L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+L:	b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org (moderated for non-subscribers)
 W:	http://linuxwireless.org/en/users/Drivers/b43
 S:	Maintained
 F:	drivers/net/wireless/b43/
@@ -1587,6 +1588,13 @@ L:	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 S:	Supported
 F:	drivers/scsi/bnx2fc/
=20
+BROADCOM SPECIFIC AMBA DRIVER (BCMA)
+M:	Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
+S:	Maintained
+F:	drivers/bcma/
+F:	include/linux/bcma/
+
 BROCADE BFA FC SCSI DRIVER
 M:	Jing Huang <huangj-43mecJUBy8ZBDgjK7y7TUQ@public.gmane.org>
 L:	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
@@ -6099,13 +6107,6 @@ S:	Maintained
 F:	drivers/ssb/
 F:	include/linux/ssb/
=20
-BROADCOM SPECIFIC AMBA DRIVER (BCMA)
-M:	Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
-L:	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
-S:	Maintained
-F:	drivers/bcma/
-F:	include/linux/bcma/
-
 SONY VAIO CONTROL DEVICE DRIVER
 M:	Mattia Dongili <malattia-k2GhghHVRtY@public.gmane.org>
 L:	platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
diff --git a/drivers/bcma/bcma_private.h b/drivers/bcma/bcma_private.h
index fda56bd..0def898 100644
--- a/drivers/bcma/bcma_private.h
+++ b/drivers/bcma/bcma_private.h
@@ -19,6 +19,7 @@ int __init bcma_bus_early_register(struct bcma_bus *bus,
 				   struct bcma_device *core_cc,
 				   struct bcma_device *core_mips);
 #ifdef CONFIG_PM
+int bcma_bus_suspend(struct bcma_bus *bus);
 int bcma_bus_resume(struct bcma_bus *bus);
 #endif
=20
diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
index 443b83a..f59244e 100644
--- a/drivers/bcma/host_pci.c
+++ b/drivers/bcma/host_pci.c
@@ -235,38 +235,32 @@ static void bcma_host_pci_remove(struct pci_dev *dev)
 }
=20
 #ifdef CONFIG_PM
-static int bcma_host_pci_suspend(struct pci_dev *dev, pm_message_t state)
+static int bcma_host_pci_suspend(struct device *dev)
 {
-	/* Host specific */
-	pci_save_state(dev);
-	pci_disable_device(dev);
-	pci_set_power_state(dev, pci_choose_state(dev, state));
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct bcma_bus *bus =3D pci_get_drvdata(pdev);
=20
-	return 0;
+	bus->mapped_core =3D NULL;
+
+	return bcma_bus_suspend(bus);
 }
=20
-static int bcma_host_pci_resume(struct pci_dev *dev)
+static int bcma_host_pci_resume(struct device *dev)
 {
-	struct bcma_bus *bus =3D pci_get_drvdata(dev);
-	int err;
+	struct pci_dev *pdev =3D to_pci_dev(dev);
+	struct bcma_bus *bus =3D pci_get_drvdata(pdev);
=20
-	/* Host specific */
-	pci_set_power_state(dev, 0);
-	err =3D pci_enable_device(dev);
-	if (err)
-		return err;
-	pci_restore_state(dev);
+	return bcma_bus_resume(bus);
+}
=20
-	/* Bus specific */
-	err =3D bcma_bus_resume(bus);
-	if (err)
-		return err;
+static SIMPLE_DEV_PM_OPS(bcma_pm_ops, bcma_host_pci_suspend,
+			 bcma_host_pci_resume);
+#define BCMA_PM_OPS	(&bcma_pm_ops)
=20
-	return 0;
-}
 #else /* CONFIG_PM */
-# define bcma_host_pci_suspend	NULL
-# define bcma_host_pci_resume	NULL
+
+#define BCMA_PM_OPS     NULL
+
 #endif /* CONFIG_PM */
=20
 static DEFINE_PCI_DEVICE_TABLE(bcma_pci_bridge_tbl) =3D {
@@ -284,8 +278,7 @@ static struct pci_driver bcma_pci_bridge_driver =3D {
 	.id_table =3D bcma_pci_bridge_tbl,
 	.probe =3D bcma_host_pci_probe,
 	.remove =3D bcma_host_pci_remove,
-	.suspend =3D bcma_host_pci_suspend,
-	.resume =3D bcma_host_pci_resume,
+	.driver.pm =3D BCMA_PM_OPS,
 };
=20
 int __init bcma_host_pci_init(void)
diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index 10f92b3..febbc0a 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -241,6 +241,21 @@ int __init bcma_bus_early_register(struct bcma_bus *bu=
s,
 }
=20
 #ifdef CONFIG_PM
+int bcma_bus_suspend(struct bcma_bus *bus)
+{
+	struct bcma_device *core;
+
+	list_for_each_entry(core, &bus->cores, list) {
+		struct device_driver *drv =3D core->dev.driver;
+		if (drv) {
+			struct bcma_driver *adrv =3D container_of(drv, struct bcma_driver, drv);
+			if (adrv->suspend)
+				adrv->suspend(core);
+		}
+	}
+	return 0;
+}
+
 int bcma_bus_resume(struct bcma_bus *bus)
 {
 	struct bcma_device *core;
@@ -252,6 +267,15 @@ int bcma_bus_resume(struct bcma_bus *bus)
 		bcma_core_chipcommon_init(&bus->drv_cc);
 	}
=20
+	list_for_each_entry(core, &bus->cores, list) {
+		struct device_driver *drv =3D core->dev.driver;
+		if (drv) {
+			struct bcma_driver *adrv =3D container_of(drv, struct bcma_driver, drv);
+			if (adrv->resume)
+				adrv->resume(core);
+		}
+	}
+
 	return 0;
 }
 #endif
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_mac.c b/drivers/net/wire=
less/ath/ath9k/ar9003_mac.c
index 88c81c5..09b8c9d 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
@@ -557,10 +557,11 @@ int ath9k_hw_process_rxdesc_edma(struct ath_hw *ah, s=
truct ath_rx_status *rxs,
 			rxs->rs_status |=3D ATH9K_RXERR_DECRYPT;
 		else if (rxsp->status11 & AR_MichaelErr)
 			rxs->rs_status |=3D ATH9K_RXERR_MIC;
-		if (rxsp->status11 & AR_KeyMiss)
-			rxs->rs_status |=3D ATH9K_RXERR_KEYMISS;
 	}
=20
+	if (rxsp->status11 & AR_KeyMiss)
+		rxs->rs_status |=3D ATH9K_RXERR_KEYMISS;
+
 	return 0;
 }
 EXPORT_SYMBOL(ath9k_hw_process_rxdesc_edma);
diff --git a/drivers/net/wireless/ath/ath9k/mac.c b/drivers/net/wireless/at=
h/ath9k/mac.c
index fd3f19c..e196aba 100644
--- a/drivers/net/wireless/ath/ath9k/mac.c
+++ b/drivers/net/wireless/ath/ath9k/mac.c
@@ -618,10 +618,11 @@ int ath9k_hw_rxprocdesc(struct ath_hw *ah, struct ath=
_desc *ds,
 			rs->rs_status |=3D ATH9K_RXERR_DECRYPT;
 		else if (ads.ds_rxstatus8 & AR_MichaelErr)
 			rs->rs_status |=3D ATH9K_RXERR_MIC;
-		if (ads.ds_rxstatus8 & AR_KeyMiss)
-			rs->rs_status |=3D ATH9K_RXERR_KEYMISS;
 	}
=20
+	if (ads.ds_rxstatus8 & AR_KeyMiss)
+		rs->rs_status |=3D ATH9K_RXERR_KEYMISS;
+
 	return 0;
 }
 EXPORT_SYMBOL(ath9k_hw_rxprocdesc);
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/mai=
n.c
index 1c6f193..b91f28e 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4852,6 +4852,9 @@ static void b43_op_stop(struct ieee80211_hw *hw)
=20
 	cancel_work_sync(&(wl->beacon_update_trigger));
=20
+	if (!dev)
+		goto out;
+
 	mutex_lock(&wl->mutex);
 	if (b43_status(dev) >=3D B43_STAT_STARTED) {
 		dev =3D b43_wireless_core_stop(dev);
@@ -4863,7 +4866,7 @@ static void b43_op_stop(struct ieee80211_hw *hw)
=20
 out_unlock:
 	mutex_unlock(&wl->mutex);
-
+out:
 	cancel_work_sync(&(wl->txpower_adjust_work));
 }
=20
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index f23b0c3..bf11850 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -2475,7 +2475,7 @@ static s32 brcmf_init_iscan(struct brcmf_cfg80211_pri=
v *cfg_priv)
 	return err;
 }
=20
-static void brcmf_delay(u32 ms)
+static __always_inline void brcmf_delay(u32 ms)
 {
 	if (ms < 1000 / HZ) {
 		cond_resched();
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/driver=
s/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index d106576..448ab9c 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -1128,14 +1128,7 @@ static int __devinit brcms_bcma_probe(struct bcma_de=
vice *pdev)
 	return 0;
 }
=20
-static int brcms_pci_suspend(struct pci_dev *pdev)
-{
-	pci_save_state(pdev);
-	pci_disable_device(pdev);
-	return pci_set_power_state(pdev, PCI_D3hot);
-}
-
-static int brcms_suspend(struct bcma_device *pdev, pm_message_t state)
+static int brcms_suspend(struct bcma_device *pdev)
 {
 	struct brcms_info *wl;
 	struct ieee80211_hw *hw;
@@ -1153,40 +1146,15 @@ static int brcms_suspend(struct bcma_device *pdev, =
pm_message_t state)
 	wl->pub->hw_up =3D false;
 	spin_unlock_bh(&wl->lock);
=20
-	/* temporarily do suspend ourselves */
-	return brcms_pci_suspend(pdev->bus->host_pci);
-}
-
-static int brcms_pci_resume(struct pci_dev *pdev)
-{
-	int err =3D 0;
-	uint val;
-
-	err =3D pci_set_power_state(pdev, PCI_D0);
-	if (err)
-		return err;
-
-	pci_restore_state(pdev);
-
-	err =3D pci_enable_device(pdev);
-	if (err)
-		return err;
-
-	pci_set_master(pdev);
-
-	pci_read_config_dword(pdev, 0x40, &val);
-	if ((val & 0x0000ff00) !=3D 0)
-		pci_write_config_dword(pdev, 0x40, val & 0xffff00ff);
+	pr_debug("brcms_suspend ok\n");
=20
 	return 0;
 }
=20
 static int brcms_resume(struct bcma_device *pdev)
 {
-	/*
-	*  just do pci resume for now until bcma supports it.
-	*/
-	return brcms_pci_resume(pdev->bus->host_pci);
+	pr_debug("brcms_resume ok\n");
+	return 0;
 }
=20
 static struct bcma_driver brcms_bcma_driver =3D {
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/=
ipw2x00/ipw2200.c
index 018a8de..4fcdac6 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -7848,7 +7848,7 @@ static void ipw_handle_data_packet_monitor(struct ipw=
_priv *priv,
 	 * more efficiently than we can parse it. ORDER MATTERS HERE */
 	struct ipw_rt_hdr *ipw_rt;
=20
-	short len =3D le16_to_cpu(pkt->u.frame.length);
+	unsigned short len =3D le16_to_cpu(pkt->u.frame.length);
=20
 	/* We received data from the HW, so stop the watchdog */
 	dev->trans_start =3D jiffies;
@@ -8023,7 +8023,7 @@ static void ipw_handle_promiscuous_rx(struct ipw_priv=
 *priv,
 	s8 signal =3D frame->rssi_dbm - IPW_RSSI_TO_DBM;
 	s8 noise =3D (s8) le16_to_cpu(frame->noise);
 	u8 rate =3D frame->rate;
-	short len =3D le16_to_cpu(pkt->u.frame.length);
+	unsigned short len =3D le16_to_cpu(pkt->u.frame.length);
 	struct sk_buff *skb;
 	int hdr_only =3D 0;
 	u16 filter =3D priv->prom_priv->filter;
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless=
/iwlwifi/iwl-scan.c
index 084aa2c..a645472 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -569,7 +569,7 @@ static int iwlagn_request_scan(struct iwl_priv *priv, s=
truct ieee80211_vif *vif)
 	struct iwl_scan_cmd *scan;
 	struct iwl_rxon_context *ctx =3D &priv->contexts[IWL_RXON_CTX_BSS];
 	u32 rate_flags =3D 0;
-	u16 cmd_len;
+	u16 cmd_len =3D 0;
 	u16 rx_chain =3D 0;
 	enum ieee80211_band band;
 	u8 n_probes =3D 0;
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 7becea3..dd5aeaf 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -2777,7 +2777,7 @@ static int mwl8k_cmd_tx_power(struct ieee80211_hw *hw,
 	else if (channel->band =3D=3D IEEE80211_BAND_5GHZ)
 		cmd->band =3D cpu_to_le16(0x4);
=20
-	cmd->channel =3D channel->hw_value;
+	cmd->channel =3D cpu_to_le16(channel->hw_value);
=20
 	if (conf->channel_type =3D=3D NL80211_CHAN_NO_HT ||
 	    conf->channel_type =3D=3D NL80211_CHAN_HT20) {
@@ -4066,7 +4066,7 @@ static int mwl8k_cmd_encryption_remove_key(struct iee=
e80211_hw *hw,
 		goto done;
=20
 	if (key->cipher =3D=3D WLAN_CIPHER_SUITE_WEP40 ||
-			WLAN_CIPHER_SUITE_WEP104)
+			key->cipher =3D=3D WLAN_CIPHER_SUITE_WEP104)
 		mwl8k_vif->wep_key_conf[key->keyidx].enabled =3D 0;
=20
 	cmd->action =3D cpu_to_le32(MWL8K_ENCR_REMOVE_KEY);
diff --git a/drivers/net/wireless/rt2x00/rt2800pci.c b/drivers/net/wireless=
/rt2x00/rt2800pci.c
index 4941a1a..dc88bae 100644
--- a/drivers/net/wireless/rt2x00/rt2800pci.c
+++ b/drivers/net/wireless/rt2x00/rt2800pci.c
@@ -422,7 +422,6 @@ static int rt2800pci_init_queues(struct rt2x00_dev *rt2=
x00dev)
 static void rt2800pci_toggle_irq(struct rt2x00_dev *rt2x00dev,
 				 enum dev_state state)
 {
-	int mask =3D (state =3D=3D STATE_RADIO_IRQ_ON);
 	u32 reg;
 	unsigned long flags;
=20
@@ -436,25 +435,14 @@ static void rt2800pci_toggle_irq(struct rt2x00_dev *r=
t2x00dev,
 	}
=20
 	spin_lock_irqsave(&rt2x00dev->irqmask_lock, flags);
-	rt2x00pci_register_read(rt2x00dev, INT_MASK_CSR, &reg);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RXDELAYINT, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TXDELAYINT, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RX_DONE, mask);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_AC0_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_AC1_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_AC2_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_AC3_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_HCCA_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_MGMT_DMA_DONE, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_MCU_COMMAND, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RXTX_COHERENT, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TBTT, mask);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_PRE_TBTT, mask);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TX_FIFO_STATUS, mask);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_AUTO_WAKEUP, mask);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_GPTIMER, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_RX_COHERENT, 0);
-	rt2x00_set_field32(&reg, INT_MASK_CSR_TX_COHERENT, 0);
+	reg =3D 0;
+	if (state =3D=3D STATE_RADIO_IRQ_ON) {
+		rt2x00_set_field32(&reg, INT_MASK_CSR_RX_DONE, 1);
+		rt2x00_set_field32(&reg, INT_MASK_CSR_TBTT, 1);
+		rt2x00_set_field32(&reg, INT_MASK_CSR_PRE_TBTT, 1);
+		rt2x00_set_field32(&reg, INT_MASK_CSR_TX_FIFO_STATUS, 1);
+		rt2x00_set_field32(&reg, INT_MASK_CSR_AUTO_WAKEUP, 1);
+	}
 	rt2x00pci_register_write(rt2x00dev, INT_MASK_CSR, reg);
 	spin_unlock_irqrestore(&rt2x00dev->irqmask_lock, flags);
=20
diff --git a/include/linux/bcma/bcma.h b/include/linux/bcma/bcma.h
index f4b8346..83c209f 100644
--- a/include/linux/bcma/bcma.h
+++ b/include/linux/bcma/bcma.h
@@ -162,7 +162,7 @@ struct bcma_driver {
=20
 	int (*probe)(struct bcma_device *dev);
 	void (*remove)(struct bcma_device *dev);
-	int (*suspend)(struct bcma_device *dev, pm_message_t state);
+	int (*suspend)(struct bcma_device *dev);
 	int (*resume)(struct bcma_device *dev);
 	void (*shutdown)(struct bcma_device *dev);
=20
diff --git a/net/mac80211/cfg.c b/net/mac80211/cfg.c
index e60df48..296620d 100644
--- a/net/mac80211/cfg.c
+++ b/net/mac80211/cfg.c
@@ -791,7 +791,7 @@ static int sta_apply_parameters(struct ieee80211_local =
*local,
 		if (set & BIT(NL80211_STA_FLAG_AUTHORIZED))
 			ret =3D sta_info_move_state_checked(sta,
 					IEEE80211_STA_AUTHORIZED);
-		else
+		else if (test_sta_flag(sta, WLAN_STA_AUTHORIZED))
 			ret =3D sta_info_move_state_checked(sta,
 					IEEE80211_STA_ASSOC);
 		if (ret)
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index f407427..7514091 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1979,6 +1979,7 @@ ieee80211_rx_h_mesh_fwding(struct ieee80211_rx_data *=
rx)
 		mesh_path_error_tx(ifmsh->mshcfg.element_ttl, fwd_hdr->addr3,
 				    0, reason, fwd_hdr->addr2, sdata);
 		IEEE80211_IFSTA_MESH_CTR_INC(ifmsh, dropped_frames_no_route);
+		kfree_skb(fwd_skb);
 		return RX_DROP_MONITOR;
 	}
=20
diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 3c428d4..ff11f6b 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -238,9 +238,11 @@ static void sta_unblock(struct work_struct *wk)
 	if (sta->dead)
 		return;
=20
-	if (!test_sta_flag(sta, WLAN_STA_PS_STA))
+	if (!test_sta_flag(sta, WLAN_STA_PS_STA)) {
+		local_bh_disable();
 		ieee80211_sta_ps_deliver_wakeup(sta);
-	else if (test_and_clear_sta_flag(sta, WLAN_STA_PSPOLL)) {
+		local_bh_enable();
+	} else if (test_and_clear_sta_flag(sta, WLAN_STA_PSPOLL)) {
 		clear_sta_flag(sta, WLAN_STA_PS_DRIVER);
=20
 		local_bh_disable();
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index edcd1c7..e05667c 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -1001,8 +1001,6 @@ ieee80211_tx_h_stats(struct ieee80211_tx_data *tx)
 static ieee80211_tx_result debug_noinline
 ieee80211_tx_h_encrypt(struct ieee80211_tx_data *tx)
 {
-	struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(tx->skb);
-
 	if (!tx->key)
 		return TX_CONTINUE;
=20
@@ -1017,13 +1015,7 @@ ieee80211_tx_h_encrypt(struct ieee80211_tx_data *tx)
 	case WLAN_CIPHER_SUITE_AES_CMAC:
 		return ieee80211_crypto_aes_cmac_encrypt(tx);
 	default:
-		/* handle hw-only algorithm */
-		if (info->control.hw_key) {
-			ieee80211_tx_set_protected(tx);
-			return TX_CONTINUE;
-		}
-		break;
-
+		return ieee80211_crypto_hw_encrypt(tx);
 	}
=20
 	return TX_DROP;
diff --git a/net/mac80211/wpa.c b/net/mac80211/wpa.c
index 422b798..b758350 100644
--- a/net/mac80211/wpa.c
+++ b/net/mac80211/wpa.c
@@ -643,3 +643,22 @@ ieee80211_crypto_aes_cmac_decrypt(struct ieee80211_rx_=
data *rx)
=20
 	return RX_CONTINUE;
 }
+
+ieee80211_tx_result
+ieee80211_crypto_hw_encrypt(struct ieee80211_tx_data *tx)
+{
+	struct sk_buff *skb;
+	struct ieee80211_tx_info *info =3D NULL;
+
+	skb_queue_walk(&tx->skbs, skb) {
+		info  =3D IEEE80211_SKB_CB(skb);
+
+		/* handle hw-only algorithm */
+		if (!info->control.hw_key)
+			return TX_DROP;
+	}
+
+	ieee80211_tx_set_protected(tx);
+
+	return TX_CONTINUE;
+}
diff --git a/net/mac80211/wpa.h b/net/mac80211/wpa.h
index baba060..07e33f8 100644
--- a/net/mac80211/wpa.h
+++ b/net/mac80211/wpa.h
@@ -32,5 +32,7 @@ ieee80211_tx_result
 ieee80211_crypto_aes_cmac_encrypt(struct ieee80211_tx_data *tx);
 ieee80211_rx_result
 ieee80211_crypto_aes_cmac_decrypt(struct ieee80211_rx_data *rx);
+ieee80211_tx_result
+ieee80211_crypto_hw_encrypt(struct ieee80211_tx_data *tx);
=20
 #endif /* WPA_H */
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--IrhDeMKUP4DT/M7F
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPFZfVAAoJEJctW/TcYTgGRRkP/1YejDXCkuWelGqDI1MrKfFw
3kXIen//wkSVmnbGXHhV7kKVitiTeczOLweRbmjXb4U/ELf1NlFlEKRVHEal1Ipp
0++Sb+LqEa85T1sonOnJKVYbIh96CF+pzs5hYEPutrGF5Nlbt5zttWevd6lppPo6
YwW8CQ2mBvYaPSZoVgohPRBQoajb23iqFxV6Dc4cd71GD04p1OrnUEdRr1B1RGqp
2a6S2tCSmwf2fmYSRHsusoT2dniWiSaZz9PnjbFrFiWPC3OQjIq6f3R/lhdmlcZy
hTZM3sSmvNDCDr2wZ0EvTP66q+mxB+uEaUKh6M9RtAbG4Q3Min82mC79RSIqo3mv
Rg1WwoB6L+IA97kJn1uZLDLz08KWDfRCoTaEJQi2ZAyOpCmpPtSrZa1ti4ueBxNp
aMghgWydJCgpnuT5ryfttSrOIj1lpQxcIP4S+i+Q62Qw48iK4Dp5k7uwHJ1Y7qyH
C4VlWAU+m7Nog1U0ZZ6AkLSR7zaNGQQHYGllT4TzJjKWGymZtmO9bqakCLoOQnYY
+86ZpKoxJkXc/UBdyEUn5ST/2hlX3jeHpTierYkOvGkQ3bUGIMcE0rs2bIcp/aVS
iynl4J51EHtJvSaCUCQQ/veGqN9PMj4wc0hmfQ0kxO7O9u4mSON9q+/vFTOnWBS4
7BVa3/3Tjhct3Fff3Gdi
=w2Qf
-----END PGP SIGNATURE-----

--IrhDeMKUP4DT/M7F--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
