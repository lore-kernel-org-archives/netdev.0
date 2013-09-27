From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2013-09-27
Date: Fri, 27 Sep 2013 14:05:49 -0400
Message-ID: <20130927180549.GB10994@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6c2NcOVqGQ03X4Wi"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.12 stream!

Regarding the Bluetooth bits, Gustavo says:

"First Bluetooth fixes to 3.12, it includes:

* 3 patches to add device id for 3 new hardwares.

* 2 patches from Johan to fix the rfkill behaviour during setup stage

* a small clean up in the rfcomm TTY code that fixes a potential racy
condition (by Gianluca Anzolin)

* 2 fixes to proper set encryption key size and security level in the
peripheral role of Bluetooth LE devices. (by Andre Guedes)

* a fix for dealing devices where pairing is not necessary, we were keeping
the Bluetooth ACL connection alive for too much time. (by Syam Sidhardhan)"

Also, I fixed-up an curly-brace indentation problem in the Bluetooth
code while merging.  On top of that...

Alexey Khoroshilov brings a p54usb fix to avoid a resource leak when
request_firmware_nowait fails.

Amitkumar Karwar fixes a firmware hang caused by too much header data
being appended for USB devices using the mwifiex driver.

Arend van Spriel provides three fixes: a brcmfmac fix to relocate some
driver code outside of an .init section; a scheduling while atomic
fix for bcma; and, another scheduling while atomic fix for brcmsmac.

Bing Zhao offers a pair of mwifiex fixes: a code change to avoid
firmware timeouts on USB; and a fix for a NULL pointer dereference.

Christian Lamparter adds a device ID to p54usb.

Felix Fietkau implements a quartet of small ath9k fixes, including
a locking fix, a list management fix, a fix to properly mark a stale
buffer, and an aggregate buffering fix.

Larry Finger champions a data alignment fix to make rtlwifi work
better with ARM builds.

Solomon Peachy reverts an earlier interrupt handling fix for cw1200
and replaces it with a new threaded oneshot irq handler implementation.

Sujith Manoharan fixes an ath9k regression by reverting an earlier
patch.

Please let me know if there are problems!

John

---

The following changes since commit f875691640cd3fa67f7ad1d3130ff9fa7fdca042:

  Merge branch 'fixes-for-3.12' of git://gitorious.org/linux-can/linux-can =
(2013-09-27 02:08:03 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 0a878747e18d4d14c5b772dcddddd86bb4c26f8f:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-09-27 13:11:17 -0400)

----------------------------------------------------------------

Alexey Khoroshilov (1):
      p54usb: fix leak at failure path in p54u_load_firmware()

Amitkumar Karwar (1):
      mwifiex: fix hang issue for USB chipsets

Andre Guedes (2):
      Bluetooth: Fix security level for peripheral role
      Bluetooth: Fix encryption key size for peripheral role

Arend van Spriel (3):
      brcmfmac: obtain platform data upon module initialization
      bcma: make bcma_core_pci_{up,down}() callable from atomic context
      brcmsmac: call bcma_core_pci_power_save() from non-atomic context

Bing Zhao (2):
      mwifiex: fix PCIe hs_cfg cancel cmd timeout
      mwifiex: fix NULL pointer dereference in usb suspend handler

Christian Lamparter (1):
      p54usb: add USB ID for Corega WLUSB2GTST USB adapter

Felix Fietkau (4):
      ath9k: fix stale flag handling on buffer clone
      ath9k: do not link bf_next across multiple A-MPDUs
      ath9k: don't use BAW tracking on PS responses for non-AMPDU packets
      ath9k: add txq locking for ath_tx_aggr_start

Gianluca Anzolin (1):
      Bluetooth: don't release the port in rfcomm_dev_state_change()

Johan Hedberg (2):
      Bluetooth: Introduce a new HCI_RFKILLED flag
      Bluetooth: Fix rfkill functionality during the HCI setup stage

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Ken O'Brien (1):
      Bluetooth: btusb: Add support for Belkin F8065bf

Larry Finger (1):
      rtlwifi: Align private space in rtl_priv struct

Peng Chen (1):
      Bluetooth: Add a new PID/VID 0cf3/e005 for AR3012.

Raphael Kubo da Costa (1):
      Bluetooth: Add support for BCM20702A0 [0b05, 17cb]

Solomon Peachy (2):
      Revert "cw1200: Don't perform SPI transfers in interrupt context"
      cw1200: Use a threaded oneshot irq handler for cw1200_spi

Sujith Manoharan (1):
      ath9k: Fix regression in LNA diversity

Syam Sidhardhan (1):
      Bluetooth: Fix ACL alive for long in case of non pariable devices

 drivers/bcma/driver_pci.c                          | 49 ++++++++++++------=
----
 drivers/bluetooth/ath3k.c                          |  2 +
 drivers/bluetooth/btusb.c                          |  5 +++
 drivers/net/wireless/ath/ath9k/recv.c              |  7 ----
 drivers/net/wireless/ath/ath9k/xmit.c              | 17 ++++++--
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c | 28 ++++++-------
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |  3 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    | 14 ++++---
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |  2 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |  4 ++
 drivers/net/wireless/cw1200/cw1200_spi.c           | 26 ++++--------
 drivers/net/wireless/cw1200/fwio.c                 |  2 +-
 drivers/net/wireless/cw1200/hwbus.h                |  1 -
 drivers/net/wireless/cw1200/hwio.c                 | 15 -------
 drivers/net/wireless/mwifiex/11n_aggr.c            |  3 +-
 drivers/net/wireless/mwifiex/11n_aggr.h            |  2 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |  5 +--
 drivers/net/wireless/mwifiex/usb.c                 |  7 ----
 drivers/net/wireless/mwifiex/wmm.c                 |  3 +-
 drivers/net/wireless/p54/p54usb.c                  |  2 +
 drivers/net/wireless/rtlwifi/wifi.h                |  2 +-
 include/linux/bcma/bcma_driver_pci.h               |  1 +
 include/net/bluetooth/hci.h                        |  1 +
 net/bluetooth/hci_core.c                           | 26 +++++++++---
 net/bluetooth/hci_event.c                          |  6 ++-
 net/bluetooth/l2cap_core.c                         |  7 ++++
 net/bluetooth/rfcomm/tty.c                         | 35 +---------------
 27 files changed, 128 insertions(+), 147 deletions(-)

diff --git a/drivers/bcma/driver_pci.c b/drivers/bcma/driver_pci.c
index c9fd694..50329d1 100644
--- a/drivers/bcma/driver_pci.c
+++ b/drivers/bcma/driver_pci.c
@@ -210,25 +210,6 @@ static void bcma_core_pci_config_fixup(struct bcma_drv=
_pci *pc)
 	}
 }
=20
-static void bcma_core_pci_power_save(struct bcma_drv_pci *pc, bool up)
-{
-	u16 data;
-
-	if (pc->core->id.rev >=3D 15 && pc->core->id.rev <=3D 20) {
-		data =3D up ? 0x74 : 0x7C;
-		bcma_pcie_mdio_writeread(pc, BCMA_CORE_PCI_MDIO_BLK1,
-					 BCMA_CORE_PCI_MDIO_BLK1_MGMT1, 0x7F64);
-		bcma_pcie_mdio_writeread(pc, BCMA_CORE_PCI_MDIO_BLK1,
-					 BCMA_CORE_PCI_MDIO_BLK1_MGMT3, data);
-	} else if (pc->core->id.rev >=3D 21 && pc->core->id.rev <=3D 22) {
-		data =3D up ? 0x75 : 0x7D;
-		bcma_pcie_mdio_writeread(pc, BCMA_CORE_PCI_MDIO_BLK1,
-					 BCMA_CORE_PCI_MDIO_BLK1_MGMT1, 0x7E65);
-		bcma_pcie_mdio_writeread(pc, BCMA_CORE_PCI_MDIO_BLK1,
-					 BCMA_CORE_PCI_MDIO_BLK1_MGMT3, data);
-	}
-}
-
 /**************************************************
  * Init.
  **************************************************/
@@ -255,6 +236,32 @@ void bcma_core_pci_init(struct bcma_drv_pci *pc)
 		bcma_core_pci_clientmode_init(pc);
 }
=20
+void bcma_core_pci_power_save(struct bcma_bus *bus, bool up)
+{
+	struct bcma_drv_pci *pc;
+	u16 data;
+
+	if (bus->hosttype !=3D BCMA_HOSTTYPE_PCI)
+		return;
+
+	pc =3D &bus->drv_pci[0];
+
+	if (pc->core->id.rev >=3D 15 && pc->core->id.rev <=3D 20) {
+		data =3D up ? 0x74 : 0x7C;
+		bcma_pcie_mdio_writeread(pc, BCMA_CORE_PCI_MDIO_BLK1,
+					 BCMA_CORE_PCI_MDIO_BLK1_MGMT1, 0x7F64);
+		bcma_pcie_mdio_writeread(pc, BCMA_CORE_PCI_MDIO_BLK1,
+					 BCMA_CORE_PCI_MDIO_BLK1_MGMT3, data);
+	} else if (pc->core->id.rev >=3D 21 && pc->core->id.rev <=3D 22) {
+		data =3D up ? 0x75 : 0x7D;
+		bcma_pcie_mdio_writeread(pc, BCMA_CORE_PCI_MDIO_BLK1,
+					 BCMA_CORE_PCI_MDIO_BLK1_MGMT1, 0x7E65);
+		bcma_pcie_mdio_writeread(pc, BCMA_CORE_PCI_MDIO_BLK1,
+					 BCMA_CORE_PCI_MDIO_BLK1_MGMT3, data);
+	}
+}
+EXPORT_SYMBOL_GPL(bcma_core_pci_power_save);
+
 int bcma_core_pci_irq_ctl(struct bcma_drv_pci *pc, struct bcma_device *cor=
e,
 			  bool enable)
 {
@@ -310,8 +317,6 @@ void bcma_core_pci_up(struct bcma_bus *bus)
=20
 	pc =3D &bus->drv_pci[0];
=20
-	bcma_core_pci_power_save(pc, true);
-
 	bcma_core_pci_extend_L1timer(pc, true);
 }
 EXPORT_SYMBOL_GPL(bcma_core_pci_up);
@@ -326,7 +331,5 @@ void bcma_core_pci_down(struct bcma_bus *bus)
 	pc =3D &bus->drv_pci[0];
=20
 	bcma_core_pci_extend_L1timer(pc, false);
-
-	bcma_core_pci_power_save(pc, false);
 }
 EXPORT_SYMBOL_GPL(bcma_core_pci_down);
diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index a12b923..0a327f4 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -85,6 +85,7 @@ static struct usb_device_id ath3k_table[] =3D {
 	{ USB_DEVICE(0x04CA, 0x3008) },
 	{ USB_DEVICE(0x13d3, 0x3362) },
 	{ USB_DEVICE(0x0CF3, 0xE004) },
+	{ USB_DEVICE(0x0CF3, 0xE005) },
 	{ USB_DEVICE(0x0930, 0x0219) },
 	{ USB_DEVICE(0x0489, 0xe057) },
 	{ USB_DEVICE(0x13d3, 0x3393) },
@@ -126,6 +127,7 @@ static struct usb_device_id ath3k_blist_tbl[] =3D {
 	{ USB_DEVICE(0x04ca, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3362), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0xe005), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe057), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3393), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 8e16f0a..f3dfc0a 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -102,6 +102,7 @@ static struct usb_device_id btusb_table[] =3D {
=20
 	/* Broadcom BCM20702A0 */
 	{ USB_DEVICE(0x0b05, 0x17b5) },
+	{ USB_DEVICE(0x0b05, 0x17cb) },
 	{ USB_DEVICE(0x04ca, 0x2003) },
 	{ USB_DEVICE(0x0489, 0xe042) },
 	{ USB_DEVICE(0x413c, 0x8197) },
@@ -112,6 +113,9 @@ static struct usb_device_id btusb_table[] =3D {
 	/*Broadcom devices with vendor specific id */
 	{ USB_VENDOR_AND_INTERFACE_INFO(0x0a5c, 0xff, 0x01, 0x01) },
=20
+	/* Belkin F8065bf - Broadcom based */
+	{ USB_VENDOR_AND_INTERFACE_INFO(0x050d, 0xff, 0x01, 0x01) },
+
 	{ }	/* Terminating entry */
 };
=20
@@ -148,6 +152,7 @@ static struct usb_device_id blacklist_table[] =3D {
 	{ USB_DEVICE(0x04ca, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3362), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0xe004), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0xe005), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0930, 0x0219), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0489, 0xe057), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3393), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/a=
th/ath9k/recv.c
index 4ee472a..ab9e3a8 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -1270,13 +1270,6 @@ static void ath9k_antenna_check(struct ath_softc *sc,
 		return;
=20
 	/*
-	 * All MPDUs in an aggregate will use the same LNA
-	 * as the first MPDU.
-	 */
-	if (rs->rs_isaggr && !rs->rs_firstaggr)
-		return;
-
-	/*
 	 * Change the default rx antenna if rx diversity
 	 * chooses the other antenna 3 times in a row.
 	 */
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index 35b515f..5ac713d 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -399,6 +399,7 @@ static struct ath_buf* ath_clone_txbuf(struct ath_softc=
 *sc, struct ath_buf *bf)
 	tbf->bf_buf_addr =3D bf->bf_buf_addr;
 	memcpy(tbf->bf_desc, bf->bf_desc, sc->sc_ah->caps.tx_desc_len);
 	tbf->bf_state =3D bf->bf_state;
+	tbf->bf_state.stale =3D false;
=20
 	return tbf;
 }
@@ -1389,11 +1390,15 @@ int ath_tx_aggr_start(struct ath_softc *sc, struct =
ieee80211_sta *sta,
 		      u16 tid, u16 *ssn)
 {
 	struct ath_atx_tid *txtid;
+	struct ath_txq *txq;
 	struct ath_node *an;
 	u8 density;
=20
 	an =3D (struct ath_node *)sta->drv_priv;
 	txtid =3D ATH_AN_2_TID(an, tid);
+	txq =3D txtid->ac->txq;
+
+	ath_txq_lock(sc, txq);
=20
 	/* update ampdu factor/density, they may have changed. This may happen
 	 * in HT IBSS when a beacon with HT-info is received after the station
@@ -1417,6 +1422,8 @@ int ath_tx_aggr_start(struct ath_softc *sc, struct ie=
ee80211_sta *sta,
 	memset(txtid->tx_buf, 0, sizeof(txtid->tx_buf));
 	txtid->baw_head =3D txtid->baw_tail =3D 0;
=20
+	ath_txq_unlock_complete(sc, txq);
+
 	return 0;
 }
=20
@@ -1555,8 +1562,10 @@ void ath9k_release_buffered_frames(struct ieee80211_=
hw *hw,
 			__skb_unlink(bf->bf_mpdu, tid_q);
 			list_add_tail(&bf->list, &bf_q);
 			ath_set_rates(tid->an->vif, tid->an->sta, bf);
-			ath_tx_addto_baw(sc, tid, bf);
-			bf->bf_state.bf_type &=3D ~BUF_AGGR;
+			if (bf_isampdu(bf)) {
+				ath_tx_addto_baw(sc, tid, bf);
+				bf->bf_state.bf_type &=3D ~BUF_AGGR;
+			}
 			if (bf_tail)
 				bf_tail->bf_next =3D bf;
=20
@@ -1950,7 +1959,9 @@ static void ath_tx_txqaddbuf(struct ath_softc *sc, st=
ruct ath_txq *txq,
 			if (bf_is_ampdu_not_probing(bf))
 				txq->axq_ampdu_depth++;
=20
-			bf =3D bf->bf_lastbf->bf_next;
+			bf_last =3D bf->bf_lastbf;
+			bf =3D bf_last->bf_next;
+			bf_last->bf_next =3D NULL;
 		}
 	}
 }
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c b/drive=
rs/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
index 64f4a2b..c3462b7 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
@@ -464,8 +464,6 @@ static struct sdio_driver brcmf_sdmmc_driver =3D {
=20
 static int brcmf_sdio_pd_probe(struct platform_device *pdev)
 {
-	int ret;
-
 	brcmf_dbg(SDIO, "Enter\n");
=20
 	brcmfmac_sdio_pdata =3D pdev->dev.platform_data;
@@ -473,11 +471,7 @@ static int brcmf_sdio_pd_probe(struct platform_device =
*pdev)
 	if (brcmfmac_sdio_pdata->power_on)
 		brcmfmac_sdio_pdata->power_on();
=20
-	ret =3D sdio_register_driver(&brcmf_sdmmc_driver);
-	if (ret)
-		brcmf_err("sdio_register_driver failed: %d\n", ret);
-
-	return ret;
+	return 0;
 }
=20
 static int brcmf_sdio_pd_remove(struct platform_device *pdev)
@@ -500,6 +494,15 @@ static struct platform_driver brcmf_sdio_pd =3D {
 	}
 };
=20
+void brcmf_sdio_register(void)
+{
+	int ret;
+
+	ret =3D sdio_register_driver(&brcmf_sdmmc_driver);
+	if (ret)
+		brcmf_err("sdio_register_driver failed: %d\n", ret);
+}
+
 void brcmf_sdio_exit(void)
 {
 	brcmf_dbg(SDIO, "Enter\n");
@@ -510,18 +513,13 @@ void brcmf_sdio_exit(void)
 		sdio_unregister_driver(&brcmf_sdmmc_driver);
 }
=20
-void brcmf_sdio_init(void)
+void __init brcmf_sdio_init(void)
 {
 	int ret;
=20
 	brcmf_dbg(SDIO, "Enter\n");
=20
 	ret =3D platform_driver_probe(&brcmf_sdio_pd, brcmf_sdio_pd_probe);
-	if (ret =3D=3D -ENODEV) {
-		brcmf_dbg(SDIO, "No platform data available, registering without.\n");
-		ret =3D sdio_register_driver(&brcmf_sdmmc_driver);
-	}
-
-	if (ret)
-		brcmf_err("driver registration failed: %d\n", ret);
+	if (ret =3D=3D -ENODEV)
+		brcmf_dbg(SDIO, "No platform data available.\n");
 }
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h b/drivers/ne=
t/wireless/brcm80211/brcmfmac/dhd_bus.h
index f7c1985..74156f8 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h
@@ -156,10 +156,11 @@ extern int brcmf_bus_start(struct device *dev);
 #ifdef CONFIG_BRCMFMAC_SDIO
 extern void brcmf_sdio_exit(void);
 extern void brcmf_sdio_init(void);
+extern void brcmf_sdio_register(void);
 #endif
 #ifdef CONFIG_BRCMFMAC_USB
 extern void brcmf_usb_exit(void);
-extern void brcmf_usb_init(void);
+extern void brcmf_usb_register(void);
 #endif
=20
 #endif				/* _BRCMF_BUS_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/=
net/wireless/brcm80211/brcmfmac/dhd_linux.c
index e067aec..40e7f85 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -1231,21 +1231,23 @@ u32 brcmf_get_chip_info(struct brcmf_if *ifp)
 	return bus->chip << 4 | bus->chiprev;
 }
=20
-static void brcmf_driver_init(struct work_struct *work)
+static void brcmf_driver_register(struct work_struct *work)
 {
-	brcmf_debugfs_init();
-
 #ifdef CONFIG_BRCMFMAC_SDIO
-	brcmf_sdio_init();
+	brcmf_sdio_register();
 #endif
 #ifdef CONFIG_BRCMFMAC_USB
-	brcmf_usb_init();
+	brcmf_usb_register();
 #endif
 }
-static DECLARE_WORK(brcmf_driver_work, brcmf_driver_init);
+static DECLARE_WORK(brcmf_driver_work, brcmf_driver_register);
=20
 static int __init brcmfmac_module_init(void)
 {
+	brcmf_debugfs_init();
+#ifdef CONFIG_BRCMFMAC_SDIO
+	brcmf_sdio_init();
+#endif
 	if (!schedule_work(&brcmf_driver_work))
 		return -EBUSY;
=20
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wi=
reless/brcm80211/brcmfmac/usb.c
index 39e01a7..f4aea47 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
@@ -1539,7 +1539,7 @@ void brcmf_usb_exit(void)
 	brcmf_release_fw(&fw_image_list);
 }
=20
-void brcmf_usb_init(void)
+void brcmf_usb_register(void)
 {
 	brcmf_dbg(USB, "Enter\n");
 	INIT_LIST_HEAD(&fw_image_list);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c b/driver=
s/net/wireless/brcm80211/brcmsmac/mac80211_if.c
index 3a65447..edc5d10 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/mac80211_if.c
@@ -457,6 +457,8 @@ static int brcms_ops_start(struct ieee80211_hw *hw)
 	if (err !=3D 0)
 		brcms_err(wl->wlc->hw->d11core, "%s: brcms_up() returned %d\n",
 			  __func__, err);
+
+	bcma_core_pci_power_save(wl->wlc->hw->d11core->bus, true);
 	return err;
 }
=20
@@ -479,6 +481,8 @@ static void brcms_ops_stop(struct ieee80211_hw *hw)
 		return;
 	}
=20
+	bcma_core_pci_power_save(wl->wlc->hw->d11core->bus, false);
+
 	/* put driver in down state */
 	spin_lock_bh(&wl->lock);
 	brcms_down(wl);
diff --git a/drivers/net/wireless/cw1200/cw1200_spi.c b/drivers/net/wireles=
s/cw1200/cw1200_spi.c
index f5e6b48..899cad3 100644
--- a/drivers/net/wireless/cw1200/cw1200_spi.c
+++ b/drivers/net/wireless/cw1200/cw1200_spi.c
@@ -42,7 +42,6 @@ struct hwbus_priv {
 	spinlock_t		lock; /* Serialize all bus operations */
 	wait_queue_head_t       wq;
 	int claimed;
-	int irq_disabled;
 };
=20
 #define SDIO_TO_SPI_ADDR(addr) ((addr & 0x1f)>>2)
@@ -238,8 +237,6 @@ static irqreturn_t cw1200_spi_irq_handler(int irq, void=
 *dev_id)
 	struct hwbus_priv *self =3D dev_id;
=20
 	if (self->core) {
-		disable_irq_nosync(self->func->irq);
-		self->irq_disabled =3D 1;
 		cw1200_irq_handler(self->core);
 		return IRQ_HANDLED;
 	} else {
@@ -253,9 +250,10 @@ static int cw1200_spi_irq_subscribe(struct hwbus_priv =
*self)
=20
 	pr_debug("SW IRQ subscribe\n");
=20
-	ret =3D request_any_context_irq(self->func->irq, cw1200_spi_irq_handler,
-				      IRQF_TRIGGER_HIGH,
-				      "cw1200_wlan_irq", self);
+	ret =3D request_threaded_irq(self->func->irq, NULL,
+				   cw1200_spi_irq_handler,
+				   IRQF_TRIGGER_HIGH | IRQF_ONESHOT,
+				   "cw1200_wlan_irq", self);
 	if (WARN_ON(ret < 0))
 		goto exit;
=20
@@ -273,22 +271,13 @@ exit:
=20
 static int cw1200_spi_irq_unsubscribe(struct hwbus_priv *self)
 {
+	int ret =3D 0;
+
 	pr_debug("SW IRQ unsubscribe\n");
 	disable_irq_wake(self->func->irq);
 	free_irq(self->func->irq, self);
=20
-	return 0;
-}
-
-static int cw1200_spi_irq_enable(struct hwbus_priv *self, int enable)
-{
-	/* Disables are handled by the interrupt handler */
-	if (enable && self->irq_disabled) {
-		enable_irq(self->func->irq);
-		self->irq_disabled =3D 0;
-	}
-
-	return 0;
+	return ret;
 }
=20
 static int cw1200_spi_off(const struct cw1200_platform_data_spi *pdata)
@@ -368,7 +357,6 @@ static struct hwbus_ops cw1200_spi_hwbus_ops =3D {
 	.unlock			=3D cw1200_spi_unlock,
 	.align_size		=3D cw1200_spi_align_size,
 	.power_mgmt		=3D cw1200_spi_pm,
-	.irq_enable             =3D cw1200_spi_irq_enable,
 };
=20
 /* Probe Function to be called by SPI stack when device is discovered */
diff --git a/drivers/net/wireless/cw1200/fwio.c b/drivers/net/wireless/cw12=
00/fwio.c
index 0b2061b..acdff0f 100644
--- a/drivers/net/wireless/cw1200/fwio.c
+++ b/drivers/net/wireless/cw1200/fwio.c
@@ -485,7 +485,7 @@ int cw1200_load_firmware(struct cw1200_common *priv)
=20
 	/* Enable interrupt signalling */
 	priv->hwbus_ops->lock(priv->hwbus_priv);
-	ret =3D __cw1200_irq_enable(priv, 2);
+	ret =3D __cw1200_irq_enable(priv, 1);
 	priv->hwbus_ops->unlock(priv->hwbus_priv);
 	if (ret < 0)
 		goto unsubscribe;
diff --git a/drivers/net/wireless/cw1200/hwbus.h b/drivers/net/wireless/cw1=
200/hwbus.h
index 51dfb3a..8b2fc83 100644
--- a/drivers/net/wireless/cw1200/hwbus.h
+++ b/drivers/net/wireless/cw1200/hwbus.h
@@ -28,7 +28,6 @@ struct hwbus_ops {
 	void (*unlock)(struct hwbus_priv *self);
 	size_t (*align_size)(struct hwbus_priv *self, size_t size);
 	int (*power_mgmt)(struct hwbus_priv *self, bool suspend);
-	int (*irq_enable)(struct hwbus_priv *self, int enable);
 };
=20
 #endif /* CW1200_HWBUS_H */
diff --git a/drivers/net/wireless/cw1200/hwio.c b/drivers/net/wireless/cw12=
00/hwio.c
index 41bd761..ff230b7 100644
--- a/drivers/net/wireless/cw1200/hwio.c
+++ b/drivers/net/wireless/cw1200/hwio.c
@@ -273,21 +273,6 @@ int __cw1200_irq_enable(struct cw1200_common *priv, in=
t enable)
 	u16 val16;
 	int ret;
=20
-	/* We need to do this hack because the SPI layer can sleep on I/O
-	   and the general path involves I/O to the device in interrupt
-	   context.
-
-	   However, the initial enable call needs to go to the hardware.
-
-	   We don't worry about shutdown because we do a full reset which
-	   clears the interrupt enabled bits.
-	*/
-	if (priv->hwbus_ops->irq_enable) {
-		ret =3D priv->hwbus_ops->irq_enable(priv->hwbus_priv, enable);
-		if (ret || enable < 2)
-			return ret;
-	}
-
 	if (HIF_8601_SILICON =3D=3D priv->hw_type) {
 		ret =3D __cw1200_reg_read_32(priv, ST90TDS_CONFIG_REG_ID, &val32);
 		if (ret < 0) {
diff --git a/drivers/net/wireless/mwifiex/11n_aggr.c b/drivers/net/wireless=
/mwifiex/11n_aggr.c
index 21c6882..1214c58 100644
--- a/drivers/net/wireless/mwifiex/11n_aggr.c
+++ b/drivers/net/wireless/mwifiex/11n_aggr.c
@@ -150,7 +150,7 @@ mwifiex_11n_form_amsdu_txpd(struct mwifiex_private *pri=
v,
  */
 int
 mwifiex_11n_aggregate_pkt(struct mwifiex_private *priv,
-			  struct mwifiex_ra_list_tbl *pra_list, int headroom,
+			  struct mwifiex_ra_list_tbl *pra_list,
 			  int ptrindex, unsigned long ra_list_flags)
 			  __releases(&priv->wmm.ra_list_spinlock)
 {
@@ -160,6 +160,7 @@ mwifiex_11n_aggregate_pkt(struct mwifiex_private *priv,
 	int pad =3D 0, ret;
 	struct mwifiex_tx_param tx_param;
 	struct txpd *ptx_pd =3D NULL;
+	int headroom =3D adapter->iface_type =3D=3D MWIFIEX_USB ? 0 : INTF_HEADER=
_LEN;
=20
 	skb_src =3D skb_peek(&pra_list->skb_head);
 	if (!skb_src) {
diff --git a/drivers/net/wireless/mwifiex/11n_aggr.h b/drivers/net/wireless=
/mwifiex/11n_aggr.h
index 900e1c6..892098d 100644
--- a/drivers/net/wireless/mwifiex/11n_aggr.h
+++ b/drivers/net/wireless/mwifiex/11n_aggr.h
@@ -26,7 +26,7 @@
 int mwifiex_11n_deaggregate_pkt(struct mwifiex_private *priv,
 				struct sk_buff *skb);
 int mwifiex_11n_aggregate_pkt(struct mwifiex_private *priv,
-			      struct mwifiex_ra_list_tbl *ptr, int headroom,
+			      struct mwifiex_ra_list_tbl *ptr,
 			      int ptr_index, unsigned long flags)
 			      __releases(&priv->wmm.ra_list_spinlock);
=20
diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/m=
wifiex/cmdevt.c
index 2d76147..a6c46f3 100644
--- a/drivers/net/wireless/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/mwifiex/cmdevt.c
@@ -1155,7 +1155,7 @@ int mwifiex_ret_802_11_hs_cfg(struct mwifiex_private =
*priv,
 	uint32_t conditions =3D le32_to_cpu(phs_cfg->params.hs_config.conditions);
=20
 	if (phs_cfg->action =3D=3D cpu_to_le16(HS_ACTIVATE) &&
-	    adapter->iface_type =3D=3D MWIFIEX_SDIO) {
+	    adapter->iface_type !=3D MWIFIEX_USB) {
 		mwifiex_hs_activated_event(priv, true);
 		return 0;
 	} else {
@@ -1167,8 +1167,7 @@ int mwifiex_ret_802_11_hs_cfg(struct mwifiex_private =
*priv,
 	}
 	if (conditions !=3D HS_CFG_CANCEL) {
 		adapter->is_hs_configured =3D true;
-		if (adapter->iface_type =3D=3D MWIFIEX_USB ||
-		    adapter->iface_type =3D=3D MWIFIEX_PCIE)
+		if (adapter->iface_type =3D=3D MWIFIEX_USB)
 			mwifiex_hs_activated_event(priv, true);
 	} else {
 		adapter->is_hs_configured =3D false;
diff --git a/drivers/net/wireless/mwifiex/usb.c b/drivers/net/wireless/mwif=
iex/usb.c
index 2472d4b..1c70b8d 100644
--- a/drivers/net/wireless/mwifiex/usb.c
+++ b/drivers/net/wireless/mwifiex/usb.c
@@ -447,9 +447,6 @@ static int mwifiex_usb_suspend(struct usb_interface *in=
tf, pm_message_t message)
 	 */
 	adapter->is_suspended =3D true;
=20
-	for (i =3D 0; i < adapter->priv_num; i++)
-		netif_carrier_off(adapter->priv[i]->netdev);
-
 	if (atomic_read(&card->rx_cmd_urb_pending) && card->rx_cmd.urb)
 		usb_kill_urb(card->rx_cmd.urb);
=20
@@ -509,10 +506,6 @@ static int mwifiex_usb_resume(struct usb_interface *in=
tf)
 						  MWIFIEX_RX_CMD_BUF_SIZE);
 	}
=20
-	for (i =3D 0; i < adapter->priv_num; i++)
-		if (adapter->priv[i]->media_connected)
-			netif_carrier_on(adapter->priv[i]->netdev);
-
 	/* Disable Host Sleep */
 	if (adapter->hs_activated)
 		mwifiex_cancel_hs(mwifiex_get_priv(adapter,
diff --git a/drivers/net/wireless/mwifiex/wmm.c b/drivers/net/wireless/mwif=
iex/wmm.c
index 2e8f9cd..95fa359 100644
--- a/drivers/net/wireless/mwifiex/wmm.c
+++ b/drivers/net/wireless/mwifiex/wmm.c
@@ -1239,8 +1239,7 @@ mwifiex_dequeue_tx_packet(struct mwifiex_adapter *ada=
pter)
 		if (enable_tx_amsdu && mwifiex_is_amsdu_allowed(priv, tid) &&
 		    mwifiex_is_11n_aggragation_possible(priv, ptr,
 							adapter->tx_buf_size))
-			mwifiex_11n_aggregate_pkt(priv, ptr, INTF_HEADER_LEN,
-						  ptr_index, flags);
+			mwifiex_11n_aggregate_pkt(priv, ptr, ptr_index, flags);
 			/* ra_list_spinlock has been freed in
 			   mwifiex_11n_aggregate_pkt() */
 		else
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p=
54usb.c
index b9deef6..e328d30 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -83,6 +83,7 @@ static struct usb_device_id p54u_table[] =3D {
 	{USB_DEVICE(0x06a9, 0x000e)},	/* Westell 802.11g USB (A90-211WG-01) */
 	{USB_DEVICE(0x06b9, 0x0121)},	/* Thomson SpeedTouch 121g */
 	{USB_DEVICE(0x0707, 0xee13)},   /* SMC 2862W-G version 2 */
+	{USB_DEVICE(0x07aa, 0x0020)},	/* Corega WLUSB2GTST USB */
 	{USB_DEVICE(0x0803, 0x4310)},	/* Zoom 4410a */
 	{USB_DEVICE(0x083a, 0x4521)},   /* Siemens Gigaset USB Adapter 54 version=
 2 */
 	{USB_DEVICE(0x083a, 0x4531)},	/* T-Com Sinus 154 data II */
@@ -979,6 +980,7 @@ static int p54u_load_firmware(struct ieee80211_hw *dev,
 	if (err) {
 		dev_err(&priv->udev->dev, "(p54usb) cannot load firmware %s "
 					  "(%d)!\n", p54u_fwlist[i].fw, err);
+		usb_put_dev(udev);
 	}
=20
 	return err;
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtl=
wifi/wifi.h
index cc03e7c..7032587 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -2057,7 +2057,7 @@ struct rtl_priv {
 	   that it points to the data allocated
 	   beyond  this structure like:
 	   rtl_pci_priv or rtl_usb_priv */
-	u8 priv[0];
+	u8 priv[0] __aligned(sizeof(void *));
 };
=20
 #define rtl_priv(hw)		(((struct rtl_priv *)(hw)->priv))
diff --git a/include/linux/bcma/bcma_driver_pci.h b/include/linux/bcma/bcma=
_driver_pci.h
index d66033f..0333e60 100644
--- a/include/linux/bcma/bcma_driver_pci.h
+++ b/include/linux/bcma/bcma_driver_pci.h
@@ -242,6 +242,7 @@ extern int bcma_core_pci_irq_ctl(struct bcma_drv_pci *p=
c,
 				 struct bcma_device *core, bool enable);
 extern void bcma_core_pci_up(struct bcma_bus *bus);
 extern void bcma_core_pci_down(struct bcma_bus *bus);
+extern void bcma_core_pci_power_save(struct bcma_bus *bus, bool up);
=20
 extern int bcma_core_pci_pcibios_map_irq(const struct pci_dev *dev);
 extern int bcma_core_pci_plat_dev_init(struct pci_dev *dev);
diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index aaeaf09..15f1084 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -104,6 +104,7 @@ enum {
 enum {
 	HCI_SETUP,
 	HCI_AUTO_OFF,
+	HCI_RFKILLED,
 	HCI_MGMT,
 	HCI_PAIRABLE,
 	HCI_SERVICE_CACHE,
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 634deba..fb7356f 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1146,7 +1146,11 @@ int hci_dev_open(__u16 dev)
 		goto done;
 	}
=20
-	if (hdev->rfkill && rfkill_blocked(hdev->rfkill)) {
+	/* Check for rfkill but allow the HCI setup stage to proceed
+	 * (which in itself doesn't cause any RF activity).
+	 */
+	if (test_bit(HCI_RFKILLED, &hdev->dev_flags) &&
+	    !test_bit(HCI_SETUP, &hdev->dev_flags)) {
 		ret =3D -ERFKILL;
 		goto done;
 	}
@@ -1566,10 +1570,13 @@ static int hci_rfkill_set_block(void *data, bool bl=
ocked)
=20
 	BT_DBG("%p name %s blocked %d", hdev, hdev->name, blocked);
=20
-	if (!blocked)
-		return 0;
-
-	hci_dev_do_close(hdev);
+	if (blocked) {
+		set_bit(HCI_RFKILLED, &hdev->dev_flags);
+		if (!test_bit(HCI_SETUP, &hdev->dev_flags))
+			hci_dev_do_close(hdev);
+	} else {
+		clear_bit(HCI_RFKILLED, &hdev->dev_flags);
+	}
=20
 	return 0;
 }
@@ -1591,9 +1598,13 @@ static void hci_power_on(struct work_struct *work)
 		return;
 	}
=20
-	if (test_bit(HCI_AUTO_OFF, &hdev->dev_flags))
+	if (test_bit(HCI_RFKILLED, &hdev->dev_flags)) {
+		clear_bit(HCI_AUTO_OFF, &hdev->dev_flags);
+		hci_dev_do_close(hdev);
+	} else if (test_bit(HCI_AUTO_OFF, &hdev->dev_flags)) {
 		queue_delayed_work(hdev->req_workqueue, &hdev->power_off,
 				   HCI_AUTO_OFF_TIMEOUT);
+	}
=20
 	if (test_and_clear_bit(HCI_SETUP, &hdev->dev_flags))
 		mgmt_index_added(hdev);
@@ -2209,6 +2220,9 @@ int hci_register_dev(struct hci_dev *hdev)
 		}
 	}
=20
+	if (hdev->rfkill && rfkill_blocked(hdev->rfkill))
+		set_bit(HCI_RFKILLED, &hdev->dev_flags);
+
 	set_bit(HCI_SETUP, &hdev->dev_flags);
=20
 	if (hdev->dev_type !=3D HCI_AMP)
diff --git a/net/bluetooth/hci_event.c b/net/bluetooth/hci_event.c
index 94aab73..8db3e89 100644
--- a/net/bluetooth/hci_event.c
+++ b/net/bluetooth/hci_event.c
@@ -3557,7 +3557,11 @@ static void hci_le_ltk_request_evt(struct hci_dev *h=
dev, struct sk_buff *skb)
 	cp.handle =3D cpu_to_le16(conn->handle);
=20
 	if (ltk->authenticated)
-		conn->sec_level =3D BT_SECURITY_HIGH;
+		conn->pending_sec_level =3D BT_SECURITY_HIGH;
+	else
+		conn->pending_sec_level =3D BT_SECURITY_MEDIUM;
+
+	conn->enc_key_size =3D ltk->enc_size;
=20
 	hci_send_cmd(hdev, HCI_OP_LE_LTK_REPLY, sizeof(cp), &cp);
=20
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index b3bb7bc..63fa111 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -3755,6 +3755,13 @@ static struct l2cap_chan *l2cap_connect(struct l2cap=
_conn *conn,
=20
 	sk =3D chan->sk;
=20
+	/* For certain devices (ex: HID mouse), support for authentication,
+	 * pairing and bonding is optional. For such devices, inorder to avoid
+	 * the ACL alive for too long after L2CAP disconnection, reset the ACL
+	 * disc_timeout back to HCI_DISCONN_TIMEOUT during L2CAP connect.
+	 */
+	conn->hcon->disc_timeout =3D HCI_DISCONN_TIMEOUT;
+
 	bacpy(&bt_sk(sk)->src, conn->src);
 	bacpy(&bt_sk(sk)->dst, conn->dst);
 	chan->psm  =3D psm;
diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index 6d126fa..84fcf9f 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -569,7 +569,6 @@ static void rfcomm_dev_data_ready(struct rfcomm_dlc *dl=
c, struct sk_buff *skb)
 static void rfcomm_dev_state_change(struct rfcomm_dlc *dlc, int err)
 {
 	struct rfcomm_dev *dev =3D dlc->owner;
-	struct tty_struct *tty;
 	if (!dev)
 		return;
=20
@@ -581,38 +580,8 @@ static void rfcomm_dev_state_change(struct rfcomm_dlc =
*dlc, int err)
 			    DPM_ORDER_DEV_AFTER_PARENT);
=20
 		wake_up_interruptible(&dev->port.open_wait);
-	} else if (dlc->state =3D=3D BT_CLOSED) {
-		tty =3D tty_port_tty_get(&dev->port);
-		if (!tty) {
-			if (test_bit(RFCOMM_RELEASE_ONHUP, &dev->flags)) {
-				/* Drop DLC lock here to avoid deadlock
-				 * 1. rfcomm_dev_get will take rfcomm_dev_lock
-				 *    but in rfcomm_dev_add there's lock order:
-				 *    rfcomm_dev_lock -> dlc lock
-				 * 2. tty_port_put will deadlock if it's
-				 *    the last reference
-				 *
-				 * FIXME: when we release the lock anything
-				 * could happen to dev, even its destruction
-				 */
-				rfcomm_dlc_unlock(dlc);
-				if (rfcomm_dev_get(dev->id) =3D=3D NULL) {
-					rfcomm_dlc_lock(dlc);
-					return;
-				}
-
-				if (!test_and_set_bit(RFCOMM_TTY_RELEASED,
-						      &dev->flags))
-					tty_port_put(&dev->port);
-
-				tty_port_put(&dev->port);
-				rfcomm_dlc_lock(dlc);
-			}
-		} else {
-			tty_hangup(tty);
-			tty_kref_put(tty);
-		}
-	}
+	} else if (dlc->state =3D=3D BT_CLOSED)
+		tty_port_tty_hangup(&dev->port, false);
 }
=20
 static void rfcomm_dev_modem_status(struct rfcomm_dlc *dlc, u8 v24_sig)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--6c2NcOVqGQ03X4Wi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAEBAgAGBQJSRcj8AAoJEJctW/TcYTgGeYYP/ikzyhKFQScmGchKGx7KwnhW
y5tgvCgNwN0bn4IQ3MLprScYjqhKLJb6g6i8COvXnyPxny0o/9ahlUFEGRsZictn
LSCIlpq+RmnNMRJOKmH/gQe89z6ZdhN1D0V+ZVu2eSXi7V3uaug/M2RXWtAXKgEg
acNoBW/cCsd0YKtYDXgjw+MEF6+nRybpJXlcltb+fnP/03D4tnGsQPoCiumZczOY
CVmsJD90k0CbBGRGXxlKoF+LpGkXmEocKCQCUhs8byDEONyyud6YNsc1VFcPuS4S
yjJNOV02SG5MDkkcqqFReA/lIZ5Ftz2OmSx5inEqRJGzpFN5a4/fl531pcrtP/U0
VWlH7qVTB8zw8Hc/e09LUKMcvF70P6PrFGYiohmvEY+WBKeB73TRZq5mKoPeyu3/
ehaO/Ff64fAuXuNkYWr6k5OoscLXexZ5VFhPYMDMHWM7R4uG5JDOV416YmONM0gJ
c6yzBMg+k+y2Ze5ibWKj+qB0dCSdf1B3KXw/tRfAgMlcT457f1LG+gBJGZfeGsYf
pqQz6gWZiMi5Ar5B5VYLeq73NG2hFtcEIu8qGvxeOWhyhzRev3sd4IM4JE4B9Yna
CPeeg2t0ojjxPpEBpY+dkj+Nny60DJjnjtxuMaNi3xacJ5UggiDtb7El1sTbmr5d
o535LsvwtOhx25Ca28GK
=IUTh
-----END PGP SIGNATURE-----

--6c2NcOVqGQ03X4Wi--
