From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-04-12
Date: Thu, 12 Apr 2012 10:28:59 -0400
Message-ID: <20120412142859.GB21495@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KsGdsel6WgEHnImy"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49008 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041Ab2DLOc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 10:32:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 5d949944229b0a08e218723be231731cd86b94f3

Dave,

This is a flurry of fixes intended for 3.4...

Many of these are Bluetooth fixes.  Gustavo says:

"This is a batch of fixes for 3.4. We have added support to 3 new
devices, fixes some NULL-pointer dereferences, memory leaks, memory
corruption and endian bugs. There was also a userspace compatibility
fix reported by Keith Packard on lkml. The fixes are all simple."

On top of the Bluetooths bits, we have a number of wireless fixes.
One is an rt2x00 fix from Chien-Chia Chen which fixes the rfkill
registration so that it still works even if the box is booted with the
device already blocked.  Johannes Berg gives us a pair of fixes, one
that corrects a macro parameter when setting a beacon wait timeout, and
another that ensures that the proper interface state is used throughout
nl80211 so as to avoid warnings and unintended driver behavior.
Julia Lawall gives us a fix for a memory leak in an error handling
case.  Larry Finger is the star performer for this round, giving us a
fix for firmware initialization in rtl8192de, a mac80211 fix to quiet
some log spam, a fix to avoid a NULL pointer dereference in rtlwifi, an
rtlwifi fix to avoid a "sleeping function called from invalid context"
BUG, and another rtlwifi fix to avoid "Out of SW-IOMMU space" errors.
Paul Gortmaker gives us a fix to avoid bcma build breakage on MIPS.
Samuel Ortiz fixes a loop in NFC's LLCP Tx frame fragmentation loop.
And finally, Sujith Manoharan reverts an earlier patch in order to
fix a regression reported by a number of ath9k users.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit a21d45726acacc963d8baddf74607d9b74e2b723:

  tcp: avoid order-1 allocations on wifi and tx path (2012-04-11 10:11:12 -=
0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

AceLan Kao (1):
      Bluetooth: Add support for Atheros [04ca:3005]

Andrei Emeltchenko (3):
      Bluetooth: Fix memory leaks due to chan refcnt
      Bluetooth: mgmt: Add missing endian conversion
      Bluetooth: mgmt: Fix timeout type

Brian Gix (1):
      Bluetooth: mgmt: Fix corruption of device_connected pkt

Chen, Chien-Chia (1):
      rt2x00: Fix rfkill_polling register function.

Cho, Yu-Chen (1):
      Bluetooth: Add Atheros maryann PIDVID support

Don Zickus (1):
      Bluetooth: btusb: typo in Broadcom SoftSailing id

Gustavo Padovan (1):
      Bluetooth: Fix userspace compatibility issue with mgmt interface

Hemant Gupta (1):
      Bluetooth: Use correct flags for checking HCI_SSP_ENABLED bit

Johan Hedberg (2):
      Bluetooth: Don't increment twice in eir_has_data_type()
      Bluetooth: Check for minimum data length in eir_has_data_type()

Johan Hovold (2):
      Bluetooth: hci_ldisc: fix NULL-pointer dereference on tty_close
      Bluetooth: hci_core: fix NULL-pointer dereference at unregister

Johannes Berg (2):
      mac80211: fix association beacon wait timeout
      nl80211: ensure interface is up in various APIs

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Jo=E3o Paulo Rechi Vita (1):
      Bluetooth: btusb: Add USB device ID "0a5c 21e8"

Julia Lawall (1):
      net/wireless/wext-core.c: add missing kfree

Larry Finger (5):
      rtlwifi: rtl8192de: Fix firmware initialization
      mac80211: Convert WARN_ON to WARN_ON_ONCE
      rtlwifi: Fix oops on rate-control failure
      rtlwifi: Preallocate USB read buffers and eliminate kalloc in read ro=
utine
      rtlwifi: Add missing DMA buffer unmapping for PCI drivers

Marcel Holtmann (1):
      MAINTAINERS: update Bluetooth tree locations

Paul Gortmaker (1):
      bcma: fix build error on MIPS; implicit pcibios_enable_device

Samuel Ortiz (1):
      NFC: Fix the LLCP Tx fragmentation loop

Santosh Nayak (1):
      Bluetooth: Fix Endian Bug.

Sujith Manoharan (1):
      Revert "ath9k: fix going to full-sleep on PS idle"

 MAINTAINERS                                 |    8 +++---
 drivers/bcma/Kconfig                        |    2 +-
 drivers/bcma/driver_pci_host.c              |    1 +
 drivers/bluetooth/ath3k.c                   |    4 +++
 drivers/bluetooth/btusb.c                   |    5 +++-
 drivers/bluetooth/hci_ldisc.c               |    2 +-
 drivers/net/wireless/ath/ath9k/main.c       |    8 ++----
 drivers/net/wireless/rt2x00/rt2x00dev.c     |    6 +----
 drivers/net/wireless/rtlwifi/base.c         |    5 +++-
 drivers/net/wireless/rtlwifi/pci.c          |    7 ++++-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c |    6 ----
 drivers/net/wireless/rtlwifi/usb.c          |   34 ++++++++++++-----------=
---
 drivers/net/wireless/rtlwifi/wifi.h         |    6 ++++-
 include/net/bluetooth/hci.h                 |    3 +-
 include/net/bluetooth/hci_core.h            |   12 +++++----
 include/net/bluetooth/mgmt.h                |    2 +-
 include/net/mac80211.h                      |    2 +-
 net/bluetooth/hci_core.c                    |    7 +++++
 net/bluetooth/l2cap_core.c                  |    3 ++
 net/bluetooth/l2cap_sock.c                  |    5 ++-
 net/bluetooth/mgmt.c                        |   13 +++++++---
 net/mac80211/mlme.c                         |    3 +-
 net/nfc/llcp/commands.c                     |    4 +-
 net/wireless/nl80211.c                      |   31 ++++++++++++++----------
 net/wireless/wext-core.c                    |    6 +++-
 25 files changed, 108 insertions(+), 77 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 71b7f5c..0e2f300 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1521,8 +1521,8 @@ M:	Gustavo Padovan <gustavo@padovan.org>
 M:	Johan Hedberg <johan.hedberg@gmail.com>
 L:	linux-bluetooth@vger.kernel.org
 W:	http://www.bluez.org/
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/padovan/bluetooth.git
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jh/bluetooth.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.g=
it
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-n=
ext.git
 S:	Maintained
 F:	drivers/bluetooth/
=20
@@ -1532,8 +1532,8 @@ M:	Gustavo Padovan <gustavo@padovan.org>
 M:	Johan Hedberg <johan.hedberg@gmail.com>
 L:	linux-bluetooth@vger.kernel.org
 W:	http://www.bluez.org/
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/padovan/bluetooth.git
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/jh/bluetooth.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth.g=
it
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-n=
ext.git
 S:	Maintained
 F:	net/bluetooth/
 F:	include/net/bluetooth/
diff --git a/drivers/bcma/Kconfig b/drivers/bcma/Kconfig
index c1172da..fb7c80f 100644
--- a/drivers/bcma/Kconfig
+++ b/drivers/bcma/Kconfig
@@ -29,7 +29,7 @@ config BCMA_HOST_PCI
=20
 config BCMA_DRIVER_PCI_HOSTMODE
 	bool "Driver for PCI core working in hostmode"
-	depends on BCMA && MIPS
+	depends on BCMA && MIPS && BCMA_HOST_PCI
 	help
 	  PCI core hostmode operation (external PCI bus).
=20
diff --git a/drivers/bcma/driver_pci_host.c b/drivers/bcma/driver_pci_host.c
index 4e20bcf..d2097a1 100644
--- a/drivers/bcma/driver_pci_host.c
+++ b/drivers/bcma/driver_pci_host.c
@@ -10,6 +10,7 @@
  */
=20
 #include "bcma_private.h"
+#include <linux/pci.h>
 #include <linux/export.h>
 #include <linux/bcma/bcma.h>
 #include <asm/paccess.h>
diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index 4844247..ae9edca 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -72,7 +72,9 @@ static struct usb_device_id ath3k_table[] =3D {
=20
 	/* Atheros AR3012 with sflash firmware*/
 	{ USB_DEVICE(0x0CF3, 0x3004) },
+	{ USB_DEVICE(0x0CF3, 0x311D) },
 	{ USB_DEVICE(0x13d3, 0x3375) },
+	{ USB_DEVICE(0x04CA, 0x3005) },
=20
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xE02C) },
@@ -89,7 +91,9 @@ static struct usb_device_id ath3k_blist_tbl[] =3D {
=20
 	/* Atheros AR3012 with sflash firmware*/
 	{ USB_DEVICE(0x0cf3, 0x3004), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0x311D), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3375), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
=20
 	{ }	/* Terminating entry */
 };
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index 480cad9..3311b81 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -61,7 +61,7 @@ static struct usb_device_id btusb_table[] =3D {
 	{ USB_DEVICE_INFO(0xe0, 0x01, 0x01) },
=20
 	/* Broadcom SoftSailing reporting vendor specific */
-	{ USB_DEVICE(0x05ac, 0x21e1) },
+	{ USB_DEVICE(0x0a5c, 0x21e1) },
=20
 	/* Apple MacBookPro 7,1 */
 	{ USB_DEVICE(0x05ac, 0x8213) },
@@ -103,6 +103,7 @@ static struct usb_device_id btusb_table[] =3D {
 	/* Broadcom BCM20702A0 */
 	{ USB_DEVICE(0x0a5c, 0x21e3) },
 	{ USB_DEVICE(0x0a5c, 0x21e6) },
+	{ USB_DEVICE(0x0a5c, 0x21e8) },
 	{ USB_DEVICE(0x0a5c, 0x21f3) },
 	{ USB_DEVICE(0x413c, 0x8197) },
=20
@@ -129,7 +130,9 @@ static struct usb_device_id blacklist_table[] =3D {
=20
 	/* Atheros 3012 with sflash firmware */
 	{ USB_DEVICE(0x0cf3, 0x3004), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x0cf3, 0x311d), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x13d3, 0x3375), .driver_info =3D BTUSB_ATH3012 },
+	{ USB_DEVICE(0x04ca, 0x3005), .driver_info =3D BTUSB_ATH3012 },
=20
 	/* Atheros AR5BBU12 with sflash firmware */
 	{ USB_DEVICE(0x0489, 0xe02c), .driver_info =3D BTUSB_IGNORE },
diff --git a/drivers/bluetooth/hci_ldisc.c b/drivers/bluetooth/hci_ldisc.c
index fd5adb4..98a8c05 100644
--- a/drivers/bluetooth/hci_ldisc.c
+++ b/drivers/bluetooth/hci_ldisc.c
@@ -299,11 +299,11 @@ static void hci_uart_tty_close(struct tty_struct *tty)
 			hci_uart_close(hdev);
=20
 		if (test_and_clear_bit(HCI_UART_PROTO_SET, &hu->flags)) {
-			hu->proto->close(hu);
 			if (hdev) {
 				hci_unregister_dev(hdev);
 				hci_free_dev(hdev);
 			}
+			hu->proto->close(hu);
 		}
=20
 		kfree(hu);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 215eb25..2504ab0 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -118,15 +118,13 @@ void ath9k_ps_restore(struct ath_softc *sc)
 	if (--sc->ps_usecount !=3D 0)
 		goto unlock;
=20
-	if (sc->ps_flags & PS_WAIT_FOR_TX_ACK)
-		goto unlock;
-
-	if (sc->ps_idle)
+	if (sc->ps_idle && (sc->ps_flags & PS_WAIT_FOR_TX_ACK))
 		mode =3D ATH9K_PM_FULL_SLEEP;
 	else if (sc->ps_enabled &&
 		 !(sc->ps_flags & (PS_WAIT_FOR_BEACON |
 			      PS_WAIT_FOR_CAB |
-			      PS_WAIT_FOR_PSPOLL_DATA)))
+			      PS_WAIT_FOR_PSPOLL_DATA |
+			      PS_WAIT_FOR_TX_ACK)))
 		mode =3D ATH9K_PM_NETWORK_SLEEP;
 	else
 		goto unlock;
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless=
/rt2x00/rt2x00dev.c
index fc9901e..90cc5e7 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -1062,11 +1062,6 @@ static int rt2x00lib_initialize(struct rt2x00_dev *r=
t2x00dev)
=20
 	set_bit(DEVICE_STATE_INITIALIZED, &rt2x00dev->flags);
=20
-	/*
-	 * Register the extra components.
-	 */
-	rt2x00rfkill_register(rt2x00dev);
-
 	return 0;
 }
=20
@@ -1210,6 +1205,7 @@ int rt2x00lib_probe_dev(struct rt2x00_dev *rt2x00dev)
 	rt2x00link_register(rt2x00dev);
 	rt2x00leds_register(rt2x00dev);
 	rt2x00debug_register(rt2x00dev);
+	rt2x00rfkill_register(rt2x00dev);
=20
 	return 0;
=20
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtl=
wifi/base.c
index 5100235..e54488d 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -838,7 +838,10 @@ void rtl_get_tcb_desc(struct ieee80211_hw *hw,
 	__le16 fc =3D hdr->frame_control;
=20
 	txrate =3D ieee80211_get_tx_rate(hw, info);
-	tcb_desc->hw_rate =3D txrate->hw_value;
+	if (txrate)
+		tcb_desc->hw_rate =3D txrate->hw_value;
+	else
+		tcb_desc->hw_rate =3D 0;
=20
 	if (ieee80211_is_data(fc)) {
 		/*
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlw=
ifi/pci.c
index 07dd38e..288b035 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -912,8 +912,13 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80=
211_hw *hw)
 	memset(&tcb_desc, 0, sizeof(struct rtl_tcb_desc));
 	ring =3D &rtlpci->tx_ring[BEACON_QUEUE];
 	pskb =3D __skb_dequeue(&ring->queue);
-	if (pskb)
+	if (pskb) {
+		struct rtl_tx_desc *entry =3D &ring->desc[ring->idx];
+		pci_unmap_single(rtlpci->pdev, rtlpriv->cfg->ops->get_desc(
+				 (u8 *) entry, true, HW_DESC_TXBUFF_ADDR),
+				 pskb->len, PCI_DMA_TODEVICE);
 		kfree_skb(pskb);
+	}
=20
 	/*NB: the beacon data buffer must be 32-bit aligned. */
 	pskb =3D ieee80211_beacon_get(hw, mac->vif);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192de/sw.c
index 4898c50..480862c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -91,7 +91,6 @@ static int rtl92d_init_sw_vars(struct ieee80211_hw *hw)
 	u8 tid;
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
 	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
-	static int header_print;
=20
 	rtlpriv->dm.dm_initialgain_enable =3D true;
 	rtlpriv->dm.dm_flag =3D 0;
@@ -171,10 +170,6 @@ static int rtl92d_init_sw_vars(struct ieee80211_hw *hw)
 	for (tid =3D 0; tid < 8; tid++)
 		skb_queue_head_init(&rtlpriv->mac80211.skb_waitq[tid]);
=20
-	/* Only load firmware for first MAC */
-	if (header_print)
-		return 0;
-
 	/* for firmware buf */
 	rtlpriv->rtlhal.pfirmware =3D vzalloc(0x8000);
 	if (!rtlpriv->rtlhal.pfirmware) {
@@ -186,7 +181,6 @@ static int rtl92d_init_sw_vars(struct ieee80211_hw *hw)
 	rtlpriv->max_fw_size =3D 0x8000;
 	pr_info("Driver for Realtek RTL8192DE WLAN interface\n");
 	pr_info("Loading firmware file %s\n", rtlpriv->cfg->fw_name);
-	header_print++;
=20
 	/* request fw */
 	err =3D request_firmware_nowait(THIS_MODULE, 1, rtlpriv->cfg->fw_name,
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlw=
ifi/usb.c
index 2e1e352..d04dbda 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -124,46 +124,38 @@ static int _usbctrl_vendorreq_sync_read(struct usb_de=
vice *udev, u8 request,
 	return status;
 }
=20
-static u32 _usb_read_sync(struct usb_device *udev, u32 addr, u16 len)
+static u32 _usb_read_sync(struct rtl_priv *rtlpriv, u32 addr, u16 len)
 {
+	struct device *dev =3D rtlpriv->io.dev;
+	struct usb_device *udev =3D to_usb_device(dev);
 	u8 request;
 	u16 wvalue;
 	u16 index;
-	u32 *data;
-	u32 ret;
+	__le32 *data =3D &rtlpriv->usb_data[rtlpriv->usb_data_index];
=20
-	data =3D kmalloc(sizeof(u32), GFP_KERNEL);
-	if (!data)
-		return -ENOMEM;
 	request =3D REALTEK_USB_VENQT_CMD_REQ;
 	index =3D REALTEK_USB_VENQT_CMD_IDX; /* n/a */
=20
 	wvalue =3D (u16)addr;
 	_usbctrl_vendorreq_sync_read(udev, request, wvalue, index, data, len);
-	ret =3D le32_to_cpu(*data);
-	kfree(data);
-	return ret;
+	if (++rtlpriv->usb_data_index >=3D RTL_USB_MAX_RX_COUNT)
+		rtlpriv->usb_data_index =3D 0;
+	return le32_to_cpu(*data);
 }
=20
 static u8 _usb_read8_sync(struct rtl_priv *rtlpriv, u32 addr)
 {
-	struct device *dev =3D rtlpriv->io.dev;
-
-	return (u8)_usb_read_sync(to_usb_device(dev), addr, 1);
+	return (u8)_usb_read_sync(rtlpriv, addr, 1);
 }
=20
 static u16 _usb_read16_sync(struct rtl_priv *rtlpriv, u32 addr)
 {
-	struct device *dev =3D rtlpriv->io.dev;
-
-	return (u16)_usb_read_sync(to_usb_device(dev), addr, 2);
+	return (u16)_usb_read_sync(rtlpriv, addr, 2);
 }
=20
 static u32 _usb_read32_sync(struct rtl_priv *rtlpriv, u32 addr)
 {
-	struct device *dev =3D rtlpriv->io.dev;
-
-	return _usb_read_sync(to_usb_device(dev), addr, 4);
+	return _usb_read_sync(rtlpriv, addr, 4);
 }
=20
 static void _usb_write_async(struct usb_device *udev, u32 addr, u32 val,
@@ -955,6 +947,11 @@ int __devinit rtl_usb_probe(struct usb_interface *intf,
 		return -ENOMEM;
 	}
 	rtlpriv =3D hw->priv;
+	rtlpriv->usb_data =3D kzalloc(RTL_USB_MAX_RX_COUNT * sizeof(u32),
+				    GFP_KERNEL);
+	if (!rtlpriv->usb_data)
+		return -ENOMEM;
+	rtlpriv->usb_data_index =3D 0;
 	init_completion(&rtlpriv->firmware_loading_complete);
 	SET_IEEE80211_DEV(hw, &intf->dev);
 	udev =3D interface_to_usbdev(intf);
@@ -1025,6 +1022,7 @@ void rtl_usb_disconnect(struct usb_interface *intf)
 	/* rtl_deinit_rfkill(hw); */
 	rtl_usb_deinit(hw);
 	rtl_deinit_core(hw);
+	kfree(rtlpriv->usb_data);
 	rtlpriv->cfg->ops->deinit_sw_leds(hw);
 	rtlpriv->cfg->ops->deinit_sw_vars(hw);
 	_rtl_usb_io_handler_release(hw);
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtl=
wifi/wifi.h
index b591614..28ebc69 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -67,7 +67,7 @@
 #define QOS_QUEUE_NUM				4
 #define RTL_MAC80211_NUM_QUEUE			5
 #define REALTEK_USB_VENQT_MAX_BUF_SIZE		254
-
+#define RTL_USB_MAX_RX_COUNT			100
 #define QBSS_LOAD_SIZE				5
 #define MAX_WMMELE_LENGTH			64
=20
@@ -1629,6 +1629,10 @@ struct rtl_priv {
 	   interface or hardware */
 	unsigned long status;
=20
+	/* data buffer pointer for USB reads */
+	__le32 *usb_data;
+	int usb_data_index;
+
 	/*This must be the last item so
 	   that it points to the data allocated
 	   beyond  this structure like:
diff --git a/include/net/bluetooth/hci.h b/include/net/bluetooth/hci.h
index 344b0f9..d47e523 100644
--- a/include/net/bluetooth/hci.h
+++ b/include/net/bluetooth/hci.h
@@ -92,6 +92,7 @@ enum {
 	HCI_SERVICE_CACHE,
 	HCI_LINK_KEYS,
 	HCI_DEBUG_KEYS,
+	HCI_UNREGISTER,
=20
 	HCI_LE_SCAN,
 	HCI_SSP_ENABLED,
@@ -1327,8 +1328,8 @@ struct sockaddr_hci {
 #define HCI_DEV_NONE	0xffff
=20
 #define HCI_CHANNEL_RAW		0
-#define HCI_CHANNEL_CONTROL	1
 #define HCI_CHANNEL_MONITOR	2
+#define HCI_CHANNEL_CONTROL	3
=20
 struct hci_filter {
 	unsigned long type_mask;
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_c=
ore.h
index daefaac..6822d25 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -427,7 +427,7 @@ enum {
 static inline bool hci_conn_ssp_enabled(struct hci_conn *conn)
 {
 	struct hci_dev *hdev =3D conn->hdev;
-	return (test_bit(HCI_SSP_ENABLED, &hdev->flags) &&
+	return (test_bit(HCI_SSP_ENABLED, &hdev->dev_flags) &&
 				test_bit(HCI_CONN_SSP_ENABLED, &conn->flags));
 }
=20
@@ -907,11 +907,13 @@ static inline void hci_role_switch_cfm(struct hci_con=
n *conn, __u8 status,
=20
 static inline bool eir_has_data_type(u8 *data, size_t data_len, u8 type)
 {
-	u8 field_len;
-	size_t parsed;
+	size_t parsed =3D 0;
=20
-	for (parsed =3D 0; parsed < data_len - 1; parsed +=3D field_len) {
-		field_len =3D data[0];
+	if (data_len < 2)
+		return false;
+
+	while (parsed < data_len - 1) {
+		u8 field_len =3D data[0];
=20
 		if (field_len =3D=3D 0)
 			break;
diff --git a/include/net/bluetooth/mgmt.h b/include/net/bluetooth/mgmt.h
index ffc1377..ebfd91f 100644
--- a/include/net/bluetooth/mgmt.h
+++ b/include/net/bluetooth/mgmt.h
@@ -117,7 +117,7 @@ struct mgmt_mode {
 #define MGMT_OP_SET_DISCOVERABLE	0x0006
 struct mgmt_cp_set_discoverable {
 	__u8	val;
-	__u16	timeout;
+	__le16	timeout;
 } __packed;
 #define MGMT_SET_DISCOVERABLE_SIZE	3
=20
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index 87d203f..9210bdc 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1327,7 +1327,7 @@ static inline struct ieee80211_rate *
 ieee80211_get_tx_rate(const struct ieee80211_hw *hw,
 		      const struct ieee80211_tx_info *c)
 {
-	if (WARN_ON(c->control.rates[0].idx < 0))
+	if (WARN_ON_ONCE(c->control.rates[0].idx < 0))
 		return NULL;
 	return &hw->wiphy->bands[c->band]->bitrates[c->control.rates[0].idx];
 }
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index e33af63..92a857e 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -665,6 +665,11 @@ int hci_dev_open(__u16 dev)
=20
 	hci_req_lock(hdev);
=20
+	if (test_bit(HCI_UNREGISTER, &hdev->dev_flags)) {
+		ret =3D -ENODEV;
+		goto done;
+	}
+
 	if (hdev->rfkill && rfkill_blocked(hdev->rfkill)) {
 		ret =3D -ERFKILL;
 		goto done;
@@ -1849,6 +1854,8 @@ void hci_unregister_dev(struct hci_dev *hdev)
=20
 	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
=20
+	set_bit(HCI_UNREGISTER, &hdev->dev_flags);
+
 	write_lock(&hci_dev_list_lock);
 	list_del(&hdev->list);
 	write_unlock(&hci_dev_list_lock);
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index b8e17e4..94552b3 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -1308,6 +1308,7 @@ static void l2cap_monitor_timeout(struct work_struct =
*work)
 	if (chan->retry_count >=3D chan->remote_max_tx) {
 		l2cap_send_disconn_req(chan->conn, chan, ECONNABORTED);
 		l2cap_chan_unlock(chan);
+		l2cap_chan_put(chan);
 		return;
 	}
=20
@@ -1316,6 +1317,7 @@ static void l2cap_monitor_timeout(struct work_struct =
*work)
=20
 	l2cap_send_rr_or_rnr(chan, L2CAP_CTRL_POLL);
 	l2cap_chan_unlock(chan);
+	l2cap_chan_put(chan);
 }
=20
 static void l2cap_retrans_timeout(struct work_struct *work)
@@ -1335,6 +1337,7 @@ static void l2cap_retrans_timeout(struct work_struct =
*work)
 	l2cap_send_rr_or_rnr(chan, L2CAP_CTRL_POLL);
=20
 	l2cap_chan_unlock(chan);
+	l2cap_chan_put(chan);
 }
=20
 static void l2cap_drop_acked_frames(struct l2cap_chan *chan)
diff --git a/net/bluetooth/l2cap_sock.c b/net/bluetooth/l2cap_sock.c
index c4fe583..29122ed 100644
--- a/net/bluetooth/l2cap_sock.c
+++ b/net/bluetooth/l2cap_sock.c
@@ -82,7 +82,7 @@ static int l2cap_sock_bind(struct socket *sock, struct so=
ckaddr *addr, int alen)
 	}
=20
 	if (la.l2_cid)
-		err =3D l2cap_add_scid(chan, la.l2_cid);
+		err =3D l2cap_add_scid(chan, __le16_to_cpu(la.l2_cid));
 	else
 		err =3D l2cap_add_psm(chan, &la.l2_bdaddr, la.l2_psm);
=20
@@ -123,7 +123,8 @@ static int l2cap_sock_connect(struct socket *sock, stru=
ct sockaddr *addr, int al
 	if (la.l2_cid && la.l2_psm)
 		return -EINVAL;
=20
-	err =3D l2cap_chan_connect(chan, la.l2_psm, la.l2_cid, &la.l2_bdaddr);
+	err =3D l2cap_chan_connect(chan, la.l2_psm, __le16_to_cpu(la.l2_cid),
+				&la.l2_bdaddr);
 	if (err)
 		return err;
=20
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 7fcff88..4ef275c 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -2523,13 +2523,18 @@ static int set_fast_connectable(struct sock *sk, st=
ruct hci_dev *hdev,
=20
 	if (cp->val) {
 		type =3D PAGE_SCAN_TYPE_INTERLACED;
-		acp.interval =3D 0x0024;	/* 22.5 msec page scan interval */
+
+		/* 22.5 msec page scan interval */
+		acp.interval =3D __constant_cpu_to_le16(0x0024);
 	} else {
 		type =3D PAGE_SCAN_TYPE_STANDARD;	/* default */
-		acp.interval =3D 0x0800;	/* default 1.28 sec page scan */
+
+		/* default 1.28 sec page scan */
+		acp.interval =3D __constant_cpu_to_le16(0x0800);
 	}
=20
-	acp.window =3D 0x0012;	/* default 11.25 msec page scan window */
+	/* default 11.25 msec page scan window */
+	acp.window =3D __constant_cpu_to_le16(0x0012);
=20
 	err =3D hci_send_cmd(hdev, HCI_OP_WRITE_PAGE_SCAN_ACTIVITY, sizeof(acp),
 			   &acp);
@@ -2936,7 +2941,7 @@ int mgmt_device_connected(struct hci_dev *hdev, bdadd=
r_t *bdaddr, u8 link_type,
 					  name, name_len);
=20
 	if (dev_class && memcmp(dev_class, "\0\0\0", 3) !=3D 0)
-		eir_len =3D eir_append_data(&ev->eir[eir_len], eir_len,
+		eir_len =3D eir_append_data(ev->eir, eir_len,
 					  EIR_CLASS_OF_DEV, dev_class, 3);
=20
 	put_unaligned_le16(eir_len, &ev->eir_len);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 576fb25..f76da5b 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3387,8 +3387,7 @@ int ieee80211_mgd_assoc(struct ieee80211_sub_if_data =
*sdata,
 		 */
 		printk(KERN_DEBUG "%s: waiting for beacon from %pM\n",
 		       sdata->name, ifmgd->bssid);
-		assoc_data->timeout =3D jiffies +
-				TU_TO_EXP_TIME(req->bss->beacon_interval);
+		assoc_data->timeout =3D TU_TO_EXP_TIME(req->bss->beacon_interval);
 	} else {
 		assoc_data->have_beacon =3D true;
 		assoc_data->sent_assoc =3D false;
diff --git a/net/nfc/llcp/commands.c b/net/nfc/llcp/commands.c
index 7b76eb7..ef10ffc 100644
--- a/net/nfc/llcp/commands.c
+++ b/net/nfc/llcp/commands.c
@@ -474,7 +474,7 @@ int nfc_llcp_send_i_frame(struct nfc_llcp_sock *sock,
=20
 	while (remaining_len > 0) {
=20
-		frag_len =3D min_t(u16, local->remote_miu, remaining_len);
+		frag_len =3D min_t(size_t, local->remote_miu, remaining_len);
=20
 		pr_debug("Fragment %zd bytes remaining %zd",
 			 frag_len, remaining_len);
@@ -497,7 +497,7 @@ int nfc_llcp_send_i_frame(struct nfc_llcp_sock *sock,
 		release_sock(sk);
=20
 		remaining_len -=3D frag_len;
-		msg_ptr +=3D len;
+		msg_ptr +=3D frag_len;
 	}
=20
 	kfree(msg_data);
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index e49da27..f432c57 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1294,6 +1294,11 @@ static int nl80211_set_wiphy(struct sk_buff *skb, st=
ruct genl_info *info)
 			goto bad_res;
 		}
=20
+		if (!netif_running(netdev)) {
+			result =3D -ENETDOWN;
+			goto bad_res;
+		}
+
 		nla_for_each_nested(nl_txq_params,
 				    info->attrs[NL80211_ATTR_WIPHY_TXQ_PARAMS],
 				    rem_txq_params) {
@@ -6384,7 +6389,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.doit =3D nl80211_get_key,
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6416,7 +6421,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
 		.doit =3D nl80211_set_beacon,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6424,7 +6429,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
 		.doit =3D nl80211_start_ap,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6432,7 +6437,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
 		.doit =3D nl80211_stop_ap,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6448,7 +6453,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.doit =3D nl80211_set_station,
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6464,7 +6469,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.doit =3D nl80211_del_station,
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6497,7 +6502,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.doit =3D nl80211_del_mpath,
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6505,7 +6510,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.doit =3D nl80211_set_bss,
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6531,7 +6536,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.doit =3D nl80211_get_mesh_config,
 		.policy =3D nl80211_policy,
 		/* can be retrieved by unprivileged users */
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6664,7 +6669,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.doit =3D nl80211_setdel_pmksa,
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6672,7 +6677,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.doit =3D nl80211_setdel_pmksa,
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6680,7 +6685,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.doit =3D nl80211_flush_pmksa,
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
@@ -6840,7 +6845,7 @@ static struct genl_ops nl80211_ops[] =3D {
 		.doit =3D nl80211_probe_client,
 		.policy =3D nl80211_policy,
 		.flags =3D GENL_ADMIN_PERM,
-		.internal_flags =3D NL80211_FLAG_NEED_NETDEV |
+		.internal_flags =3D NL80211_FLAG_NEED_NETDEV_UP |
 				  NL80211_FLAG_NEED_RTNL,
 	},
 	{
diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index 0af7f54..af648e0 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -780,8 +780,10 @@ static int ioctl_standard_iw_point(struct iw_point *iw=
p, unsigned int cmd,
 		if (cmd =3D=3D SIOCSIWENCODEEXT) {
 			struct iw_encode_ext *ee =3D (void *) extra;
=20
-			if (iwp->length < sizeof(*ee) + ee->key_len)
-				return -EFAULT;
+			if (iwp->length < sizeof(*ee) + ee->key_len) {
+				err =3D -EFAULT;
+				goto out;
+			}
 		}
 	}
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPhuarAAoJEJctW/TcYTgGhTQP/1iXk1S1IfZk4Nvp+XUSqm8o
+Umd5mRZGmD03+ykHNkFZayFYAkHNsGtYio2x0ADErbpzoFkk+G6ug6skSeB+N97
5+cDjb0LoTOSLc/xRPcnlZcC8BTziVIbxbALSOrH9hexp4pFYht5FBitHs4cEEwf
dOwzQgRcybmCVHBqu12FI+CBQVTwh29JFCQj6PO3VJoIYw+P580ICzidtNrvcAxp
nwoVPDGgxagiRBlHlxFgKkC6ODjQ3aChtXeCi4WshqBX5zUHj2Ezi3PW/rM+dG11
sdDpRTeSofadEdekAFocw0Jhzmt8XrFr1HhIsxI76EMdyNIGOYVMTt/o5AseloL3
DgIPIp3kkWIOVCZybgvvwLnih182mgTrYzye7cW2Gcx4WS+k/rmxXWoYELCB7r1o
JeKHQU5xpSGP6t1EuZ/jLge0rwGhHLewGw008hupHcHy1vYA7j7oKPZ+LtzrHMpU
LiS0l3bQSM6QsslaX4rZ7uijUxaLbBuCWhhBM1DjReKyrqrlTE/L3YDEJjN14/Hw
0LRhmECNgrG9sVJwF+GpSRBUgFDSvVRUsX4df0k/b41q+8DXYqtMww2BiaYK64SN
o7rnQKSYhwC5WrJfOcM8NuOU0sOk9ys+4MVDP6uyXVCPFlSwM1xgm7ps2kpjXmg2
FgbqNEhfp0GpLbkInoOT
=rOwn
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--
