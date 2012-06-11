From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-06-11
Date: Mon, 11 Jun 2012 15:17:18 -0400
Message-ID: <20120611191718.GD30086@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gatW/ieO32f1wygP"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gatW/ieO32f1wygP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit ed6be3dcfee0bb891efd6ea908ca32bea711085b

Dave,

Here is another group of fixes intended for 3.5.

Emmanuel Grumbach brings a fix to avoid some firmware memory
corruption, and he disables a problematic hardware feature in the
iwlwifi driver.

Hauke Mehrtens fixes a null pointer dereference in bcma.

Johannes Berg updates MAINTAINERS to reflect that he is now maintaining
separate feeder trees for the wireless stack components.

Meenakshi Venkataraman points iwlwifi to the correct firmware for
the 6035 device.

Oleksij Rempel prevents b43 from calling ieee80211_unregister_hw if
they haven't registered any hardware, avoiding a BUG exit.

Qasim Javed fixes mac80211_hwsim to maintain ACK stats appropriately.

Sasha Levin fixes a possible null pointer dereference in the NFC code.

Stanislav Yakovlev avoids a WARN_ON in ipw2100, mirroring a similar
fix already applied to ipw2200.

Stanislaw Gruszka avoids an rtl8187 bug with sleeping in an invalid
context.  He also restores a previously removed mac80211 flag that
is needed by the iwl4965 driver.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 16b0dc29c1af9df341428f4c49ada4f626258082:

  dummy: fix rcu_sched self-detected stalls (2012-06-11 01:12:04 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Emmanuel Grumbach (2):
      iwlwifi: don't mess up the SCD when removing a key
      iwlwifi: disable the buggy chain extension feature in HW

Hauke Mehrtens (1):
      bcma: fix null pointer in bcma_core_pci_irq_ctl

Johannes Berg (1):
      wireless: add my new trees to MAINTAINERS

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Meenakshi Venkataraman (1):
      iwlwifi: use correct supported firmware for 6035 and 6000g2

Oleksij Rempel (1):
      b43: do not call ieee80211_unregister_hw if we are not registred

Qasim Javed (1):
      mac80211_hwsim: Set IEEE80211_STAT_ACK flag when userspace indicates =
that the frame has been acknowledged.

Sasha Levin (1):
      NFC: Fix possible NULL ptr deref when getting the name of a socket

Stanislav Yakovlev (1):
      net/wireless: ipw2100: Fix WARN_ON occurring in wiphy_register called=
 by ipw2100_pci_init_one

Stanislaw Gruszka (2):
      rtl8187: ->brightness_set can not sleep
      mac80211: add back channel change flag

 MAINTAINERS                                   |   12 ++++++++++--
 drivers/bcma/driver_pci.c                     |    6 ++++--
 drivers/net/wireless/b43/b43.h                |    4 ++++
 drivers/net/wireless/b43/main.c               |   19 ++++++++++++-------
 drivers/net/wireless/ipw2x00/ipw2100.c        |   20 +++++---------------
 drivers/net/wireless/iwlwifi/iwl-6000.c       |   23 +++++++++++++++++++++=
--
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c    |    2 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h       |    1 +
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c |    5 +++++
 drivers/net/wireless/mac80211_hwsim.c         |    1 +
 drivers/net/wireless/rtl818x/rtl8187/leds.c   |    2 +-
 net/mac80211/mlme.c                           |    2 +-
 net/nfc/llcp/sock.c                           |    3 +++
 13 files changed, 69 insertions(+), 31 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 55f0fda..03660de 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1800,6 +1800,9 @@ F:	include/linux/cfag12864b.h
 CFG80211 and NL80211
 M:	Johannes Berg <johannes@sipsolutions.net>
 L:	linux-wireless@vger.kernel.org
+W:	http://wireless.kernel.org/
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.g=
it
 S:	Maintained
 F:	include/linux/nl80211.h
 F:	include/net/cfg80211.h
@@ -4340,7 +4343,8 @@ MAC80211
 M:	Johannes Berg <johannes@sipsolutions.net>
 L:	linux-wireless@vger.kernel.org
 W:	http://linuxwireless.org/
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.g=
it
 S:	Maintained
 F:	Documentation/networking/mac80211-injection.txt
 F:	include/net/mac80211.h
@@ -4351,7 +4355,8 @@ M:	Stefano Brivio <stefano.brivio@polimi.it>
 M:	Mattias Nissler <mattias.nissler@gmx.de>
 L:	linux-wireless@vger.kernel.org
 W:	http://linuxwireless.org/en/developers/Documentation/mac80211/RateContr=
ol/PID
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.g=
it
 S:	Maintained
 F:	net/mac80211/rc80211_pid*
=20
@@ -5695,6 +5700,9 @@ F:	include/linux/remoteproc.h
 RFKILL
 M:	Johannes Berg <johannes@sipsolutions.net>
 L:	linux-wireless@vger.kernel.org
+W:	http://wireless.kernel.org/
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jberg/mac80211-next.g=
it
 S:	Maintained
 F:	Documentation/rfkill.txt
 F:	net/rfkill/
diff --git a/drivers/bcma/driver_pci.c b/drivers/bcma/driver_pci.c
index 9a96f14..c32ebd5 100644
--- a/drivers/bcma/driver_pci.c
+++ b/drivers/bcma/driver_pci.c
@@ -232,17 +232,19 @@ void __devinit bcma_core_pci_init(struct bcma_drv_pci=
 *pc)
 int bcma_core_pci_irq_ctl(struct bcma_drv_pci *pc, struct bcma_device *cor=
e,
 			  bool enable)
 {
-	struct pci_dev *pdev =3D pc->core->bus->host_pci;
+	struct pci_dev *pdev;
 	u32 coremask, tmp;
 	int err =3D 0;
=20
-	if (core->bus->hosttype !=3D BCMA_HOSTTYPE_PCI) {
+	if (!pc || core->bus->hosttype !=3D BCMA_HOSTTYPE_PCI) {
 		/* This bcma device is not on a PCI host-bus. So the IRQs are
 		 * not routed through the PCI core.
 		 * So we must not enable routing through the PCI core. */
 		goto out;
 	}
=20
+	pdev =3D pc->core->bus->host_pci;
+
 	err =3D pci_read_config_dword(pdev, BCMA_PCI_IRQMASK, &tmp);
 	if (err)
 		goto out;
diff --git a/drivers/net/wireless/b43/b43.h b/drivers/net/wireless/b43/b43.h
index 67c13af..c06b6cb 100644
--- a/drivers/net/wireless/b43/b43.h
+++ b/drivers/net/wireless/b43/b43.h
@@ -877,6 +877,10 @@ struct b43_wl {
 	 * from the mac80211 subsystem. */
 	u16 mac80211_initially_registered_queues;
=20
+	/* Set this if we call ieee80211_register_hw() and check if we call
+	 * ieee80211_unregister_hw(). */
+	bool hw_registred;
+
 	/* We can only have one operating interface (802.11 core)
 	 * at a time. General information about this interface follows.
 	 */
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/mai=
n.c
index 5a39b22..acd03a4 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -2437,6 +2437,7 @@ start_ieee80211:
 	err =3D ieee80211_register_hw(wl->hw);
 	if (err)
 		goto err_one_core_detach;
+	wl->hw_registred =3D true;
 	b43_leds_register(wl->current_dev);
 	goto out;
=20
@@ -5299,6 +5300,7 @@ static struct b43_wl *b43_wireless_init(struct b43_bu=
s_dev *dev)
=20
 	hw->queues =3D modparam_qos ? B43_QOS_QUEUE_NUM : 1;
 	wl->mac80211_initially_registered_queues =3D hw->queues;
+	wl->hw_registred =3D false;
 	hw->max_rates =3D 2;
 	SET_IEEE80211_DEV(hw, dev->dev);
 	if (is_valid_ether_addr(sprom->et1mac))
@@ -5370,12 +5372,15 @@ static void b43_bcma_remove(struct bcma_device *cor=
e)
 	 * as the ieee80211 unreg will destroy the workqueue. */
 	cancel_work_sync(&wldev->restart_work);
=20
-	/* Restore the queues count before unregistering, because firmware detect
-	 * might have modified it. Restoring is important, so the networking
-	 * stack can properly free resources. */
-	wl->hw->queues =3D wl->mac80211_initially_registered_queues;
-	b43_leds_stop(wldev);
-	ieee80211_unregister_hw(wl->hw);
+	B43_WARN_ON(!wl);
+	if (wl->current_dev =3D=3D wldev && wl->hw_registred) {
+		/* Restore the queues count before unregistering, because firmware detect
+		 * might have modified it. Restoring is important, so the networking
+		 * stack can properly free resources. */
+		wl->hw->queues =3D wl->mac80211_initially_registered_queues;
+		b43_leds_stop(wldev);
+		ieee80211_unregister_hw(wl->hw);
+	}
=20
 	b43_one_core_detach(wldev->dev);
=20
@@ -5446,7 +5451,7 @@ static void b43_ssb_remove(struct ssb_device *sdev)
 	cancel_work_sync(&wldev->restart_work);
=20
 	B43_WARN_ON(!wl);
-	if (wl->current_dev =3D=3D wldev) {
+	if (wl->current_dev =3D=3D wldev && wl->hw_registred) {
 		/* Restore the queues count before unregistering, because firmware detect
 		 * might have modified it. Restoring is important, so the networking
 		 * stack can properly free resources. */
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/=
ipw2x00/ipw2100.c
index 9cfae0c..95aa8e1 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -1903,14 +1903,6 @@ static void ipw2100_down(struct ipw2100_priv *priv)
 	netif_stop_queue(priv->net_dev);
 }
=20
-/* Called by register_netdev() */
-static int ipw2100_net_init(struct net_device *dev)
-{
-	struct ipw2100_priv *priv =3D libipw_priv(dev);
-
-	return ipw2100_up(priv, 1);
-}
-
 static int ipw2100_wdev_init(struct net_device *dev)
 {
 	struct ipw2100_priv *priv =3D libipw_priv(dev);
@@ -6087,7 +6079,6 @@ static const struct net_device_ops ipw2100_netdev_ops=
 =3D {
 	.ndo_stop		=3D ipw2100_close,
 	.ndo_start_xmit		=3D libipw_xmit,
 	.ndo_change_mtu		=3D libipw_change_mtu,
-	.ndo_init		=3D ipw2100_net_init,
 	.ndo_tx_timeout		=3D ipw2100_tx_timeout,
 	.ndo_set_mac_address	=3D ipw2100_set_address,
 	.ndo_validate_addr	=3D eth_validate_addr,
@@ -6329,6 +6320,10 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_=
dev,
 	printk(KERN_INFO DRV_NAME
 	       ": Detected Intel PRO/Wireless 2100 Network Connection\n");
=20
+	err =3D ipw2100_up(priv, 1);
+	if (err)
+		goto fail;
+
 	err =3D ipw2100_wdev_init(dev);
 	if (err)
 		goto fail;
@@ -6338,12 +6333,7 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_=
dev,
 	 * network device we would call ipw2100_up.  This introduced a race
 	 * condition with newer hotplug configurations (network was coming
 	 * up and making calls before the device was initialized).
-	 *
-	 * If we called ipw2100_up before we registered the device, then the
-	 * device name wasn't registered.  So, we instead use the net_dev->init
-	 * member to call a function that then just turns and calls ipw2100_up.
-	 * net_dev->init is called after name allocation but before the
-	 * notifier chain is called */
+	 */
 	err =3D register_netdev(dev);
 	if (err) {
 		printk(KERN_WARNING DRV_NAME
diff --git a/drivers/net/wireless/iwlwifi/iwl-6000.c b/drivers/net/wireless=
/iwlwifi/iwl-6000.c
index 19f7ee8..e5e8ada 100644
--- a/drivers/net/wireless/iwlwifi/iwl-6000.c
+++ b/drivers/net/wireless/iwlwifi/iwl-6000.c
@@ -35,17 +35,20 @@
 #define IWL6000_UCODE_API_MAX 6
 #define IWL6050_UCODE_API_MAX 5
 #define IWL6000G2_UCODE_API_MAX 6
+#define IWL6035_UCODE_API_MAX 6
=20
 /* Oldest version we won't warn about */
 #define IWL6000_UCODE_API_OK 4
 #define IWL6000G2_UCODE_API_OK 5
 #define IWL6050_UCODE_API_OK 5
 #define IWL6000G2B_UCODE_API_OK 6
+#define IWL6035_UCODE_API_OK 6
=20
 /* Lowest firmware API version supported */
 #define IWL6000_UCODE_API_MIN 4
 #define IWL6050_UCODE_API_MIN 4
-#define IWL6000G2_UCODE_API_MIN 4
+#define IWL6000G2_UCODE_API_MIN 5
+#define IWL6035_UCODE_API_MIN 6
=20
 /* EEPROM versions */
 #define EEPROM_6000_TX_POWER_VERSION	(4)
@@ -227,9 +230,25 @@ const struct iwl_cfg iwl6030_2bg_cfg =3D {
 	IWL_DEVICE_6030,
 };
=20
+#define IWL_DEVICE_6035						\
+	.fw_name_pre =3D IWL6030_FW_PRE,				\
+	.ucode_api_max =3D IWL6035_UCODE_API_MAX,			\
+	.ucode_api_ok =3D IWL6035_UCODE_API_OK,			\
+	.ucode_api_min =3D IWL6035_UCODE_API_MIN,			\
+	.device_family =3D IWL_DEVICE_FAMILY_6030,		\
+	.max_inst_size =3D IWL60_RTC_INST_SIZE,			\
+	.max_data_size =3D IWL60_RTC_DATA_SIZE,			\
+	.eeprom_ver =3D EEPROM_6030_EEPROM_VERSION,		\
+	.eeprom_calib_ver =3D EEPROM_6030_TX_POWER_VERSION,	\
+	.base_params =3D &iwl6000_g2_base_params,			\
+	.bt_params =3D &iwl6000_bt_params,			\
+	.need_temp_offset_calib =3D true,				\
+	.led_mode =3D IWL_LED_RF_STATE,				\
+	.adv_pm =3D true
+
 const struct iwl_cfg iwl6035_2agn_cfg =3D {
 	.name =3D "Intel(R) Centrino(R) Advanced-N 6235 AGN",
-	IWL_DEVICE_6030,
+	IWL_DEVICE_6035,
 	.ht_params =3D &iwl6000_ht_params,
 };
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c b/drivers/net/wirel=
ess/iwlwifi/iwl-agn-sta.c
index aea07aa..eb6a8ea 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-sta.c
@@ -1267,7 +1267,7 @@ int iwl_remove_dynamic_key(struct iwl_priv *priv,
 		key_flags |=3D STA_KEY_MULTICAST_MSK;
=20
 	sta_cmd.key.key_flags =3D key_flags;
-	sta_cmd.key.key_offset =3D WEP_INVALID_OFFSET;
+	sta_cmd.key.key_offset =3D keyconf->hw_key_idx;
 	sta_cmd.sta.modify_mask =3D STA_MODIFY_KEY_MASK;
 	sta_cmd.mode =3D STA_CONTROL_MODIFY_MSK;
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-prph.h b/drivers/net/wireless=
/iwlwifi/iwl-prph.h
index 3b10692..dfd5466 100644
--- a/drivers/net/wireless/iwlwifi/iwl-prph.h
+++ b/drivers/net/wireless/iwlwifi/iwl-prph.h
@@ -224,6 +224,7 @@
 #define SCD_TXFACT		(SCD_BASE + 0x10)
 #define SCD_ACTIVE		(SCD_BASE + 0x14)
 #define SCD_QUEUECHAIN_SEL	(SCD_BASE + 0xe8)
+#define SCD_CHAINEXT_EN		(SCD_BASE + 0x244)
 #define SCD_AGGR_SEL		(SCD_BASE + 0x248)
 #define SCD_INTERRUPT_MASK	(SCD_BASE + 0x108)
=20
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c b/drivers/net/wi=
reless/iwlwifi/iwl-trans-pcie.c
index ec6fb39..79c6b91 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
@@ -1058,6 +1058,11 @@ static void iwl_tx_start(struct iwl_trans *trans)
 	iwl_write_prph(trans, SCD_DRAM_BASE_ADDR,
 		       trans_pcie->scd_bc_tbls.dma >> 10);
=20
+	/* The chain extension of the SCD doesn't work well. This feature is
+	 * enabled by default by the HW, so we need to disable it manually.
+	 */
+	iwl_write_prph(trans, SCD_CHAINEXT_EN, 0);
+
 	/* Enable DMA channel */
 	for (chan =3D 0; chan < FH_TCSR_CHNL_NUM ; chan++)
 		iwl_write_direct32(trans, FH_TCSR_CHNL_TX_CONFIG_REG(chan),
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/m=
ac80211_hwsim.c
index 4c9336c..a0b7cfd 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -1555,6 +1555,7 @@ static int hwsim_tx_info_frame_received_nl(struct sk_=
buff *skb_2,
 			hdr =3D (struct ieee80211_hdr *) skb->data;
 			mac80211_hwsim_monitor_ack(data2->hw, hdr->addr2);
 		}
+		txi->flags |=3D IEEE80211_TX_STAT_ACK;
 	}
 	ieee80211_tx_status_irqsafe(data2->hw, skb);
 	return 0;
diff --git a/drivers/net/wireless/rtl818x/rtl8187/leds.c b/drivers/net/wire=
less/rtl818x/rtl8187/leds.c
index 2e0de2f..c2d5b49 100644
--- a/drivers/net/wireless/rtl818x/rtl8187/leds.c
+++ b/drivers/net/wireless/rtl818x/rtl8187/leds.c
@@ -117,7 +117,7 @@ static void rtl8187_led_brightness_set(struct led_class=
dev *led_dev,
 			radio_on =3D true;
 		} else if (radio_on) {
 			radio_on =3D false;
-			cancel_delayed_work_sync(&priv->led_on);
+			cancel_delayed_work(&priv->led_on);
 			ieee80211_queue_delayed_work(hw, &priv->led_off, 0);
 		}
 	} else if (radio_on) {
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index d94627c..91d84cc 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3124,7 +3124,7 @@ static int ieee80211_prep_connection(struct ieee80211=
_sub_if_data *sdata,
 	}
=20
 	local->oper_channel =3D cbss->channel;
-	ieee80211_hw_config(local, 0);
+	ieee80211_hw_config(local, IEEE80211_CONF_CHANGE_CHANNEL);
=20
 	if (!have_sta) {
 		u32 rates =3D 0, basic_rates =3D 0;
diff --git a/net/nfc/llcp/sock.c b/net/nfc/llcp/sock.c
index 3f339b1..17a707d 100644
--- a/net/nfc/llcp/sock.c
+++ b/net/nfc/llcp/sock.c
@@ -292,6 +292,9 @@ static int llcp_sock_getname(struct socket *sock, struc=
t sockaddr *addr,
=20
 	pr_debug("%p\n", sk);
=20
+	if (llcp_sock =3D=3D NULL)
+		return -EBADFD;
+
 	addr->sa_family =3D AF_NFC;
 	*len =3D sizeof(struct sockaddr_nfc_llcp);
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--gatW/ieO32f1wygP
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJP1kQ+AAoJEJctW/TcYTgG00AP/RJZT5ywKoVgVb/1rvJjLLvc
vOAAkWoaNYfn/pFq5bEUDq0zP8g0oBci2+UJ/RawNAceOkqVNurWfCx/FX3CJbth
q0mAl5GaJE8exPuqs/bdgLczGFK0+vEw635rEUXmQA8CSNLMHL96EgYUYFEZvrx+
Uoj0p8aLiQ4QtHrcVjr53n63Yx3LozbAFvNIlb8OnCbHNJqhR/iAaznWJtpNLM+7
RFmVVjYQOLGExalpKl151U6E9/rwM3K6vpVgpW8y4DUT6FdglhcIMzlS3Aje2CKx
7hog/SKZ1bfAifGPVS8HyKgqgBQ6/SAj8g1oJpbvC/MJBAeagFjDmyKyK1dPPIbU
ydKFPH0KtEpQytfw9r3wlfuAu2p7sU35+HjiEE7tl1rbjG43EhxHU4PrIvuFaFt/
kWZ+hUIXZAWZwOhXIVSmaxz4Y5z3R4cPwJN9dtZ4UQf3FnZD3EIWIxB31KKemZXv
6ZtavX5oFl0vpAEFr0VJyV4shhBB0b3Em7cN2tpwZZMNQqpm+1oUaO1mEvdcM6Ah
t1YFArIhk3irlRLYXfB12CcVVhE0hdY3u5p/Drox9wFqqq1RBlJ1LcLUbhbVwloX
kztCOOJ+OVyUBxNusdvuHyzvabTp4mopP9t0gePfUfKwcNFB7e3BNUPwS8iryDL7
tIrgMtXqKRN2tHRwE3KL
=WE1o
-----END PGP SIGNATURE-----

--gatW/ieO32f1wygP--
