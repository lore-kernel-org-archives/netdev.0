From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2013-06-03
Date: Mon, 3 Jun 2013 14:48:17 -0400
Message-ID: <20130603184817.GD2727@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Still another batch of fixes intended for the 3.10 stream...  This
includes a big batch of fixes for brcmfmac, along with a Bluetooth pull
and a couple of other fixes.

Regarding the brcmfmac batch, Arend makes the following plea:

"This is a somewhat large series and reading the message of the
announcement of v3.10-rc3 I think it is good to give our story
up front.  Firmware-signalling is a new feature merged in for 3.10,
which was a major overhaul of the transmit path in brcmfmac. During and
after the merge window we still have some blanks in our test coverage
and further testing revealed issues with P2P, TDLS, and power-saving
clients in AP mode. These issues have been fixed in this series."

As for the Bluetooth bits, Gustavo says:

"The following patches are important bug fixes for 3.10, plus the
support for a new device. We do have three fixes from Johan. The first
one is a fix to avoid LE-only devices to rely on the (inexistent)
extended features data. The second patch fixes length checks on
incoming L2CAP signalling PDUs so we can discard PDU whose size
doesn't match the one reported in the header.  The last one fixes
the handling of power on failures, we now report proper errors to
mgmt when hci_dev_open()."

Along with that...

Arend also reverts an earlier brcmsmac patch that causes a regression
in 3.10-rc1.

Larry Finger corrects an rtlwifi problem that caused some devices to
refuse to connect to non-WPA2 networks if the device had previously
assocated with a WPA2 network.

Mark A. Greer fixes an out of bounds array access in mwifiex.

Please let me know if there are problems!

John

---

The following changes since commit 01cb71d2d47b78354358e4bb938bb06323e17498:

  net_sched: restore "overhead xxx" handling (2013-06-02 22:22:35 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 6eba8cf4d7b3d9fce0575927777407743bd070bb:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-06-03 14:18:13 -0400)

----------------------------------------------------------------

Arend van Spriel (7):
      brcmfmac: allow firmware-signal tlv to be longer than specified
      brcmfmac: remove fifo bitfield from brcmf_skbuff_cb::if_flags
      brcmfmac: rework credit pickup to assure consistent handling
      brcmfmac: explicitly indicate sk_buff is sent upon request credit
      brcmfmac: reducing debug logging in firmware-signalling code
      brcmfmac: Sent TIM information in case of data available.
      brcmsmac: fix regression observed in 3.10-rc1

Bing Zhao (1):
      Bluetooth: btmrvl: support Marvell Bluetooth device SD8897

Hante Meuleman (10):
      brcmfmac: Take bus flowcontrol at credit mgmt into account.
      brcmfmac: On bus flow control use fw signalling or netif.
      brcmfmac: For FW signalling it is necessary to track gen bit.
      brcmfmac: Correct creditmap when credit borrowing is active.
      brcmfmac: Find correct MAC descriptor in case of TDLS.
      brcmfmac: fix invalid ifp lookup in firmware-signalling
      brcmfmac: Accept only first creditmap event.
      brcmfmac: Signalling header push and pull on logic places.
      brcmfmac: Fix endless loop when brcmf_fws_commit_skb fails.
      brcmfmac: Simplify counting transit count.

Johan Hedberg (3):
      Bluetooth: Fix checks for LE support on LE-only controllers
      Bluetooth: Fix missing length checks for L2CAP signalling PDUs
      Bluetooth: Fix mgmt handling of power on failures

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtlwifi: rtl8192cu: Fix problem in connecting to WEP or WPA(1) networ=
ks

Mark A. Greer (1):
      mwifiex: debugfs: Fix out of bounds array access

 drivers/bluetooth/Kconfig                          |   4 +-
 drivers/bluetooth/btmrvl_sdio.c                    |  28 +
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   2 +
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  21 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c | 638 ++++++++++-------=
----
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h |   1 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   8 +
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  17 +-
 drivers/net/wireless/mwifiex/debugfs.c             |  22 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        | 134 +++--
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.h        |   4 -
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |  18 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.h        |   3 +
 drivers/net/wireless/rtlwifi/usb.c                 |  13 +
 drivers/net/wireless/rtlwifi/wifi.h                |   4 +
 include/net/bluetooth/hci_core.h                   |   1 +
 include/net/bluetooth/mgmt.h                       |   1 +
 net/bluetooth/hci_core.c                           |   6 +-
 net/bluetooth/l2cap_core.c                         |  70 ++-
 net/bluetooth/mgmt.c                               |  23 +-
 net/bluetooth/smp.c                                |   4 +-
 23 files changed, 610 insertions(+), 418 deletions(-)

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index fdfd61a..11a6104 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -201,7 +201,7 @@ config BT_MRVL
 	  The core driver to support Marvell Bluetooth devices.
=20
 	  This driver is required if you want to support
-	  Marvell Bluetooth devices, such as 8688/8787/8797.
+	  Marvell Bluetooth devices, such as 8688/8787/8797/8897.
=20
 	  Say Y here to compile Marvell Bluetooth driver
 	  into the kernel or say M to compile it as module.
@@ -214,7 +214,7 @@ config BT_MRVL_SDIO
 	  The driver for Marvell Bluetooth chipsets with SDIO interface.
=20
 	  This driver is required if you want to use Marvell Bluetooth
-	  devices with SDIO interface. Currently SD8688/SD8787/SD8797
+	  devices with SDIO interface. Currently SD8688/SD8787/SD8797/SD8897
 	  chipsets are supported.
=20
 	  Say Y here to compile support for Marvell BT-over-SDIO driver
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdi=
o.c
index c63488c..13693b7 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -82,6 +82,23 @@ static const struct btmrvl_sdio_card_reg btmrvl_reg_87xx=
 =3D {
 	.io_port_2 =3D 0x7a,
 };
=20
+static const struct btmrvl_sdio_card_reg btmrvl_reg_88xx =3D {
+	.cfg =3D 0x00,
+	.host_int_mask =3D 0x02,
+	.host_intstatus =3D 0x03,
+	.card_status =3D 0x50,
+	.sq_read_base_addr_a0 =3D 0x60,
+	.sq_read_base_addr_a1 =3D 0x61,
+	.card_revision =3D 0xbc,
+	.card_fw_status0 =3D 0xc0,
+	.card_fw_status1 =3D 0xc1,
+	.card_rx_len =3D 0xc2,
+	.card_rx_unit =3D 0xc3,
+	.io_port_0 =3D 0xd8,
+	.io_port_1 =3D 0xd9,
+	.io_port_2 =3D 0xda,
+};
+
 static const struct btmrvl_sdio_device btmrvl_sdio_sd8688 =3D {
 	.helper		=3D "mrvl/sd8688_helper.bin",
 	.firmware	=3D "mrvl/sd8688.bin",
@@ -103,6 +120,13 @@ static const struct btmrvl_sdio_device btmrvl_sdio_sd8=
797 =3D {
 	.sd_blksz_fw_dl	=3D 256,
 };
=20
+static const struct btmrvl_sdio_device btmrvl_sdio_sd8897 =3D {
+	.helper		=3D NULL,
+	.firmware	=3D "mrvl/sd8897_uapsta.bin",
+	.reg		=3D &btmrvl_reg_88xx,
+	.sd_blksz_fw_dl	=3D 256,
+};
+
 static const struct sdio_device_id btmrvl_sdio_ids[] =3D {
 	/* Marvell SD8688 Bluetooth device */
 	{ SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, 0x9105),
@@ -116,6 +140,9 @@ static const struct sdio_device_id btmrvl_sdio_ids[] =
=3D {
 	/* Marvell SD8797 Bluetooth device */
 	{ SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, 0x912A),
 			.driver_data =3D (unsigned long) &btmrvl_sdio_sd8797 },
+	/* Marvell SD8897 Bluetooth device */
+	{ SDIO_DEVICE(SDIO_VENDOR_ID_MARVELL, 0x912E),
+			.driver_data =3D (unsigned long) &btmrvl_sdio_sd8897 },
=20
 	{ }	/* Terminating entry */
 };
@@ -1194,3 +1221,4 @@ MODULE_FIRMWARE("mrvl/sd8688_helper.bin");
 MODULE_FIRMWARE("mrvl/sd8688.bin");
 MODULE_FIRMWARE("mrvl/sd8787_uapsta.bin");
 MODULE_FIRMWARE("mrvl/sd8797_uapsta.bin");
+MODULE_FIRMWARE("mrvl/sd8897_uapsta.bin");
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd.h b/drivers/net/wi=
reless/brcm80211/brcmfmac/dhd.h
index 28db9cf..86cbfe2 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd.h
@@ -583,6 +583,7 @@ enum brcmf_netif_stop_reason {
  * @bssidx: index of bss associated with this interface.
  * @mac_addr: assigned mac address.
  * @netif_stop: bitmap indicates reason why netif queues are stopped.
+ * @netif_stop_lock: spinlock for update netif_stop from multiple sources.
  * @pend_8021x_cnt: tracks outstanding number of 802.1x frames.
  * @pend_8021x_wait: used for signalling change in count.
  */
@@ -598,6 +599,7 @@ struct brcmf_if {
 	s32 bssidx;
 	u8 mac_addr[ETH_ALEN];
 	u8 netif_stop;
+	spinlock_t netif_stop_lock;
 	atomic_t pend_8021x_cnt;
 	wait_queue_head_t pend_8021x_wait;
 };
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c b/drivers/=
net/wireless/brcm80211/brcmfmac/dhd_linux.c
index b98f223..63cadf6 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_linux.c
@@ -179,7 +179,7 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_bu=
ff *skb,
 	struct brcmf_pub *drvr =3D ifp->drvr;
 	struct ethhdr *eh;
=20
-	brcmf_dbg(TRACE, "Enter, idx=3D%d\n", ifp->bssidx);
+	brcmf_dbg(DATA, "Enter, idx=3D%d\n", ifp->bssidx);
=20
 	/* Can the device send data? */
 	if (drvr->bus_if->state !=3D BRCMF_BUS_DATA) {
@@ -240,11 +240,15 @@ done:
 void brcmf_txflowblock_if(struct brcmf_if *ifp,
 			  enum brcmf_netif_stop_reason reason, bool state)
 {
+	unsigned long flags;
+
 	if (!ifp)
 		return;
=20
 	brcmf_dbg(TRACE, "enter: idx=3D%d stop=3D0x%X reason=3D%d state=3D%d\n",
 		  ifp->bssidx, ifp->netif_stop, reason, state);
+
+	spin_lock_irqsave(&ifp->netif_stop_lock, flags);
 	if (state) {
 		if (!ifp->netif_stop)
 			netif_stop_queue(ifp->ndev);
@@ -254,6 +258,7 @@ void brcmf_txflowblock_if(struct brcmf_if *ifp,
 		if (!ifp->netif_stop)
 			netif_wake_queue(ifp->ndev);
 	}
+	spin_unlock_irqrestore(&ifp->netif_stop_lock, flags);
 }
=20
 void brcmf_txflowblock(struct device *dev, bool state)
@@ -264,9 +269,14 @@ void brcmf_txflowblock(struct device *dev, bool state)
=20
 	brcmf_dbg(TRACE, "Enter\n");
=20
-	for (i =3D 0; i < BRCMF_MAX_IFS; i++)
-		brcmf_txflowblock_if(drvr->iflist[i],
-				     BRCMF_NETIF_STOP_REASON_BLOCK_BUS, state);
+	if (brcmf_fws_fc_active(drvr->fws)) {
+		brcmf_fws_bus_blocked(drvr, state);
+	} else {
+		for (i =3D 0; i < BRCMF_MAX_IFS; i++)
+			brcmf_txflowblock_if(drvr->iflist[i],
+					     BRCMF_NETIF_STOP_REASON_BLOCK_BUS,
+					     state);
+	}
 }
=20
 void brcmf_rx_frames(struct device *dev, struct sk_buff_head *skb_list)
@@ -280,7 +290,7 @@ void brcmf_rx_frames(struct device *dev, struct sk_buff=
_head *skb_list)
 	u8 ifidx;
 	int ret;
=20
-	brcmf_dbg(TRACE, "Enter\n");
+	brcmf_dbg(DATA, "Enter\n");
=20
 	skb_queue_walk_safe(skb_list, skb, pnext) {
 		skb_unlink(skb, skb_list);
@@ -779,6 +789,7 @@ struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s=
32 bssidx, s32 ifidx,
 	ifp->bssidx =3D bssidx;
=20
 	init_waitqueue_head(&ifp->pend_8021x_wait);
+	spin_lock_init(&ifp->netif_stop_lock);
=20
 	if (mac_addr !=3D NULL)
 		memcpy(ifp->mac_addr, mac_addr, ETH_ALEN);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/n=
et/wireless/brcm80211/brcmfmac/dhd_sdio.c
index d248751..6f3d181 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -2369,12 +2369,12 @@ static int brcmf_sdbrcm_bus_txdata(struct device *d=
ev, struct sk_buff *pkt)
 	} else {
 		ret =3D 0;
 	}
-	spin_unlock_bh(&bus->txqlock);
=20
 	if (pktq_len(&bus->txq) >=3D TXHI) {
 		bus->txoff =3D true;
 		brcmf_txflowblock(bus->sdiodev->dev, true);
 	}
+	spin_unlock_bh(&bus->txqlock);
=20
 #ifdef DEBUG
 	if (pktq_plen(&bus->txq, prec) > qcount[prec])
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c b/drivers/n=
et/wireless/brcm80211/brcmfmac/fwsignal.c
index 5352dc1..ea37bd4 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c
@@ -157,11 +157,13 @@ static const char *brcmf_fws_get_tlv_name(enum brcmf_=
fws_tlv_type id)
  * @BRCMF_FWS_SKBSTATE_NEW: sk_buff is newly arrived in the driver.
  * @BRCMF_FWS_SKBSTATE_DELAYED: sk_buff had to wait on queue.
  * @BRCMF_FWS_SKBSTATE_SUPPRESSED: sk_buff has been suppressed by firmware.
+ * @BRCMF_FWS_SKBSTATE_TIM: allocated for TIM update info.
  */
 enum brcmf_fws_skb_state {
 	BRCMF_FWS_SKBSTATE_NEW,
 	BRCMF_FWS_SKBSTATE_DELAYED,
-	BRCMF_FWS_SKBSTATE_SUPPRESSED
+	BRCMF_FWS_SKBSTATE_SUPPRESSED,
+	BRCMF_FWS_SKBSTATE_TIM
 };
=20
 /**
@@ -190,14 +192,16 @@ struct brcmf_skbuff_cb {
 /*
  * sk_buff control if flags
  *
- *	b[11]  - packet sent upon firmware request.
+ *	b[12]  - packet sent upon credit request.
+ *	b[11]  - packet sent upon packet request.
  *	b[10]  - packet only contains signalling data.
  *	b[9]   - packet is a tx packet.
  *	b[8]   - packet uses FIFO credit (non-pspoll).
  *	b[7]   - interface in AP mode.
- *	b[6:4] - AC FIFO number.
  *	b[3:0] - interface index.
  */
+#define BRCMF_SKB_IF_FLAGS_REQ_CREDIT_MASK	0x1000
+#define BRCMF_SKB_IF_FLAGS_REQ_CREDIT_SHIFT	12
 #define BRCMF_SKB_IF_FLAGS_REQUESTED_MASK	0x0800
 #define BRCMF_SKB_IF_FLAGS_REQUESTED_SHIFT	11
 #define BRCMF_SKB_IF_FLAGS_SIGNAL_ONLY_MASK	0x0400
@@ -208,8 +212,6 @@ struct brcmf_skbuff_cb {
 #define BRCMF_SKB_IF_FLAGS_CREDITCHECK_SHIFT	8
 #define BRCMF_SKB_IF_FLAGS_IF_AP_MASK		0x0080
 #define BRCMF_SKB_IF_FLAGS_IF_AP_SHIFT		7
-#define BRCMF_SKB_IF_FLAGS_FIFO_MASK		0x0070
-#define BRCMF_SKB_IF_FLAGS_FIFO_SHIFT		4
 #define BRCMF_SKB_IF_FLAGS_INDEX_MASK		0x000f
 #define BRCMF_SKB_IF_FLAGS_INDEX_SHIFT		0
=20
@@ -246,7 +248,7 @@ struct brcmf_skbuff_cb {
 #define BRCMF_SKB_HTOD_TAG_HSLOT_MASK			0x00ffff00
 #define BRCMF_SKB_HTOD_TAG_HSLOT_SHIFT			8
 #define BRCMF_SKB_HTOD_TAG_FREERUN_MASK			0x000000ff
-#define BRCMF_SKB_HTOD_TAG_FREERUN_SHIFT			0
+#define BRCMF_SKB_HTOD_TAG_FREERUN_SHIFT		0
=20
 #define brcmf_skb_htod_tag_set_field(skb, field, value) \
 	brcmu_maskset32(&(brcmf_skbcb(skb)->htod), \
@@ -278,6 +280,7 @@ struct brcmf_skbuff_cb {
 /**
  * enum brcmf_fws_fifo - fifo indices used by dongle firmware.
  *
+ * @BRCMF_FWS_FIFO_FIRST: first fifo, ie. background.
  * @BRCMF_FWS_FIFO_AC_BK: fifo for background traffic.
  * @BRCMF_FWS_FIFO_AC_BE: fifo for best-effort traffic.
  * @BRCMF_FWS_FIFO_AC_VI: fifo for video traffic.
@@ -287,7 +290,8 @@ struct brcmf_skbuff_cb {
  * @BRCMF_FWS_FIFO_COUNT: number of fifos.
  */
 enum brcmf_fws_fifo {
-	BRCMF_FWS_FIFO_AC_BK,
+	BRCMF_FWS_FIFO_FIRST,
+	BRCMF_FWS_FIFO_AC_BK =3D BRCMF_FWS_FIFO_FIRST,
 	BRCMF_FWS_FIFO_AC_BE,
 	BRCMF_FWS_FIFO_AC_VI,
 	BRCMF_FWS_FIFO_AC_VO,
@@ -343,6 +347,7 @@ enum brcmf_fws_mac_desc_state {
  * @transit_count: packet in transit to firmware.
  */
 struct brcmf_fws_mac_descriptor {
+	char name[16];
 	u8 occupied;
 	u8 mac_handle;
 	u8 interface_id;
@@ -356,7 +361,6 @@ struct brcmf_fws_mac_descriptor {
 	u8 seq[BRCMF_FWS_FIFO_COUNT];
 	struct pktq psq;
 	int transit_count;
-	int suppress_count;
 	int suppr_transit_count;
 	bool send_tim_signal;
 	u8 traffic_pending_bmp;
@@ -383,12 +387,10 @@ enum brcmf_fws_hanger_item_state {
  * struct brcmf_fws_hanger_item - single entry for tx pending packet.
  *
  * @state: entry is either free or occupied.
- * @gen: generation.
  * @pkt: packet itself.
  */
 struct brcmf_fws_hanger_item {
 	enum brcmf_fws_hanger_item_state state;
-	u8 gen;
 	struct sk_buff *pkt;
 };
=20
@@ -434,6 +436,8 @@ struct brcmf_fws_info {
 	u32 fifo_credit_map;
 	u32 fifo_delay_map;
 	unsigned long borrow_defer_timestamp;
+	bool bus_flow_blocked;
+	bool creditmap_received;
 };
=20
 /*
@@ -507,7 +511,6 @@ static void brcmf_fws_hanger_init(struct brcmf_fws_hang=
er *hanger)
 {
 	int i;
=20
-	brcmf_dbg(TRACE, "enter\n");
 	memset(hanger, 0, sizeof(*hanger));
 	for (i =3D 0; i < ARRAY_SIZE(hanger->items); i++)
 		hanger->items[i].state =3D BRCMF_FWS_HANGER_ITEM_STATE_FREE;
@@ -517,7 +520,6 @@ static u32 brcmf_fws_hanger_get_free_slot(struct brcmf_=
fws_hanger *h)
 {
 	u32 i;
=20
-	brcmf_dbg(TRACE, "enter\n");
 	i =3D (h->slot_pos + 1) % BRCMF_FWS_HANGER_MAXITEMS;
=20
 	while (i !=3D h->slot_pos) {
@@ -533,14 +535,12 @@ static u32 brcmf_fws_hanger_get_free_slot(struct brcm=
f_fws_hanger *h)
 	h->failed_slotfind++;
 	i =3D BRCMF_FWS_HANGER_MAXITEMS;
 done:
-	brcmf_dbg(TRACE, "exit: %d\n", i);
 	return i;
 }
=20
 static int brcmf_fws_hanger_pushpkt(struct brcmf_fws_hanger *h,
-					   struct sk_buff *pkt, u32 slot_id)
+				    struct sk_buff *pkt, u32 slot_id)
 {
-	brcmf_dbg(TRACE, "enter\n");
 	if (slot_id >=3D BRCMF_FWS_HANGER_MAXITEMS)
 		return -ENOENT;
=20
@@ -560,7 +560,6 @@ static int brcmf_fws_hanger_poppkt(struct brcmf_fws_han=
ger *h,
 					  u32 slot_id, struct sk_buff **pktout,
 					  bool remove_item)
 {
-	brcmf_dbg(TRACE, "enter\n");
 	if (slot_id >=3D BRCMF_FWS_HANGER_MAXITEMS)
 		return -ENOENT;
=20
@@ -574,22 +573,17 @@ static int brcmf_fws_hanger_poppkt(struct brcmf_fws_h=
anger *h,
 	if (remove_item) {
 		h->items[slot_id].state =3D BRCMF_FWS_HANGER_ITEM_STATE_FREE;
 		h->items[slot_id].pkt =3D NULL;
-		h->items[slot_id].gen =3D 0xff;
 		h->popped++;
 	}
 	return 0;
 }
=20
 static int brcmf_fws_hanger_mark_suppressed(struct brcmf_fws_hanger *h,
-						   u32 slot_id, u8 gen)
+					    u32 slot_id)
 {
-	brcmf_dbg(TRACE, "enter\n");
-
 	if (slot_id >=3D BRCMF_FWS_HANGER_MAXITEMS)
 		return -ENOENT;
=20
-	h->items[slot_id].gen =3D gen;
-
 	if (h->items[slot_id].state !=3D BRCMF_FWS_HANGER_ITEM_STATE_INUSE) {
 		brcmf_err("entry not in use\n");
 		return -EINVAL;
@@ -599,25 +593,6 @@ static int brcmf_fws_hanger_mark_suppressed(struct brc=
mf_fws_hanger *h,
 	return 0;
 }
=20
-static int brcmf_fws_hanger_get_genbit(struct brcmf_fws_hanger *hanger,
-					      struct sk_buff *pkt, u32 slot_id,
-					      int *gen)
-{
-	brcmf_dbg(TRACE, "enter\n");
-	*gen =3D 0xff;
-
-	if (slot_id >=3D BRCMF_FWS_HANGER_MAXITEMS)
-		return -ENOENT;
-
-	if (hanger->items[slot_id].state =3D=3D BRCMF_FWS_HANGER_ITEM_STATE_FREE)=
 {
-		brcmf_err("slot not in use\n");
-		return -EINVAL;
-	}
-
-	*gen =3D hanger->items[slot_id].gen;
-	return 0;
-}
-
 static void brcmf_fws_hanger_cleanup(struct brcmf_fws_info *fws,
 				     bool (*fn)(struct sk_buff *, void *),
 				     int ifidx)
@@ -627,7 +602,6 @@ static void brcmf_fws_hanger_cleanup(struct brcmf_fws_i=
nfo *fws,
 	int i;
 	enum brcmf_fws_hanger_item_state s;
=20
-	brcmf_dbg(TRACE, "enter: ifidx=3D%d\n", ifidx);
 	for (i =3D 0; i < ARRAY_SIZE(h->items); i++) {
 		s =3D h->items[i].state;
 		if (s =3D=3D BRCMF_FWS_HANGER_ITEM_STATE_INUSE ||
@@ -644,6 +618,19 @@ static void brcmf_fws_hanger_cleanup(struct brcmf_fws_=
info *fws,
 	}
 }
=20
+static void brcmf_fws_macdesc_set_name(struct brcmf_fws_info *fws,
+				       struct brcmf_fws_mac_descriptor *desc)
+{
+	if (desc =3D=3D &fws->desc.other)
+		strlcpy(desc->name, "MAC-OTHER", sizeof(desc->name));
+	else if (desc->mac_handle)
+		scnprintf(desc->name, sizeof(desc->name), "MAC-%d:%d",
+			  desc->mac_handle, desc->interface_id);
+	else
+		scnprintf(desc->name, sizeof(desc->name), "MACIF:%d",
+			  desc->interface_id);
+}
+
 static void brcmf_fws_init_mac_descriptor(struct brcmf_fws_mac_descriptor =
*desc,
 					  u8 *addr, u8 ifidx)
 {
@@ -675,7 +662,6 @@ brcmf_fws_mac_descriptor_lookup(struct brcmf_fws_info *=
fws, u8 *ea)
 	struct brcmf_fws_mac_descriptor *entry;
 	int i;
=20
-	brcmf_dbg(TRACE, "enter: ea=3D%pM\n", ea);
 	if (ea =3D=3D NULL)
 		return ERR_PTR(-EINVAL);
=20
@@ -695,31 +681,23 @@ brcmf_fws_find_mac_desc(struct brcmf_fws_info *fws, s=
truct brcmf_if *ifp,
 {
 	struct brcmf_fws_mac_descriptor *entry =3D &fws->desc.other;
 	bool multicast;
-	enum nl80211_iftype iftype;
-
-	brcmf_dbg(TRACE, "enter: idx=3D%d\n", ifp->bssidx);
=20
 	multicast =3D is_multicast_ether_addr(da);
-	iftype =3D brcmf_cfg80211_get_iftype(ifp);
=20
-	/* Multicast destination and P2P clients get the interface entry.
-	 * STA gets the interface entry if there is no exact match. For
-	 * example, TDLS destinations have their own entry.
+	/* Multicast destination, STA and P2P clients get the interface entry.
+	 * STA/GC gets the Mac Entry for TDLS destinations, TDLS destinations
+	 * have their own entry.
 	 */
-	entry =3D NULL;
-	if ((multicast || iftype =3D=3D NL80211_IFTYPE_STATION ||
-	     iftype =3D=3D NL80211_IFTYPE_P2P_CLIENT) && ifp->fws_desc)
+	if (multicast && ifp->fws_desc) {
 		entry =3D ifp->fws_desc;
-
-	if (entry !=3D NULL && iftype !=3D NL80211_IFTYPE_STATION)
 		goto done;
+	}
=20
 	entry =3D brcmf_fws_mac_descriptor_lookup(fws, da);
 	if (IS_ERR(entry))
-		entry =3D &fws->desc.other;
+		entry =3D ifp->fws_desc;
=20
 done:
-	brcmf_dbg(TRACE, "exit: entry=3D%p\n", entry);
 	return entry;
 }
=20
@@ -752,11 +730,7 @@ static void brcmf_fws_mac_desc_cleanup(struct brcmf_fw=
s_info *fws,
 				       struct brcmf_fws_mac_descriptor *entry,
 				       int ifidx)
 {
-	brcmf_dbg(TRACE, "enter: entry=3D(ea=3D%pM, ifid=3D%d), ifidx=3D%d\n",
-		  entry->ea, entry->interface_id, ifidx);
 	if (entry->occupied && (ifidx =3D=3D -1 || ifidx =3D=3D entry->interface_=
id)) {
-		brcmf_dbg(TRACE, "flush psq: ifidx=3D%d, qlen=3D%d\n",
-			  ifidx, entry->psq.len);
 		brcmf_fws_psq_flush(fws, &entry->psq, ifidx);
 		entry->occupied =3D !!(entry->psq.len);
 	}
@@ -772,7 +746,6 @@ static void brcmf_fws_bus_txq_cleanup(struct brcmf_fws_=
info *fws,
 	int prec;
 	u32 hslot;
=20
-	brcmf_dbg(TRACE, "enter: ifidx=3D%d\n", ifidx);
 	txq =3D brcmf_bus_gettxq(fws->drvr->bus_if);
 	if (IS_ERR(txq)) {
 		brcmf_dbg(TRACE, "no txq to clean up\n");
@@ -798,7 +771,6 @@ static void brcmf_fws_cleanup(struct brcmf_fws_info *fw=
s, int ifidx)
 	struct brcmf_fws_mac_descriptor *table;
 	bool (*matchfn)(struct sk_buff *, void *) =3D NULL;
=20
-	brcmf_dbg(TRACE, "enter: ifidx=3D%d\n", ifidx);
 	if (fws =3D=3D NULL)
 		return;
=20
@@ -815,37 +787,106 @@ static void brcmf_fws_cleanup(struct brcmf_fws_info =
*fws, int ifidx)
 	brcmf_fws_hanger_cleanup(fws, matchfn, ifidx);
 }
=20
-static void brcmf_fws_tim_update(struct brcmf_fws_info *ctx,
-				 struct brcmf_fws_mac_descriptor *entry,
-				 int prec)
+static int brcmf_fws_hdrpush(struct brcmf_fws_info *fws, struct sk_buff *s=
kb)
 {
-	brcmf_dbg(TRACE, "enter: ea=3D%pM\n", entry->ea);
-	if (entry->state =3D=3D BRCMF_FWS_STATE_CLOSE) {
-		/* check delayedQ and suppressQ in one call using bitmap */
-		if (brcmu_pktq_mlen(&entry->psq, 3 << (prec * 2)) =3D=3D 0)
-			entry->traffic_pending_bmp =3D
-				entry->traffic_pending_bmp & ~NBITVAL(prec);
-		else
-			entry->traffic_pending_bmp =3D
-				entry->traffic_pending_bmp | NBITVAL(prec);
+	struct brcmf_fws_mac_descriptor *entry =3D brcmf_skbcb(skb)->mac;
+	u8 *wlh;
+	u16 data_offset =3D 0;
+	u8 fillers;
+	__le32 pkttag =3D cpu_to_le32(brcmf_skbcb(skb)->htod);
+
+	brcmf_dbg(TRACE, "enter: ea=3D%pM, ifidx=3D%u (%u), pkttag=3D0x%08X, hslo=
t=3D%d\n",
+		  entry->ea, entry->interface_id,
+		  brcmf_skb_if_flags_get_field(skb, INDEX),
+		  le32_to_cpu(pkttag), (le32_to_cpu(pkttag) >> 8) & 0xffff);
+	if (entry->send_tim_signal)
+		data_offset +=3D 2 + BRCMF_FWS_TYPE_PENDING_TRAFFIC_BMP_LEN;
+
+	/* +2 is for Type[1] and Len[1] in TLV, plus TIM signal */
+	data_offset +=3D 2 + BRCMF_FWS_TYPE_PKTTAG_LEN;
+	fillers =3D round_up(data_offset, 4) - data_offset;
+	data_offset +=3D fillers;
+
+	skb_push(skb, data_offset);
+	wlh =3D skb->data;
+
+	wlh[0] =3D BRCMF_FWS_TYPE_PKTTAG;
+	wlh[1] =3D BRCMF_FWS_TYPE_PKTTAG_LEN;
+	memcpy(&wlh[2], &pkttag, sizeof(pkttag));
+	wlh +=3D BRCMF_FWS_TYPE_PKTTAG_LEN + 2;
+
+	if (entry->send_tim_signal) {
+		entry->send_tim_signal =3D 0;
+		wlh[0] =3D BRCMF_FWS_TYPE_PENDING_TRAFFIC_BMP;
+		wlh[1] =3D BRCMF_FWS_TYPE_PENDING_TRAFFIC_BMP_LEN;
+		wlh[2] =3D entry->mac_handle;
+		wlh[3] =3D entry->traffic_pending_bmp;
+		brcmf_dbg(TRACE, "adding TIM info: %02X:%02X:%02X:%02X\n",
+			  wlh[0], wlh[1], wlh[2], wlh[3]);
+		wlh +=3D BRCMF_FWS_TYPE_PENDING_TRAFFIC_BMP_LEN + 2;
+		entry->traffic_lastreported_bmp =3D entry->traffic_pending_bmp;
 	}
-	/* request a TIM update to firmware at the next piggyback opportunity */
+	if (fillers)
+		memset(wlh, BRCMF_FWS_TYPE_FILLER, fillers);
+
+	brcmf_proto_hdrpush(fws->drvr, brcmf_skb_if_flags_get_field(skb, INDEX),
+			    data_offset >> 2, skb);
+	return 0;
+}
+
+static bool brcmf_fws_tim_update(struct brcmf_fws_info *fws,
+				 struct brcmf_fws_mac_descriptor *entry,
+				 int prec, bool send_immediately)
+{
+	struct sk_buff *skb;
+	struct brcmf_bus *bus;
+	struct brcmf_skbuff_cb *skcb;
+	s32 err;
+	u32 len;
+
+	/* check delayedQ and suppressQ in one call using bitmap */
+	if (brcmu_pktq_mlen(&entry->psq, 3 << (prec * 2)) =3D=3D 0)
+		entry->traffic_pending_bmp &=3D ~NBITVAL(prec);
+	else
+		entry->traffic_pending_bmp |=3D NBITVAL(prec);
+
+	entry->send_tim_signal =3D false;
 	if (entry->traffic_lastreported_bmp !=3D entry->traffic_pending_bmp)
 		entry->send_tim_signal =3D true;
+	if (send_immediately && entry->send_tim_signal &&
+	    entry->state =3D=3D BRCMF_FWS_STATE_CLOSE) {
+		/* create a dummy packet and sent that. The traffic          */
+		/* bitmap info will automatically be attached to that packet */
+		len =3D BRCMF_FWS_TYPE_PKTTAG_LEN + 2 +
+		      BRCMF_FWS_TYPE_PENDING_TRAFFIC_BMP_LEN + 2 +
+		      4 + fws->drvr->hdrlen;
+		skb =3D brcmu_pkt_buf_get_skb(len);
+		skb_pull(skb, len);
+		if (skb =3D=3D NULL)
+			return false;
+		skcb =3D brcmf_skbcb(skb);
+		skcb->mac =3D entry;
+		skcb->state =3D BRCMF_FWS_SKBSTATE_TIM;
+		bus =3D fws->drvr->bus_if;
+		err =3D brcmf_fws_hdrpush(fws, skb);
+		if (err =3D=3D 0)
+			err =3D brcmf_bus_txdata(bus, skb);
+		if (err)
+			brcmu_pkt_buf_free_skb(skb);
+		return true;
+	}
+	return false;
 }
=20
 static void
 brcmf_fws_flow_control_check(struct brcmf_fws_info *fws, struct pktq *pq,
 			     u8 if_id)
 {
-	struct brcmf_if *ifp =3D fws->drvr->iflist[if_id];
+	struct brcmf_if *ifp =3D fws->drvr->iflist[!if_id ? 0 : if_id + 1];
=20
 	if (WARN_ON(!ifp))
 		return;
=20
-	brcmf_dbg(TRACE,
-		  "enter: bssidx=3D%d, ifidx=3D%d\n", ifp->bssidx, ifp->ifidx);
-
 	if ((ifp->netif_stop & BRCMF_NETIF_STOP_REASON_FWS_FC) &&
 	    pq->len <=3D BRCMF_FWS_FLOWCONTROL_LOWATER)
 		brcmf_txflowblock_if(ifp,
@@ -876,8 +917,9 @@ int brcmf_fws_macdesc_indicate(struct brcmf_fws_info *f=
ws, u8 type, u8 *data)
=20
 	entry =3D &fws->desc.nodes[mac_handle & 0x1F];
 	if (type =3D=3D BRCMF_FWS_TYPE_MACDESC_DEL) {
-		brcmf_dbg(TRACE, "deleting mac %pM idx %d\n", addr, ifidx);
 		if (entry->occupied) {
+			brcmf_dbg(TRACE, "deleting %s mac %pM\n",
+				  entry->name, addr);
 			brcmf_fws_mac_desc_cleanup(fws, entry, -1);
 			brcmf_fws_clear_mac_descriptor(entry);
 		} else
@@ -885,25 +927,28 @@ int brcmf_fws_macdesc_indicate(struct brcmf_fws_info =
*fws, u8 type, u8 *data)
 		return 0;
 	}
=20
-	brcmf_dbg(TRACE,
-		  "add mac %pM handle %u idx %d\n", addr, mac_handle, ifidx);
 	existing =3D brcmf_fws_mac_descriptor_lookup(fws, addr);
 	if (IS_ERR(existing)) {
 		if (!entry->occupied) {
 			entry->mac_handle =3D mac_handle;
 			brcmf_fws_init_mac_descriptor(entry, addr, ifidx);
+			brcmf_fws_macdesc_set_name(fws, entry);
 			brcmu_pktq_init(&entry->psq, BRCMF_FWS_PSQ_PREC_COUNT,
 					BRCMF_FWS_PSQ_LEN);
+			brcmf_dbg(TRACE, "add %s mac %pM\n", entry->name, addr);
 		} else {
 			fws->stats.mac_update_failed++;
 		}
 	} else {
 		if (entry !=3D existing) {
-			brcmf_dbg(TRACE, "relocate mac\n");
+			brcmf_dbg(TRACE, "copy mac %s\n", existing->name);
 			memcpy(entry, existing,
 			       offsetof(struct brcmf_fws_mac_descriptor, psq));
 			entry->mac_handle =3D mac_handle;
 			brcmf_fws_clear_mac_descriptor(existing);
+			brcmf_fws_macdesc_set_name(fws, entry);
+			brcmf_dbg(TRACE, "relocate %s mac %pM\n", entry->name,
+				  addr);
 		} else {
 			brcmf_dbg(TRACE, "use existing\n");
 			WARN_ON(entry->mac_handle !=3D mac_handle);
@@ -918,7 +963,6 @@ static int brcmf_fws_macdesc_state_indicate(struct brcm=
f_fws_info *fws,
 {
 	struct brcmf_fws_mac_descriptor *entry;
 	u8 mac_handle;
-	int i;
=20
 	mac_handle =3D data[0];
 	entry =3D &fws->desc.nodes[mac_handle & 0x1F];
@@ -926,16 +970,18 @@ static int brcmf_fws_macdesc_state_indicate(struct br=
cmf_fws_info *fws,
 		fws->stats.mac_ps_update_failed++;
 		return -ESRCH;
 	}
-
-	/* a state update should wipe old credits? */
+	/* a state update should wipe old credits */
 	entry->requested_credit =3D 0;
+	entry->requested_packet =3D 0;
 	if (type =3D=3D BRCMF_FWS_TYPE_MAC_OPEN) {
 		entry->state =3D BRCMF_FWS_STATE_OPEN;
 		return BRCMF_FWS_RET_OK_SCHEDULE;
 	} else {
 		entry->state =3D BRCMF_FWS_STATE_CLOSE;
-		for (i =3D BRCMF_FWS_FIFO_AC_BE; i < NL80211_NUM_ACS; i++)
-			brcmf_fws_tim_update(fws, entry, i);
+		brcmf_fws_tim_update(fws, entry, BRCMF_FWS_FIFO_AC_BK, false);
+		brcmf_fws_tim_update(fws, entry, BRCMF_FWS_FIFO_AC_BE, false);
+		brcmf_fws_tim_update(fws, entry, BRCMF_FWS_FIFO_AC_VI, false);
+		brcmf_fws_tim_update(fws, entry, BRCMF_FWS_FIFO_AC_VO, true);
 	}
 	return BRCMF_FWS_RET_OK_NOSCHEDULE;
 }
@@ -949,7 +995,6 @@ static int brcmf_fws_interface_state_indicate(struct br=
cmf_fws_info *fws,
=20
 	ifidx =3D data[0];
=20
-	brcmf_dbg(TRACE, "enter: ifidx=3D%d\n", ifidx);
 	if (ifidx >=3D BRCMF_MAX_IFS) {
 		ret =3D -ERANGE;
 		goto fail;
@@ -961,6 +1006,8 @@ static int brcmf_fws_interface_state_indicate(struct b=
rcmf_fws_info *fws,
 		goto fail;
 	}
=20
+	brcmf_dbg(TRACE, "%s (%d): %s\n", brcmf_fws_get_tlv_name(type), type,
+		  entry->name);
 	switch (type) {
 	case BRCMF_FWS_TYPE_INTERFACE_OPEN:
 		entry->state =3D BRCMF_FWS_STATE_OPEN;
@@ -991,6 +1038,9 @@ static int brcmf_fws_request_indicate(struct brcmf_fws=
_info *fws, u8 type,
 		return -ESRCH;
 	}
=20
+	brcmf_dbg(TRACE, "%s (%d): %s cnt %d bmp %d\n",
+		  brcmf_fws_get_tlv_name(type), type, entry->name,
+		  data[0], data[2]);
 	if (type =3D=3D BRCMF_FWS_TYPE_MAC_REQUEST_CREDIT)
 		entry->requested_credit =3D data[0];
 	else
@@ -1000,6 +1050,37 @@ static int brcmf_fws_request_indicate(struct brcmf_f=
ws_info *fws, u8 type,
 	return BRCMF_FWS_RET_OK_SCHEDULE;
 }
=20
+static int brcmf_fws_macdesc_use_credit(struct brcmf_fws_mac_descriptor *e=
ntry,
+					struct sk_buff *skb)
+{
+	int use_credit =3D 1;
+
+	if (entry->state =3D=3D BRCMF_FWS_STATE_CLOSE) {
+		if (entry->requested_credit > 0) {
+			/*
+			 * if the packet was pulled out while destination is in
+			 * closed state but had a non-zero packets requested,
+			 * then this should not count against the FIFO credit.
+			 * That is due to the fact that the firmware will
+			 * most likely hold onto this packet until a suitable
+			 * time later to push it to the appropriate AC FIFO.
+			 */
+			entry->requested_credit--;
+			brcmf_skb_if_flags_set_field(skb, REQ_CREDIT, 1);
+			use_credit =3D 0;
+		} else if (entry->requested_packet > 0) {
+			entry->requested_packet--;
+			brcmf_skb_if_flags_set_field(skb, REQUESTED, 1);
+			use_credit =3D 0;
+		}
+	} else {
+		WARN_ON(entry->requested_credit);
+		WARN_ON(entry->requested_packet);
+	}
+	brcmf_skb_if_flags_set_field(skb, CREDITCHECK, use_credit);
+	return use_credit;
+}
+
 static void brcmf_fws_return_credits(struct brcmf_fws_info *fws,
 				     u8 fifo, u8 credits)
 {
@@ -1010,6 +1091,8 @@ static void brcmf_fws_return_credits(struct brcmf_fws=
_info *fws,
 	if (!credits)
 		return;
=20
+	fws->fifo_credit_map |=3D 1 << fifo;
+
 	if ((fifo =3D=3D BRCMF_FWS_FIFO_AC_BE) &&
 	    (fws->credits_borrowed[0])) {
 		for (lender_ac =3D BRCMF_FWS_FIFO_AC_VO; lender_ac >=3D 0;
@@ -1031,7 +1114,6 @@ static void brcmf_fws_return_credits(struct brcmf_fws=
_info *fws,
 		}
 	}
=20
-	fws->fifo_credit_map |=3D 1 << fifo;
 	fws->fifo_credit[fifo] +=3D credits;
 }
=20
@@ -1042,24 +1124,22 @@ static void brcmf_fws_schedule_deq(struct brcmf_fws=
_info *fws)
 		queue_work(fws->fws_wq, &fws->fws_dequeue_work);
 }
=20
-static void brcmf_skb_pick_up_credit(struct brcmf_fws_info *fws, int fifo,
+static void brcmf_fws_skb_pickup_credit(struct brcmf_fws_info *fws, int fi=
fo,
 				     struct sk_buff *p)
 {
 	struct brcmf_fws_mac_descriptor *entry =3D brcmf_skbcb(p)->mac;
=20
-	if (brcmf_skbcb(p)->if_flags & BRCMF_SKB_IF_FLAGS_CREDITCHECK_MASK) {
-		if (fws->fcmode !=3D BRCMF_FWS_FCMODE_IMPLIED_CREDIT)
-			return;
+	if (brcmf_skbcb(p)->if_flags & BRCMF_SKB_IF_FLAGS_CREDITCHECK_MASK)
 		brcmf_fws_return_credits(fws, fifo, 1);
-	} else {
+	else if (brcmf_skb_if_flags_get_field(p, REQ_CREDIT) &&
+		 entry->state =3D=3D BRCMF_FWS_STATE_CLOSE)
 		/*
 		 * if this packet did not count against FIFO credit, it
-		 * must have taken a requested_credit from the destination
+		 * could have taken a requested_credit from the destination
 		 * entry (for pspoll etc.)
 		 */
-		if (!brcmf_skb_if_flags_get_field(p, REQUESTED))
-			entry->requested_credit++;
-	}
+		entry->requested_credit++;
+
 	brcmf_fws_schedule_deq(fws);
 }
=20
@@ -1078,7 +1158,7 @@ static int brcmf_fws_enq(struct brcmf_fws_info *fws,
 		return -ENOENT;
 	}
=20
-	brcmf_dbg(TRACE, "enter: ea=3D%pM, qlen=3D%d\n", entry->ea, entry->psq.le=
n);
+	brcmf_dbg(DATA, "enter: fifo %d skb %p\n", fifo, p);
 	if (state =3D=3D BRCMF_FWS_SKBSTATE_SUPPRESSED) {
 		prec +=3D 1;
 		qfull_stat =3D &fws->stats.supprq_full_error;
@@ -1095,14 +1175,12 @@ static int brcmf_fws_enq(struct brcmf_fws_info *fws,
=20
 	/* update the sk_buff state */
 	brcmf_skbcb(p)->state =3D state;
-	if (state =3D=3D BRCMF_FWS_SKBSTATE_SUPPRESSED)
-		entry->suppress_count++;
=20
 	/*
 	 * A packet has been pushed so update traffic
 	 * availability bitmap, if applicable
 	 */
-	brcmf_fws_tim_update(fws, entry, fifo);
+	brcmf_fws_tim_update(fws, entry, fifo, true);
 	brcmf_fws_flow_control_check(fws, &entry->psq,
 				     brcmf_skb_if_flags_get_field(p, INDEX));
 	return 0;
@@ -1113,7 +1191,6 @@ static struct sk_buff *brcmf_fws_deq(struct brcmf_fws=
_info *fws, int fifo)
 	struct brcmf_fws_mac_descriptor *table;
 	struct brcmf_fws_mac_descriptor *entry;
 	struct sk_buff *p;
-	int use_credit =3D 1;
 	int num_nodes;
 	int node_pos;
 	int prec_out;
@@ -1137,9 +1214,8 @@ static struct sk_buff *brcmf_fws_deq(struct brcmf_fws=
_info *fws, int fifo)
 		p =3D brcmu_pktq_mdeq(&entry->psq, pmsk << (fifo * 2), &prec_out);
 		if (p =3D=3D NULL) {
 			if (entry->suppressed) {
-				if (entry->suppr_transit_count >
-				    entry->suppress_count)
-					return NULL;
+				if (entry->suppr_transit_count)
+					continue;
 				entry->suppressed =3D false;
 				p =3D brcmu_pktq_mdeq(&entry->psq,
 						    1 << (fifo * 2), &prec_out);
@@ -1148,26 +1224,7 @@ static struct sk_buff *brcmf_fws_deq(struct brcmf_fw=
s_info *fws, int fifo)
 		if  (p =3D=3D NULL)
 			continue;
=20
-		/* did the packet come from suppress sub-queue? */
-		if (entry->requested_credit > 0) {
-			entry->requested_credit--;
-			/*
-			 * if the packet was pulled out while destination is in
-			 * closed state but had a non-zero packets requested,
-			 * then this should not count against the FIFO credit.
-			 * That is due to the fact that the firmware will
-			 * most likely hold onto this packet until a suitable
-			 * time later to push it to the appropriate AC FIFO.
-			 */
-			if (entry->state =3D=3D BRCMF_FWS_STATE_CLOSE)
-				use_credit =3D 0;
-		} else if (entry->requested_packet > 0) {
-			entry->requested_packet--;
-			brcmf_skb_if_flags_set_field(p, REQUESTED, 1);
-			if (entry->state =3D=3D BRCMF_FWS_STATE_CLOSE)
-				use_credit =3D 0;
-		}
-		brcmf_skb_if_flags_set_field(p, CREDITCHECK, use_credit);
+		brcmf_fws_macdesc_use_credit(entry, p);
=20
 		/* move dequeue position to ensure fair round-robin */
 		fws->deq_node_pos[fifo] =3D (node_pos + i + 1) % num_nodes;
@@ -1179,7 +1236,7 @@ static struct sk_buff *brcmf_fws_deq(struct brcmf_fws=
_info *fws, int fifo)
 		 * A packet has been picked up, update traffic
 		 * availability bitmap, if applicable
 		 */
-		brcmf_fws_tim_update(fws, entry, fifo);
+		brcmf_fws_tim_update(fws, entry, fifo, false);
=20
 		/*
 		 * decrement total enqueued fifo packets and
@@ -1192,7 +1249,7 @@ static struct sk_buff *brcmf_fws_deq(struct brcmf_fws=
_info *fws, int fifo)
 	}
 	p =3D NULL;
 done:
-	brcmf_dbg(TRACE, "exit: fifo %d skb %p\n", fifo, p);
+	brcmf_dbg(DATA, "exit: fifo %d skb %p\n", fifo, p);
 	return p;
 }
=20
@@ -1202,22 +1259,26 @@ static int brcmf_fws_txstatus_suppressed(struct brc=
mf_fws_info *fws, int fifo,
 	struct brcmf_fws_mac_descriptor *entry =3D brcmf_skbcb(skb)->mac;
 	u32 hslot;
 	int ret;
+	u8 ifidx;
=20
 	hslot =3D brcmf_skb_htod_tag_get_field(skb, HSLOT);
=20
 	/* this packet was suppressed */
-	if (!entry->suppressed || entry->generation !=3D genbit) {
+	if (!entry->suppressed) {
 		entry->suppressed =3D true;
-		entry->suppress_count =3D brcmu_pktq_mlen(&entry->psq,
-							1 << (fifo * 2 + 1));
 		entry->suppr_transit_count =3D entry->transit_count;
+		brcmf_dbg(DATA, "suppress %s: transit %d\n",
+			  entry->name, entry->transit_count);
 	}
=20
 	entry->generation =3D genbit;
=20
-	ret =3D brcmf_fws_enq(fws, BRCMF_FWS_SKBSTATE_SUPPRESSED, fifo, skb);
+	ret =3D brcmf_proto_hdrpull(fws->drvr, false, &ifidx, skb);
+	if (ret =3D=3D 0)
+		ret =3D brcmf_fws_enq(fws, BRCMF_FWS_SKBSTATE_SUPPRESSED, fifo,
+				    skb);
 	if (ret !=3D 0) {
-		/* suppress q is full, drop this packet */
+		/* suppress q is full or hdrpull failed, drop this packet */
 		brcmf_fws_hanger_poppkt(&fws->hanger, hslot, &skb,
 					true);
 	} else {
@@ -1225,26 +1286,24 @@ static int brcmf_fws_txstatus_suppressed(struct brc=
mf_fws_info *fws, int fifo,
 		 * Mark suppressed to avoid a double free during
 		 * wlfc cleanup
 		 */
-		brcmf_fws_hanger_mark_suppressed(&fws->hanger, hslot,
-						 genbit);
-		entry->suppress_count++;
+		brcmf_fws_hanger_mark_suppressed(&fws->hanger, hslot);
 	}
=20
 	return ret;
 }
=20
 static int
-brcmf_fws_txstatus_process(struct brcmf_fws_info *fws, u8 flags, u32 hslot,
+brcmf_fws_txs_process(struct brcmf_fws_info *fws, u8 flags, u32 hslot,
 			   u32 genbit)
 {
 	u32 fifo;
 	int ret;
 	bool remove_from_hanger =3D true;
 	struct sk_buff *skb;
+	struct brcmf_skbuff_cb *skcb;
 	struct brcmf_fws_mac_descriptor *entry =3D NULL;
=20
-	brcmf_dbg(TRACE, "status: flags=3D0x%X, hslot=3D%d\n",
-		  flags, hslot);
+	brcmf_dbg(DATA, "flags %d\n", flags);
=20
 	if (flags =3D=3D BRCMF_FWS_TXSTATUS_DISCARD)
 		fws->stats.txs_discard++;
@@ -1266,26 +1325,31 @@ brcmf_fws_txstatus_process(struct brcmf_fws_info *f=
ws, u8 flags, u32 hslot,
 		return ret;
 	}
=20
-	entry =3D brcmf_skbcb(skb)->mac;
+	skcb =3D brcmf_skbcb(skb);
+	entry =3D skcb->mac;
 	if (WARN_ON(!entry)) {
 		brcmu_pkt_buf_free_skb(skb);
 		return -EINVAL;
 	}
+	entry->transit_count--;
+	if (entry->suppressed && entry->suppr_transit_count)
+		entry->suppr_transit_count--;
+
+	brcmf_dbg(DATA, "%s flags %X htod %X\n", entry->name, skcb->if_flags,
+		  skcb->htod);
=20
 	/* pick up the implicit credit from this packet */
 	fifo =3D brcmf_skb_htod_tag_get_field(skb, FIFO);
-	brcmf_skb_pick_up_credit(fws, fifo, skb);
+	if (fws->fcmode =3D=3D BRCMF_FWS_FCMODE_IMPLIED_CREDIT ||
+	    !(brcmf_skbcb(skb)->if_flags & BRCMF_SKB_IF_FLAGS_CREDITCHECK_MASK))
+		brcmf_fws_skb_pickup_credit(fws, fifo, skb);
=20
 	if (!remove_from_hanger)
 		ret =3D brcmf_fws_txstatus_suppressed(fws, fifo, skb, genbit);
=20
-	if (remove_from_hanger || ret) {
-		entry->transit_count--;
-		if (entry->suppressed)
-			entry->suppr_transit_count--;
-
+	if (remove_from_hanger || ret)
 		brcmf_txfinalize(fws->drvr, skb, true);
-	}
+
 	return 0;
 }
=20
@@ -1299,11 +1363,11 @@ static int brcmf_fws_fifocreditback_indicate(struct=
 brcmf_fws_info *fws,
 		return BRCMF_FWS_RET_OK_NOSCHEDULE;
 	}
=20
-	brcmf_dbg(TRACE, "enter: data %pM\n", data);
+	brcmf_dbg(DATA, "enter: data %pM\n", data);
 	for (i =3D 0; i < BRCMF_FWS_FIFO_COUNT; i++)
 		brcmf_fws_return_credits(fws, i, data[i]);
=20
-	brcmf_dbg(INFO, "map: credit %x delay %x\n", fws->fifo_credit_map,
+	brcmf_dbg(DATA, "map: credit %x delay %x\n", fws->fifo_credit_map,
 		  fws->fifo_delay_map);
 	return BRCMF_FWS_RET_OK_SCHEDULE;
 }
@@ -1323,7 +1387,7 @@ static int brcmf_fws_txstatus_indicate(struct brcmf_f=
ws_info *fws, u8 *data)
 	hslot =3D brcmf_txstatus_get_field(status, HSLOT);
 	genbit =3D brcmf_txstatus_get_field(status, GENERATION);
=20
-	return brcmf_fws_txstatus_process(fws, flags, hslot, genbit);
+	return brcmf_fws_txs_process(fws, flags, hslot, genbit);
 }
=20
 static int brcmf_fws_dbg_seqnum_check(struct brcmf_fws_info *fws, u8 *data)
@@ -1331,7 +1395,7 @@ static int brcmf_fws_dbg_seqnum_check(struct brcmf_fw=
s_info *fws, u8 *data)
 	__le32 timestamp;
=20
 	memcpy(&timestamp, &data[2], sizeof(timestamp));
-	brcmf_dbg(INFO, "received: seq %d, timestamp %d\n", data[1],
+	brcmf_dbg(CTL, "received: seq %d, timestamp %d\n", data[1],
 		  le32_to_cpu(timestamp));
 	return 0;
 }
@@ -1364,6 +1428,10 @@ static int brcmf_fws_notify_credit_map(struct brcmf_=
if *ifp,
 		brcmf_err("event payload too small (%d)\n", e->datalen);
 		return -EINVAL;
 	}
+	if (fws->creditmap_received)
+		return 0;
+
+	fws->creditmap_received =3D true;
=20
 	brcmf_dbg(TRACE, "enter: credits %pM\n", credits);
 	brcmf_fws_lock(ifp->drvr, flags);
@@ -1392,7 +1460,7 @@ int brcmf_fws_hdrpull(struct brcmf_pub *drvr, int ifi=
dx, s16 signal_len,
 	s32 status;
 	s32 err;
=20
-	brcmf_dbg(TRACE, "enter: ifidx %d, skblen %u, sig %d\n",
+	brcmf_dbg(HDRS, "enter: ifidx %d, skblen %u, sig %d\n",
 		  ifidx, skb->len, signal_len);
=20
 	WARN_ON(signal_len > skb->len);
@@ -1426,14 +1494,15 @@ int brcmf_fws_hdrpull(struct brcmf_pub *drvr, int i=
fidx, s16 signal_len,
 		len =3D signal_data[1];
 		data =3D signal_data + 2;
=20
-		brcmf_dbg(INFO, "tlv type=3D%d (%s), len=3D%d, data[0]=3D%d\n", type,
-			  brcmf_fws_get_tlv_name(type), len, *data);
+		brcmf_dbg(HDRS, "tlv type=3D%s (%d), len=3D%d (%d)\n",
+			  brcmf_fws_get_tlv_name(type), type, len,
+			  brcmf_fws_get_tlv_len(fws, type));
=20
 		/* abort parsing when length invalid */
 		if (data_len < len + 2)
 			break;
=20
-		if (len !=3D brcmf_fws_get_tlv_len(fws, type))
+		if (len < brcmf_fws_get_tlv_len(fws, type))
 			break;
=20
 		err =3D BRCMF_FWS_RET_OK_NOSCHEDULE;
@@ -1502,113 +1571,54 @@ int brcmf_fws_hdrpull(struct brcmf_pub *drvr, int =
ifidx, s16 signal_len,
 	return 0;
 }
=20
-static int brcmf_fws_hdrpush(struct brcmf_fws_info *fws, struct sk_buff *s=
kb)
-{
-	struct brcmf_fws_mac_descriptor *entry =3D brcmf_skbcb(skb)->mac;
-	u8 *wlh;
-	u16 data_offset =3D 0;
-	u8 fillers;
-	__le32 pkttag =3D cpu_to_le32(brcmf_skbcb(skb)->htod);
-
-	brcmf_dbg(TRACE, "enter: ea=3D%pM, ifidx=3D%u, pkttag=3D0x%08X\n",
-		  entry->ea, entry->interface_id, le32_to_cpu(pkttag));
-	if (entry->send_tim_signal)
-		data_offset +=3D 2 + BRCMF_FWS_TYPE_PENDING_TRAFFIC_BMP_LEN;
-
-	/* +2 is for Type[1] and Len[1] in TLV, plus TIM signal */
-	data_offset +=3D 2 + BRCMF_FWS_TYPE_PKTTAG_LEN;
-	fillers =3D round_up(data_offset, 4) - data_offset;
-	data_offset +=3D fillers;
-
-	skb_push(skb, data_offset);
-	wlh =3D skb->data;
-
-	wlh[0] =3D BRCMF_FWS_TYPE_PKTTAG;
-	wlh[1] =3D BRCMF_FWS_TYPE_PKTTAG_LEN;
-	memcpy(&wlh[2], &pkttag, sizeof(pkttag));
-	wlh +=3D BRCMF_FWS_TYPE_PKTTAG_LEN + 2;
-
-	if (entry->send_tim_signal) {
-		entry->send_tim_signal =3D 0;
-		wlh[0] =3D BRCMF_FWS_TYPE_PENDING_TRAFFIC_BMP;
-		wlh[1] =3D BRCMF_FWS_TYPE_PENDING_TRAFFIC_BMP_LEN;
-		wlh[2] =3D entry->mac_handle;
-		wlh[3] =3D entry->traffic_pending_bmp;
-		wlh +=3D BRCMF_FWS_TYPE_PENDING_TRAFFIC_BMP_LEN + 2;
-		entry->traffic_lastreported_bmp =3D entry->traffic_pending_bmp;
-	}
-	if (fillers)
-		memset(wlh, BRCMF_FWS_TYPE_FILLER, fillers);
-
-	brcmf_proto_hdrpush(fws->drvr, brcmf_skb_if_flags_get_field(skb, INDEX),
-			    data_offset >> 2, skb);
-	return 0;
-}
-
 static int brcmf_fws_precommit_skb(struct brcmf_fws_info *fws, int fifo,
 				   struct sk_buff *p)
 {
 	struct brcmf_skbuff_cb *skcb =3D brcmf_skbcb(p);
 	struct brcmf_fws_mac_descriptor *entry =3D skcb->mac;
 	int rc =3D 0;
-	bool header_needed;
+	bool first_time;
 	int hslot =3D BRCMF_FWS_HANGER_MAXITEMS;
 	u8 free_ctr;
-	u8 ifidx;
 	u8 flags;
=20
-	header_needed =3D skcb->state !=3D BRCMF_FWS_SKBSTATE_SUPPRESSED;
+	first_time =3D skcb->state !=3D BRCMF_FWS_SKBSTATE_SUPPRESSED;
=20
-	if (header_needed) {
-		/* obtaining free slot may fail, but that will be caught
-		 * by the hanger push. This assures the packet has a BDC
-		 * header upon return.
-		 */
-		hslot =3D brcmf_fws_hanger_get_free_slot(&fws->hanger);
-		free_ctr =3D entry->seq[fifo];
-		brcmf_skb_htod_tag_set_field(p, HSLOT, hslot);
-		brcmf_skb_htod_tag_set_field(p, FREERUN, free_ctr);
-		brcmf_skb_htod_tag_set_field(p, GENERATION, 1);
-		entry->transit_count++;
-	}
 	brcmf_skb_if_flags_set_field(p, TRANSMIT, 1);
 	brcmf_skb_htod_tag_set_field(p, FIFO, fifo);
-
+	brcmf_skb_htod_tag_set_field(p, GENERATION, entry->generation);
 	flags =3D BRCMF_FWS_HTOD_FLAG_PKTFROMHOST;
 	if (!(skcb->if_flags & BRCMF_SKB_IF_FLAGS_CREDITCHECK_MASK)) {
 		/*
-		Indicate that this packet is being sent in response to an
-		explicit request from the firmware side.
-		*/
+		 * Indicate that this packet is being sent in response to an
+		 * explicit request from the firmware side.
+		 */
 		flags |=3D BRCMF_FWS_HTOD_FLAG_PKT_REQUESTED;
 	}
 	brcmf_skb_htod_tag_set_field(p, FLAGS, flags);
-	if (header_needed) {
-		brcmf_fws_hdrpush(fws, p);
+	if (first_time) {
+		/* obtaining free slot may fail, but that will be caught
+		 * by the hanger push. This assures the packet has a BDC
+		 * header upon return.
+		 */
+		hslot =3D brcmf_fws_hanger_get_free_slot(&fws->hanger);
+		free_ctr =3D entry->seq[fifo];
+		brcmf_skb_htod_tag_set_field(p, HSLOT, hslot);
+		brcmf_skb_htod_tag_set_field(p, FREERUN, free_ctr);
 		rc =3D brcmf_fws_hanger_pushpkt(&fws->hanger, p, hslot);
 		if (rc)
 			brcmf_err("hanger push failed: rc=3D%d\n", rc);
-	} else {
-		int gen;
-
-		/* remove old header */
-		rc =3D brcmf_proto_hdrpull(fws->drvr, false, &ifidx, p);
-		if (rc =3D=3D 0) {
-			hslot =3D brcmf_skb_htod_tag_get_field(p, HSLOT);
-			brcmf_fws_hanger_get_genbit(&fws->hanger, p,
-						    hslot, &gen);
-			brcmf_skb_htod_tag_set_field(p, GENERATION, gen);
-
-			/* push new header */
-			brcmf_fws_hdrpush(fws, p);
-		}
 	}
=20
+	if (rc =3D=3D 0)
+		brcmf_fws_hdrpush(fws, p);
+
 	return rc;
 }
=20
 static void
-brcmf_fws_rollback_toq(struct brcmf_fws_info *fws, struct sk_buff *skb)
+brcmf_fws_rollback_toq(struct brcmf_fws_info *fws,
+		       struct sk_buff *skb, int fifo)
 {
 	/*
 	put the packet back to the head of queue
@@ -1622,11 +1632,8 @@ brcmf_fws_rollback_toq(struct brcmf_fws_info *fws, s=
truct sk_buff *skb)
 	enum brcmf_fws_skb_state state;
 	struct sk_buff *pktout;
 	int rc =3D 0;
-	int fifo;
 	int hslot;
-	u8 ifidx;
=20
-	fifo =3D brcmf_skb_if_flags_get_field(skb, FIFO);
 	state =3D brcmf_skbcb(skb)->state;
 	entry =3D brcmf_skbcb(skb)->mac;
=20
@@ -1642,17 +1649,6 @@ brcmf_fws_rollback_toq(struct brcmf_fws_info *fws, s=
truct sk_buff *skb)
 		} else {
 			hslot =3D brcmf_skb_htod_tag_get_field(skb, HSLOT);
=20
-			/* remove header first */
-			rc =3D brcmf_proto_hdrpull(fws->drvr, false, &ifidx, skb);
-			if (rc) {
-				brcmf_err("header removal failed\n");
-				/* free the hanger slot */
-				brcmf_fws_hanger_poppkt(&fws->hanger, hslot,
-							&pktout, true);
-				rc =3D -EINVAL;
-				goto fail;
-			}
-
 			/* delay-q packets are going to delay-q */
 			pktout =3D brcmu_pktq_penq_head(&entry->psq,
 						      2 * fifo, skb);
@@ -1668,33 +1664,28 @@ brcmf_fws_rollback_toq(struct brcmf_fws_info *fws, =
struct sk_buff *skb)
 			/* decrement sequence count */
 			entry->seq[fifo]--;
 		}
-		/*
-		if this packet did not count against FIFO credit, it must have
-		taken a requested_credit from the firmware (for pspoll etc.)
-		*/
-		if (!(brcmf_skbcb(skb)->if_flags &
-		      BRCMF_SKB_IF_FLAGS_CREDITCHECK_MASK))
-			entry->requested_credit++;
 	} else {
 		brcmf_err("no mac entry linked\n");
 		rc =3D -ENOENT;
 	}
=20
-
-fail:
 	if (rc) {
-		brcmf_txfinalize(fws->drvr, skb, false);
+		brcmf_fws_bustxfail(fws, skb);
 		fws->stats.rollback_failed++;
-	} else
+	} else {
 		fws->stats.rollback_success++;
+		brcmf_fws_skb_pickup_credit(fws, fifo, skb);
+	}
 }
=20
 static int brcmf_fws_borrow_credit(struct brcmf_fws_info *fws)
 {
 	int lender_ac;
=20
-	if (time_after(fws->borrow_defer_timestamp, jiffies))
+	if (time_after(fws->borrow_defer_timestamp, jiffies)) {
+		fws->fifo_credit_map &=3D ~(1 << BRCMF_FWS_FIFO_AC_BE);
 		return -ENAVAIL;
+	}
=20
 	for (lender_ac =3D 0; lender_ac <=3D BRCMF_FWS_FIFO_AC_VO; lender_ac++) {
 		if (fws->fifo_credit[lender_ac]) {
@@ -1702,10 +1693,12 @@ static int brcmf_fws_borrow_credit(struct brcmf_fws=
_info *fws)
 			fws->fifo_credit[lender_ac]--;
 			if (fws->fifo_credit[lender_ac] =3D=3D 0)
 				fws->fifo_credit_map &=3D ~(1 << lender_ac);
-			brcmf_dbg(TRACE, "borrow credit from: %d\n", lender_ac);
+			fws->fifo_credit_map |=3D (1 << BRCMF_FWS_FIFO_AC_BE);
+			brcmf_dbg(DATA, "borrow credit from: %d\n", lender_ac);
 			return 0;
 		}
 	}
+	fws->fifo_credit_map &=3D ~(1 << BRCMF_FWS_FIFO_AC_BE);
 	return -ENAVAIL;
 }
=20
@@ -1714,33 +1707,9 @@ static int brcmf_fws_consume_credit(struct brcmf_fws=
_info *fws, int fifo,
 {
 	struct brcmf_fws_mac_descriptor *entry =3D brcmf_skbcb(skb)->mac;
 	int *credit =3D &fws->fifo_credit[fifo];
-	int use_credit =3D 1;
=20
-	brcmf_dbg(TRACE, "enter: ac=3D%d, credits=3D%d\n", fifo, *credit);
-
-	if (entry->requested_credit > 0) {
-		/*
-		 * if the packet was pulled out while destination is in
-		 * closed state but had a non-zero packets requested,
-		 * then this should not count against the FIFO credit.
-		 * That is due to the fact that the firmware will
-		 * most likely hold onto this packet until a suitable
-		 * time later to push it to the appropriate AC FIFO.
-		 */
-		entry->requested_credit--;
-		if (entry->state =3D=3D BRCMF_FWS_STATE_CLOSE)
-			use_credit =3D 0;
-	} else if (entry->requested_packet > 0) {
-		entry->requested_packet--;
-		brcmf_skb_if_flags_set_field(skb, REQUESTED, 1);
-		if (entry->state =3D=3D BRCMF_FWS_STATE_CLOSE)
-			use_credit =3D 0;
-	}
-	brcmf_skb_if_flags_set_field(skb, CREDITCHECK, use_credit);
-	if (!use_credit) {
-		brcmf_dbg(TRACE, "exit: no creditcheck set\n");
+	if (!brcmf_fws_macdesc_use_credit(entry, skb))
 		return 0;
-	}
=20
 	if (fifo !=3D BRCMF_FWS_FIFO_AC_BE)
 		fws->borrow_defer_timestamp =3D jiffies +
@@ -1752,13 +1721,13 @@ static int brcmf_fws_consume_credit(struct brcmf_fw=
s_info *fws, int fifo,
 		    brcmf_fws_borrow_credit(fws) =3D=3D 0)
 			return 0;
=20
-		brcmf_dbg(TRACE, "exit: ac=3D%d, credits depleted\n", fifo);
+		brcmf_dbg(DATA, "exit: ac=3D%d, credits depleted\n", fifo);
 		return -ENAVAIL;
 	}
 	(*credit)--;
 	if (!(*credit))
 		fws->fifo_credit_map &=3D ~(1 << fifo);
-	brcmf_dbg(TRACE, "exit: ac=3D%d, credits=3D%d\n", fifo, *credit);
+	brcmf_dbg(DATA, "exit: ac=3D%d, credits=3D%d\n", fifo, *credit);
 	return 0;
 }
=20
@@ -1769,6 +1738,7 @@ static int brcmf_fws_commit_skb(struct brcmf_fws_info=
 *fws, int fifo,
 	struct brcmf_fws_mac_descriptor *entry;
 	struct brcmf_bus *bus =3D fws->drvr->bus_if;
 	int rc;
+	u8 ifidx;
=20
 	entry =3D skcb->mac;
 	if (IS_ERR(entry))
@@ -1780,10 +1750,17 @@ static int brcmf_fws_commit_skb(struct brcmf_fws_in=
fo *fws, int fifo,
 		goto rollback;
 	}
=20
+	brcmf_dbg(DATA, "%s flags %X htod %X\n", entry->name, skcb->if_flags,
+		  skcb->htod);
 	rc =3D brcmf_bus_txdata(bus, skb);
-	if (rc < 0)
+	if (rc < 0) {
+		brcmf_proto_hdrpull(fws->drvr, false, &ifidx, skb);
 		goto rollback;
+	}
=20
+	entry->transit_count++;
+	if (entry->suppressed)
+		entry->suppr_transit_count++;
 	entry->seq[fifo]++;
 	fws->stats.pkt2bus++;
 	if (brcmf_skbcb(skb)->if_flags & BRCMF_SKB_IF_FLAGS_CREDITCHECK_MASK) {
@@ -1794,7 +1771,7 @@ static int brcmf_fws_commit_skb(struct brcmf_fws_info=
 *fws, int fifo,
 	return rc;
=20
 rollback:
-	brcmf_fws_rollback_toq(fws, skb);
+	brcmf_fws_rollback_toq(fws, skb, fifo);
 	return rc;
 }
=20
@@ -1831,13 +1808,13 @@ int brcmf_fws_process_skb(struct brcmf_if *ifp, str=
uct sk_buff *skb)
 	brcmf_skb_if_flags_set_field(skb, INDEX, ifp->ifidx);
 	if (!multicast)
 		fifo =3D brcmf_fws_prio2fifo[skb->priority];
-	brcmf_skb_if_flags_set_field(skb, FIFO, fifo);
=20
-	brcmf_dbg(TRACE, "ea=3D%pM, multi=3D%d, fifo=3D%d\n", eh->h_dest,
-		  multicast, fifo);
+	brcmf_dbg(DATA, "%s mac %pM multi %d fifo %d\n", skcb->mac->name,
+		  eh->h_dest, multicast, fifo);
=20
 	brcmf_fws_lock(drvr, flags);
 	if (skcb->mac->suppressed ||
+	    fws->bus_flow_blocked ||
 	    brcmf_fws_mac_desc_closed(fws, skcb->mac, fifo) ||
 	    brcmu_pktq_mlen(&skcb->mac->psq, 3 << (fifo * 2)) ||
 	    (!multicast &&
@@ -1846,9 +1823,7 @@ int brcmf_fws_process_skb(struct brcmf_if *ifp, struc=
t sk_buff *skb)
 		drvr->fws->fifo_delay_map |=3D 1 << fifo;
 		brcmf_fws_enq(fws, BRCMF_FWS_SKBSTATE_DELAYED, fifo, skb);
 	} else {
-		if (brcmf_fws_commit_skb(fws, fifo, skb))
-			if (!multicast)
-				brcmf_skb_pick_up_credit(fws, fifo, skb);
+		brcmf_fws_commit_skb(fws, fifo, skb);
 	}
 	brcmf_fws_unlock(drvr, flags);
 	return 0;
@@ -1870,16 +1845,16 @@ void brcmf_fws_add_interface(struct brcmf_if *ifp)
 	struct brcmf_fws_info *fws =3D ifp->drvr->fws;
 	struct brcmf_fws_mac_descriptor *entry;
=20
-	brcmf_dbg(TRACE, "enter: idx=3D%d, mac=3D%pM\n",
-		  ifp->bssidx, ifp->mac_addr);
 	if (!ifp->ndev || !ifp->drvr->fw_signals)
 		return;
=20
 	entry =3D &fws->desc.iface[ifp->ifidx];
 	ifp->fws_desc =3D entry;
 	brcmf_fws_init_mac_descriptor(entry, ifp->mac_addr, ifp->ifidx);
+	brcmf_fws_macdesc_set_name(fws, entry);
 	brcmu_pktq_init(&entry->psq, BRCMF_FWS_PSQ_PREC_COUNT,
 			BRCMF_FWS_PSQ_LEN);
+	brcmf_dbg(TRACE, "added %s\n", entry->name);
 }
=20
 void brcmf_fws_del_interface(struct brcmf_if *ifp)
@@ -1887,12 +1862,12 @@ void brcmf_fws_del_interface(struct brcmf_if *ifp)
 	struct brcmf_fws_mac_descriptor *entry =3D ifp->fws_desc;
 	ulong flags;
=20
-	brcmf_dbg(TRACE, "enter: idx=3D%d\n", ifp->bssidx);
 	if (!entry)
 		return;
=20
 	brcmf_fws_lock(ifp->drvr, flags);
 	ifp->fws_desc =3D NULL;
+	brcmf_dbg(TRACE, "deleting %s\n", entry->name);
 	brcmf_fws_clear_mac_descriptor(entry);
 	brcmf_fws_cleanup(ifp->drvr->fws, ifp->ifidx);
 	brcmf_fws_unlock(ifp->drvr, flags);
@@ -1904,39 +1879,39 @@ static void brcmf_fws_dequeue_worker(struct work_st=
ruct *worker)
 	struct sk_buff *skb;
 	ulong flags;
 	int fifo;
-	int credit;
=20
 	fws =3D container_of(worker, struct brcmf_fws_info, fws_dequeue_work);
=20
-	brcmf_dbg(TRACE, "enter: fws=3D%p\n", fws);
 	brcmf_fws_lock(fws->drvr, flags);
-	for (fifo =3D NL80211_NUM_ACS; fifo >=3D 0; fifo--) {
-		brcmf_dbg(TRACE, "fifo %d credit %d\n", fifo,
-			  fws->fifo_credit[fifo]);
-		for (credit =3D 0; credit < fws->fifo_credit[fifo]; /* nop */) {
+	for (fifo =3D NL80211_NUM_ACS; fifo >=3D 0 && !fws->bus_flow_blocked;
+	     fifo--) {
+		while (fws->fifo_credit[fifo]) {
 			skb =3D brcmf_fws_deq(fws, fifo);
-			if (!skb || brcmf_fws_commit_skb(fws, fifo, skb))
+			if (!skb)
 				break;
 			if (brcmf_skbcb(skb)->if_flags &
 			    BRCMF_SKB_IF_FLAGS_CREDITCHECK_MASK)
-				credit++;
+				fws->fifo_credit[fifo]--;
+
+			if (brcmf_fws_commit_skb(fws, fifo, skb))
+				break;
+			if (fws->bus_flow_blocked)
+				break;
 		}
 		if ((fifo =3D=3D BRCMF_FWS_FIFO_AC_BE) &&
-		    (credit =3D=3D fws->fifo_credit[fifo])) {
-			fws->fifo_credit[fifo] -=3D credit;
+		    (fws->fifo_credit[fifo] =3D=3D 0) &&
+		    (!fws->bus_flow_blocked)) {
 			while (brcmf_fws_borrow_credit(fws) =3D=3D 0) {
 				skb =3D brcmf_fws_deq(fws, fifo);
 				if (!skb) {
 					brcmf_fws_return_credits(fws, fifo, 1);
 					break;
 				}
-				if (brcmf_fws_commit_skb(fws, fifo, skb)) {
-					brcmf_fws_return_credits(fws, fifo, 1);
+				if (brcmf_fws_commit_skb(fws, fifo, skb))
+					break;
+				if (fws->bus_flow_blocked)
 					break;
-				}
 			}
-		} else {
-			fws->fifo_credit[fifo] -=3D credit;
 		}
 	}
 	brcmf_fws_unlock(fws->drvr, flags);
@@ -1994,14 +1969,14 @@ int brcmf_fws_init(struct brcmf_pub *drvr)
=20
 	brcmf_fws_hanger_init(&drvr->fws->hanger);
 	brcmf_fws_init_mac_descriptor(&drvr->fws->desc.other, NULL, 0);
+	brcmf_fws_macdesc_set_name(drvr->fws, &drvr->fws->desc.other);
 	brcmu_pktq_init(&drvr->fws->desc.other.psq, BRCMF_FWS_PSQ_PREC_COUNT,
 			BRCMF_FWS_PSQ_LEN);
=20
 	/* create debugfs file for statistics */
 	brcmf_debugfs_create_fws_stats(drvr, &drvr->fws->stats);
=20
-	/* TODO: remove upon feature delivery */
-	brcmf_err("%s bdcv2 tlv signaling [%x]\n",
+	brcmf_dbg(INFO, "%s bdcv2 tlv signaling [%x]\n",
 		  drvr->fw_signals ? "enabled" : "disabled", tlv);
 	return 0;
=20
@@ -2043,25 +2018,34 @@ bool brcmf_fws_fc_active(struct brcmf_fws_info *fws)
 	if (!fws)
 		return false;
=20
-	brcmf_dbg(TRACE, "enter: mode=3D%d\n", fws->fcmode);
 	return fws->fcmode !=3D BRCMF_FWS_FCMODE_NONE;
 }
=20
 void brcmf_fws_bustxfail(struct brcmf_fws_info *fws, struct sk_buff *skb)
 {
 	ulong flags;
+	int fifo;
=20
+	if (brcmf_skbcb(skb)->state =3D=3D BRCMF_FWS_SKBSTATE_TIM) {
+		brcmu_pkt_buf_free_skb(skb);
+		return;
+	}
 	brcmf_fws_lock(fws->drvr, flags);
-	brcmf_fws_txstatus_process(fws, BRCMF_FWS_TXSTATUS_FW_TOSSED,
+	brcmf_fws_txs_process(fws, BRCMF_FWS_TXSTATUS_FW_TOSSED,
 				   brcmf_skb_htod_tag_get_field(skb, HSLOT), 0);
 	/* the packet never reached firmware so reclaim credit */
-	if (fws->fcmode =3D=3D BRCMF_FWS_FCMODE_EXPLICIT_CREDIT &&
-	    brcmf_skbcb(skb)->if_flags & BRCMF_SKB_IF_FLAGS_CREDITCHECK_MASK) {
-		brcmf_fws_return_credits(fws,
-					 brcmf_skb_htod_tag_get_field(skb,
-								      FIFO),
-					 1);
-		brcmf_fws_schedule_deq(fws);
+	if (fws->fcmode =3D=3D BRCMF_FWS_FCMODE_EXPLICIT_CREDIT) {
+		fifo =3D brcmf_skb_htod_tag_get_field(skb, FIFO);
+		brcmf_fws_skb_pickup_credit(fws, fifo, skb);
 	}
 	brcmf_fws_unlock(fws->drvr, flags);
 }
+
+void brcmf_fws_bus_blocked(struct brcmf_pub *drvr, bool flow_blocked)
+{
+	struct brcmf_fws_info *fws =3D drvr->fws;
+
+	fws->bus_flow_blocked =3D flow_blocked;
+	if (!flow_blocked)
+		brcmf_fws_schedule_deq(fws);
+}
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h b/drivers/n=
et/wireless/brcm80211/brcmfmac/fwsignal.h
index fbe483d..9fc8609 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h
+++ b/drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h
@@ -29,5 +29,6 @@ void brcmf_fws_reset_interface(struct brcmf_if *ifp);
 void brcmf_fws_add_interface(struct brcmf_if *ifp);
 void brcmf_fws_del_interface(struct brcmf_if *ifp);
 void brcmf_fws_bustxfail(struct brcmf_fws_info *fws, struct sk_buff *skb);
+void brcmf_fws_bus_blocked(struct brcmf_pub *drvr, bool flow_blocked);
=20
 #endif /* FWSIGNAL_H_ */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wi=
reless/brcm80211/brcmfmac/usb.c
index 01aed7a..322cadc 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
@@ -82,6 +82,7 @@ struct brcmf_usbdev_info {
 	int tx_high_watermark;
 	int tx_freecount;
 	bool tx_flowblock;
+	spinlock_t tx_flowblock_lock;
=20
 	struct brcmf_usbreq *tx_reqs;
 	struct brcmf_usbreq *rx_reqs;
@@ -411,6 +412,7 @@ static void brcmf_usb_tx_complete(struct urb *urb)
 {
 	struct brcmf_usbreq *req =3D (struct brcmf_usbreq *)urb->context;
 	struct brcmf_usbdev_info *devinfo =3D req->devinfo;
+	unsigned long flags;
=20
 	brcmf_dbg(USB, "Enter, urb->status=3D%d, skb=3D%p\n", urb->status,
 		  req->skb);
@@ -419,11 +421,13 @@ static void brcmf_usb_tx_complete(struct urb *urb)
 	brcmf_txcomplete(devinfo->dev, req->skb, urb->status =3D=3D 0);
 	req->skb =3D NULL;
 	brcmf_usb_enq(devinfo, &devinfo->tx_freeq, req, &devinfo->tx_freecount);
+	spin_lock_irqsave(&devinfo->tx_flowblock_lock, flags);
 	if (devinfo->tx_freecount > devinfo->tx_high_watermark &&
 		devinfo->tx_flowblock) {
 		brcmf_txflowblock(devinfo->dev, false);
 		devinfo->tx_flowblock =3D false;
 	}
+	spin_unlock_irqrestore(&devinfo->tx_flowblock_lock, flags);
 }
=20
 static void brcmf_usb_rx_complete(struct urb *urb)
@@ -568,6 +572,7 @@ static int brcmf_usb_tx(struct device *dev, struct sk_b=
uff *skb)
 	struct brcmf_usbdev_info *devinfo =3D brcmf_usb_get_businfo(dev);
 	struct brcmf_usbreq  *req;
 	int ret;
+	unsigned long flags;
=20
 	brcmf_dbg(USB, "Enter, skb=3D%p\n", skb);
 	if (devinfo->bus_pub.state !=3D BRCMFMAC_USB_STATE_UP) {
@@ -599,11 +604,13 @@ static int brcmf_usb_tx(struct device *dev, struct sk=
_buff *skb)
 		goto fail;
 	}
=20
+	spin_lock_irqsave(&devinfo->tx_flowblock_lock, flags);
 	if (devinfo->tx_freecount < devinfo->tx_low_watermark &&
 	    !devinfo->tx_flowblock) {
 		brcmf_txflowblock(dev, true);
 		devinfo->tx_flowblock =3D true;
 	}
+	spin_unlock_irqrestore(&devinfo->tx_flowblock_lock, flags);
 	return 0;
=20
 fail:
@@ -1164,6 +1171,7 @@ struct brcmf_usbdev *brcmf_usb_attach(struct brcmf_us=
bdev_info *devinfo,
=20
 	/* Initialize the spinlocks */
 	spin_lock_init(&devinfo->qlock);
+	spin_lock_init(&devinfo->tx_flowblock_lock);
=20
 	INIT_LIST_HEAD(&devinfo->rx_freeq);
 	INIT_LIST_HEAD(&devinfo->rx_postq);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/w=
ireless/brcm80211/brcmsmac/main.c
index 28e7aee..9fd6f2f 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -3074,21 +3074,8 @@ static void brcms_b_antsel_set(struct brcms_hardware=
 *wlc_hw, u32 antsel_avail)
  */
 static bool brcms_c_ps_allowed(struct brcms_c_info *wlc)
 {
-	/* disallow PS when one of the following global conditions meets */
-	if (!wlc->pub->associated)
-		return false;
-
-	/* disallow PS when one of these meets when not scanning */
-	if (wlc->filter_flags & FIF_PROMISC_IN_BSS)
-		return false;
-
-	if (wlc->bsscfg->type =3D=3D BRCMS_TYPE_AP)
-		return false;
-
-	if (wlc->bsscfg->type =3D=3D BRCMS_TYPE_ADHOC)
-		return false;
-
-	return true;
+	/* not supporting PS so always return false for now */
+	return false;
 }
=20
 static void brcms_c_statsupd(struct brcms_c_info *wlc)
diff --git a/drivers/net/wireless/mwifiex/debugfs.c b/drivers/net/wireless/=
mwifiex/debugfs.c
index 753b568..a5f9875 100644
--- a/drivers/net/wireless/mwifiex/debugfs.c
+++ b/drivers/net/wireless/mwifiex/debugfs.c
@@ -26,10 +26,17 @@
 static struct dentry *mwifiex_dfs_dir;
=20
 static char *bss_modes[] =3D {
-	"Unknown",
-	"Ad-hoc",
-	"Managed",
-	"Auto"
+	"UNSPECIFIED",
+	"ADHOC",
+	"STATION",
+	"AP",
+	"AP_VLAN",
+	"WDS",
+	"MONITOR",
+	"MESH_POINT",
+	"P2P_CLIENT",
+	"P2P_GO",
+	"P2P_DEVICE",
 };
=20
 /* size/addr for mwifiex_debug_info */
@@ -200,7 +207,12 @@ mwifiex_info_read(struct file *file, char __user *ubuf,
 	p +=3D sprintf(p, "driver_version =3D %s", fmt);
 	p +=3D sprintf(p, "\nverext =3D %s", priv->version_str);
 	p +=3D sprintf(p, "\ninterface_name=3D\"%s\"\n", netdev->name);
-	p +=3D sprintf(p, "bss_mode=3D\"%s\"\n", bss_modes[info.bss_mode]);
+
+	if (info.bss_mode >=3D ARRAY_SIZE(bss_modes))
+		p +=3D sprintf(p, "bss_mode=3D\"%d\"\n", info.bss_mode);
+	else
+		p +=3D sprintf(p, "bss_mode=3D\"%s\"\n", bss_modes[info.bss_mode]);
+
 	p +=3D sprintf(p, "media_state=3D\"%s\"\n",
 		     (!priv->media_connected ? "Disconnected" : "Connected"));
 	p +=3D sprintf(p, "mac_address=3D\"%pM\"\n", netdev->dev_addr);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/hw.c
index 3d0498e..189ba12 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -1973,26 +1973,35 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8=
 variable, u8 *val)
 	}
 }
=20
-void rtl92cu_update_hal_rate_table(struct ieee80211_hw *hw,
-				   struct ieee80211_sta *sta,
-				   u8 rssi_level)
+static void rtl92cu_update_hal_rate_table(struct ieee80211_hw *hw,
+					  struct ieee80211_sta *sta)
 {
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
 	struct rtl_phy *rtlphy =3D &(rtlpriv->phy);
 	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
-	u32 ratr_value =3D (u32) mac->basic_rates;
-	u8 *mcsrate =3D mac->mcs;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	u32 ratr_value;
 	u8 ratr_index =3D 0;
 	u8 nmode =3D mac->ht_enable;
-	u8 mimo_ps =3D 1;
-	u16 shortgi_rate =3D 0;
-	u32 tmp_ratr_value =3D 0;
+	u8 mimo_ps =3D IEEE80211_SMPS_OFF;
+	u16 shortgi_rate;
+	u32 tmp_ratr_value;
 	u8 curtxbw_40mhz =3D mac->bw_40;
-	u8 curshortgi_40mhz =3D mac->sgi_40;
-	u8 curshortgi_20mhz =3D mac->sgi_20;
+	u8 curshortgi_40mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
+			       1 : 0;
+	u8 curshortgi_20mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
+			       1 : 0;
 	enum wireless_mode wirelessmode =3D mac->mode;
=20
-	ratr_value |=3D ((*(u16 *) (mcsrate))) << 12;
+	if (rtlhal->current_bandtype =3D=3D BAND_ON_5G)
+		ratr_value =3D sta->supp_rates[1] << 4;
+	else
+		ratr_value =3D sta->supp_rates[0];
+	if (mac->opmode =3D=3D NL80211_IFTYPE_ADHOC)
+		ratr_value =3D 0xfff;
+
+	ratr_value |=3D (sta->ht_cap.mcs.rx_mask[1] << 20 |
+			sta->ht_cap.mcs.rx_mask[0] << 12);
 	switch (wirelessmode) {
 	case WIRELESS_MODE_B:
 		if (ratr_value & 0x0000000c)
@@ -2006,7 +2015,7 @@ void rtl92cu_update_hal_rate_table(struct ieee80211_h=
w *hw,
 	case WIRELESS_MODE_N_24G:
 	case WIRELESS_MODE_N_5G:
 		nmode =3D 1;
-		if (mimo_ps =3D=3D 0) {
+		if (mimo_ps =3D=3D IEEE80211_SMPS_STATIC) {
 			ratr_value &=3D 0x0007F005;
 		} else {
 			u32 ratr_mask;
@@ -2016,8 +2025,7 @@ void rtl92cu_update_hal_rate_table(struct ieee80211_h=
w *hw,
 				ratr_mask =3D 0x000ff005;
 			else
 				ratr_mask =3D 0x0f0ff005;
-			if (curtxbw_40mhz)
-				ratr_mask |=3D 0x00000010;
+
 			ratr_value &=3D ratr_mask;
 		}
 		break;
@@ -2026,41 +2034,74 @@ void rtl92cu_update_hal_rate_table(struct ieee80211=
_hw *hw,
 			ratr_value &=3D 0x000ff0ff;
 		else
 			ratr_value &=3D 0x0f0ff0ff;
+
 		break;
 	}
+
 	ratr_value &=3D 0x0FFFFFFF;
-	if (nmode && ((curtxbw_40mhz && curshortgi_40mhz) ||
-	    (!curtxbw_40mhz && curshortgi_20mhz))) {
+
+	if (nmode && ((curtxbw_40mhz &&
+			 curshortgi_40mhz) || (!curtxbw_40mhz &&
+					       curshortgi_20mhz))) {
+
 		ratr_value |=3D 0x10000000;
 		tmp_ratr_value =3D (ratr_value >> 12);
+
 		for (shortgi_rate =3D 15; shortgi_rate > 0; shortgi_rate--) {
 			if ((1 << shortgi_rate) & tmp_ratr_value)
 				break;
 		}
+
 		shortgi_rate =3D (shortgi_rate << 12) | (shortgi_rate << 8) |
-			       (shortgi_rate << 4) | (shortgi_rate);
+		    (shortgi_rate << 4) | (shortgi_rate);
 	}
+
 	rtl_write_dword(rtlpriv, REG_ARFR0 + ratr_index * 4, ratr_value);
+
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "%x\n",
+		 rtl_read_dword(rtlpriv, REG_ARFR0));
 }
=20
-void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw, u8 rssi_level)
+static void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw,
+					 struct ieee80211_sta *sta,
+					 u8 rssi_level)
 {
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
 	struct rtl_phy *rtlphy =3D &(rtlpriv->phy);
 	struct rtl_mac *mac =3D rtl_mac(rtl_priv(hw));
-	u32 ratr_bitmap =3D (u32) mac->basic_rates;
-	u8 *p_mcsrate =3D mac->mcs;
-	u8 ratr_index =3D 0;
-	u8 curtxbw_40mhz =3D mac->bw_40;
-	u8 curshortgi_40mhz =3D mac->sgi_40;
-	u8 curshortgi_20mhz =3D mac->sgi_20;
-	enum wireless_mode wirelessmode =3D mac->mode;
+	struct rtl_hal *rtlhal =3D rtl_hal(rtl_priv(hw));
+	struct rtl_sta_info *sta_entry =3D NULL;
+	u32 ratr_bitmap;
+	u8 ratr_index;
+	u8 curtxbw_40mhz =3D (sta->bandwidth >=3D IEEE80211_STA_RX_BW_40) ? 1 : 0;
+	u8 curshortgi_40mhz =3D curtxbw_40mhz &&
+			      (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_40) ?
+				1 : 0;
+	u8 curshortgi_20mhz =3D (sta->ht_cap.cap & IEEE80211_HT_CAP_SGI_20) ?
+				1 : 0;
+	enum wireless_mode wirelessmode =3D 0;
 	bool shortgi =3D false;
 	u8 rate_mask[5];
 	u8 macid =3D 0;
-	u8 mimops =3D 1;
-
-	ratr_bitmap |=3D (p_mcsrate[1] << 20) | (p_mcsrate[0] << 12);
+	u8 mimo_ps =3D IEEE80211_SMPS_OFF;
+
+	sta_entry =3D (struct rtl_sta_info *) sta->drv_priv;
+	wirelessmode =3D sta_entry->wireless_mode;
+	if (mac->opmode =3D=3D NL80211_IFTYPE_STATION ||
+	    mac->opmode =3D=3D NL80211_IFTYPE_MESH_POINT)
+		curtxbw_40mhz =3D mac->bw_40;
+	else if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
+		mac->opmode =3D=3D NL80211_IFTYPE_ADHOC)
+		macid =3D sta->aid + 1;
+
+	if (rtlhal->current_bandtype =3D=3D BAND_ON_5G)
+		ratr_bitmap =3D sta->supp_rates[1] << 4;
+	else
+		ratr_bitmap =3D sta->supp_rates[0];
+	if (mac->opmode =3D=3D NL80211_IFTYPE_ADHOC)
+		ratr_bitmap =3D 0xfff;
+	ratr_bitmap |=3D (sta->ht_cap.mcs.rx_mask[1] << 20 |
+			sta->ht_cap.mcs.rx_mask[0] << 12);
 	switch (wirelessmode) {
 	case WIRELESS_MODE_B:
 		ratr_index =3D RATR_INX_WIRELESS_B;
@@ -2071,6 +2112,7 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_hw=
 *hw, u8 rssi_level)
 		break;
 	case WIRELESS_MODE_G:
 		ratr_index =3D RATR_INX_WIRELESS_GB;
+
 		if (rssi_level =3D=3D 1)
 			ratr_bitmap &=3D 0x00000f00;
 		else if (rssi_level =3D=3D 2)
@@ -2085,7 +2127,8 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_hw=
 *hw, u8 rssi_level)
 	case WIRELESS_MODE_N_24G:
 	case WIRELESS_MODE_N_5G:
 		ratr_index =3D RATR_INX_WIRELESS_NGB;
-		if (mimops =3D=3D 0) {
+
+		if (mimo_ps =3D=3D IEEE80211_SMPS_STATIC) {
 			if (rssi_level =3D=3D 1)
 				ratr_bitmap &=3D 0x00070000;
 			else if (rssi_level =3D=3D 2)
@@ -2128,8 +2171,10 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_h=
w *hw, u8 rssi_level)
 				}
 			}
 		}
+
 		if ((curtxbw_40mhz && curshortgi_40mhz) ||
 		    (!curtxbw_40mhz && curshortgi_20mhz)) {
+
 			if (macid =3D=3D 0)
 				shortgi =3D true;
 			else if (macid =3D=3D 1)
@@ -2138,21 +2183,42 @@ void rtl92cu_update_hal_rate_mask(struct ieee80211_=
hw *hw, u8 rssi_level)
 		break;
 	default:
 		ratr_index =3D RATR_INX_WIRELESS_NGB;
+
 		if (rtlphy->rf_type =3D=3D RF_1T2R)
 			ratr_bitmap &=3D 0x000ff0ff;
 		else
 			ratr_bitmap &=3D 0x0f0ff0ff;
 		break;
 	}
-	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG, "ratr_bitmap :%x\n",
-		 ratr_bitmap);
-	*(u32 *)&rate_mask =3D ((ratr_bitmap & 0x0fffffff) |
-				      ratr_index << 28);
+	sta_entry->ratr_index =3D ratr_index;
+
+	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
+		 "ratr_bitmap :%x\n", ratr_bitmap);
+	*(u32 *)&rate_mask =3D (ratr_bitmap & 0x0fffffff) |
+				     (ratr_index << 28);
 	rate_mask[4] =3D macid | (shortgi ? 0x20 : 0x00) | 0x80;
 	RT_TRACE(rtlpriv, COMP_RATR, DBG_DMESG,
 		 "Rate_index:%x, ratr_val:%x, %5phC\n",
 		 ratr_index, ratr_bitmap, rate_mask);
-	rtl92c_fill_h2c_cmd(hw, H2C_RA_MASK, 5, rate_mask);
+	memcpy(rtlpriv->rate_mask, rate_mask, 5);
+	/* rtl92c_fill_h2c_cmd() does USB I/O and will result in a
+	 * "scheduled while atomic" if called directly */
+	schedule_work(&rtlpriv->works.fill_h2c_cmd);
+
+	if (macid !=3D 0)
+		sta_entry->ratr_index =3D ratr_index;
+}
+
+void rtl92cu_update_hal_rate_tbl(struct ieee80211_hw *hw,
+				 struct ieee80211_sta *sta,
+				 u8 rssi_level)
+{
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	if (rtlpriv->dm.useramask)
+		rtl92cu_update_hal_rate_mask(hw, sta, rssi_level);
+	else
+		rtl92cu_update_hal_rate_table(hw, sta);
 }
=20
 void rtl92cu_update_channel_access_setting(struct ieee80211_hw *hw)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h b/drivers/net/wire=
less/rtlwifi/rtl8192cu/hw.h
index f41a3aa..8e3ec1e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.h
@@ -98,10 +98,6 @@ void rtl92cu_update_interrupt_mask(struct ieee80211_hw *=
hw,
 				   u32 add_msr, u32 rm_msr);
 void rtl92cu_get_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
 void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val);
-void rtl92cu_update_hal_rate_table(struct ieee80211_hw *hw,
-				   struct ieee80211_sta *sta,
-				   u8 rssi_level);
-void rtl92cu_update_hal_rate_mask(struct ieee80211_hw *hw, u8 rssi_level);
=20
 void rtl92cu_update_channel_access_setting(struct ieee80211_hw *hw);
 bool rtl92cu_gpio_radio_on_off_checking(struct ieee80211_hw *hw, u8 * vali=
d);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c b/drivers/net/wir=
eless/rtlwifi/rtl8192cu/mac.c
index 85b6bdb..da4f587 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/mac.c
@@ -289,14 +289,30 @@ void rtl92c_set_key(struct ieee80211_hw *hw, u32 key_=
index,
 				macaddr =3D cam_const_broad;
 				entry_id =3D key_index;
 			} else {
+				if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
+				    mac->opmode =3D=3D NL80211_IFTYPE_MESH_POINT) {
+					entry_id =3D rtl_cam_get_free_entry(hw,
+								 p_macaddr);
+					if (entry_id >=3D  TOTAL_CAM_ENTRY) {
+						RT_TRACE(rtlpriv, COMP_SEC,
+							 DBG_EMERG,
+							 "Can not find free hw security cam entry\n");
+						return;
+					}
+				} else {
+					entry_id =3D CAM_PAIRWISE_KEY_POSITION;
+				}
+
 				key_index =3D PAIRWISE_KEYIDX;
-				entry_id =3D CAM_PAIRWISE_KEY_POSITION;
 				is_pairwise =3D true;
 			}
 		}
 		if (rtlpriv->sec.key_len[key_index] =3D=3D 0) {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 				 "delete one entry\n");
+			if (mac->opmode =3D=3D NL80211_IFTYPE_AP ||
+			    mac->opmode =3D=3D NL80211_IFTYPE_MESH_POINT)
+				rtl_cam_del_entry(hw, p_macaddr);
 			rtl_cam_delete_one_entry(hw, p_macaddr, entry_id);
 		} else {
 			RT_TRACE(rtlpriv, COMP_SEC, DBG_LOUD,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192cu/sw.c
index 938b1e6..826f085 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -106,8 +106,7 @@ static struct rtl_hal_ops rtl8192cu_hal_ops =3D {
 	.update_interrupt_mask =3D rtl92cu_update_interrupt_mask,
 	.get_hw_reg =3D rtl92cu_get_hw_reg,
 	.set_hw_reg =3D rtl92cu_set_hw_reg,
-	.update_rate_tbl =3D rtl92cu_update_hal_rate_table,
-	.update_rate_mask =3D rtl92cu_update_hal_rate_mask,
+	.update_rate_tbl =3D rtl92cu_update_hal_rate_tbl,
 	.fill_tx_desc =3D rtl92cu_tx_fill_desc,
 	.fill_fake_txdesc =3D rtl92cu_fill_fake_txdesc,
 	.fill_tx_cmddesc =3D rtl92cu_tx_fill_cmddesc,
@@ -137,6 +136,7 @@ static struct rtl_hal_ops rtl8192cu_hal_ops =3D {
 	.phy_lc_calibrate =3D _rtl92cu_phy_lc_calibrate,
 	.phy_set_bw_mode_callback =3D rtl92cu_phy_set_bw_mode_callback,
 	.dm_dynamic_txpower =3D rtl92cu_dm_dynamic_txpower,
+	.fill_h2c_cmd =3D rtl92c_fill_h2c_cmd,
 };
=20
 static struct rtl_mod_params rtl92cu_mod_params =3D {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.h b/drivers/net/wire=
less/rtlwifi/rtl8192cu/sw.h
index a1310ab..262e1e4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.h
@@ -49,5 +49,8 @@ bool rtl92cu_phy_set_rf_power_state(struct ieee80211_hw *=
hw,
 u32 rtl92cu_phy_query_rf_reg(struct ieee80211_hw *hw,
 			    enum radio_path rfpath, u32 regaddr, u32 bitmask);
 void rtl92cu_phy_set_bw_mode_callback(struct ieee80211_hw *hw);
+void rtl92cu_update_hal_rate_tbl(struct ieee80211_hw *hw,
+				 struct ieee80211_sta *sta,
+				 u8 rssi_level);
=20
 #endif
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlw=
ifi/usb.c
index 76732b0..a3532e0 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -824,6 +824,7 @@ static void rtl_usb_stop(struct ieee80211_hw *hw)
=20
 	/* should after adapter start and interrupt enable. */
 	set_hal_stop(rtlhal);
+	cancel_work_sync(&rtlpriv->works.fill_h2c_cmd);
 	/* Enable software */
 	SET_USB_STOP(rtlusb);
 	rtl_usb_deinit(hw);
@@ -1026,6 +1027,16 @@ static bool rtl_usb_tx_chk_waitq_insert(struct ieee8=
0211_hw *hw,
 	return false;
 }
=20
+static void rtl_fill_h2c_cmd_work_callback(struct work_struct *work)
+{
+	struct rtl_works *rtlworks =3D
+	    container_of(work, struct rtl_works, fill_h2c_cmd);
+	struct ieee80211_hw *hw =3D rtlworks->hw;
+	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
+
+	rtlpriv->cfg->ops->fill_h2c_cmd(hw, H2C_RA_MASK, 5, rtlpriv->rate_mask);
+}
+
 static struct rtl_intf_ops rtl_usb_ops =3D {
 	.adapter_start =3D rtl_usb_start,
 	.adapter_stop =3D rtl_usb_stop,
@@ -1057,6 +1068,8 @@ int rtl_usb_probe(struct usb_interface *intf,
=20
 	/* this spin lock must be initialized early */
 	spin_lock_init(&rtlpriv->locks.usb_lock);
+	INIT_WORK(&rtlpriv->works.fill_h2c_cmd,
+		  rtl_fill_h2c_cmd_work_callback);
=20
 	rtlpriv->usb_data_index =3D 0;
 	init_completion(&rtlpriv->firmware_loading_complete);
diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtl=
wifi/wifi.h
index 44328ba..cc03e7c 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1736,6 +1736,8 @@ struct rtl_hal_ops {
 	void (*bt_wifi_media_status_notify) (struct ieee80211_hw *hw,
 					     bool mstate);
 	void (*bt_coex_off_before_lps) (struct ieee80211_hw *hw);
+	void (*fill_h2c_cmd) (struct ieee80211_hw *hw, u8 element_id,
+			      u32 cmd_len, u8 *p_cmdbuffer);
 };
=20
 struct rtl_intf_ops {
@@ -1869,6 +1871,7 @@ struct rtl_works {
 	struct delayed_work fwevt_wq;
=20
 	struct work_struct lps_change_work;
+	struct work_struct fill_h2c_cmd;
 };
=20
 struct rtl_debug {
@@ -2048,6 +2051,7 @@ struct rtl_priv {
 		};
 	};
 	bool enter_ps;	/* true when entering PS */
+	u8 rate_mask[5];
=20
 	/*This must be the last item so
 	   that it points to the data allocated
diff --git a/include/net/bluetooth/hci_core.h b/include/net/bluetooth/hci_c=
ore.h
index 35a57cd..7cb6d36 100644
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -1117,6 +1117,7 @@ void hci_sock_dev_event(struct hci_dev *hdev, int eve=
nt);
 int mgmt_control(struct sock *sk, struct msghdr *msg, size_t len);
 int mgmt_index_added(struct hci_dev *hdev);
 int mgmt_index_removed(struct hci_dev *hdev);
+int mgmt_set_powered_failed(struct hci_dev *hdev, int err);
 int mgmt_powered(struct hci_dev *hdev, u8 powered);
 int mgmt_discoverable(struct hci_dev *hdev, u8 discoverable);
 int mgmt_connectable(struct hci_dev *hdev, u8 connectable);
diff --git a/include/net/bluetooth/mgmt.h b/include/net/bluetooth/mgmt.h
index 22980a7..9944c3e 100644
--- a/include/net/bluetooth/mgmt.h
+++ b/include/net/bluetooth/mgmt.h
@@ -42,6 +42,7 @@
 #define MGMT_STATUS_NOT_POWERED		0x0f
 #define MGMT_STATUS_CANCELLED		0x10
 #define MGMT_STATUS_INVALID_INDEX	0x11
+#define MGMT_STATUS_RFKILLED		0x12
=20
 struct mgmt_hdr {
 	__le16	opcode;
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index 33843c5..d817c93 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -1555,11 +1555,15 @@ static const struct rfkill_ops hci_rfkill_ops =3D {
 static void hci_power_on(struct work_struct *work)
 {
 	struct hci_dev *hdev =3D container_of(work, struct hci_dev, power_on);
+	int err;
=20
 	BT_DBG("%s", hdev->name);
=20
-	if (hci_dev_open(hdev->id) < 0)
+	err =3D hci_dev_open(hdev->id);
+	if (err < 0) {
+		mgmt_set_powered_failed(hdev, err);
 		return;
+	}
=20
 	if (test_bit(HCI_AUTO_OFF, &hdev->dev_flags))
 		queue_delayed_work(hdev->req_workqueue, &hdev->power_off,
diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index a76d1ac..24bee07 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -3677,10 +3677,14 @@ static void l2cap_conf_rfc_get(struct l2cap_chan *c=
han, void *rsp, int len)
 }
=20
 static inline int l2cap_command_rej(struct l2cap_conn *conn,
-				    struct l2cap_cmd_hdr *cmd, u8 *data)
+				    struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+				    u8 *data)
 {
 	struct l2cap_cmd_rej_unk *rej =3D (struct l2cap_cmd_rej_unk *) data;
=20
+	if (cmd_len < sizeof(*rej))
+		return -EPROTO;
+
 	if (rej->reason !=3D L2CAP_REJ_NOT_UNDERSTOOD)
 		return 0;
=20
@@ -3829,11 +3833,14 @@ sendresp:
 }
=20
 static int l2cap_connect_req(struct l2cap_conn *conn,
-			     struct l2cap_cmd_hdr *cmd, u8 *data)
+			     struct l2cap_cmd_hdr *cmd, u16 cmd_len, u8 *data)
 {
 	struct hci_dev *hdev =3D conn->hcon->hdev;
 	struct hci_conn *hcon =3D conn->hcon;
=20
+	if (cmd_len < sizeof(struct l2cap_conn_req))
+		return -EPROTO;
+
 	hci_dev_lock(hdev);
 	if (test_bit(HCI_MGMT, &hdev->dev_flags) &&
 	    !test_and_set_bit(HCI_CONN_MGMT_CONNECTED, &hcon->flags))
@@ -3847,7 +3854,8 @@ static int l2cap_connect_req(struct l2cap_conn *conn,
 }
=20
 static int l2cap_connect_create_rsp(struct l2cap_conn *conn,
-				    struct l2cap_cmd_hdr *cmd, u8 *data)
+				    struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+				    u8 *data)
 {
 	struct l2cap_conn_rsp *rsp =3D (struct l2cap_conn_rsp *) data;
 	u16 scid, dcid, result, status;
@@ -3855,6 +3863,9 @@ static int l2cap_connect_create_rsp(struct l2cap_conn=
 *conn,
 	u8 req[128];
 	int err;
=20
+	if (cmd_len < sizeof(*rsp))
+		return -EPROTO;
+
 	scid   =3D __le16_to_cpu(rsp->scid);
 	dcid   =3D __le16_to_cpu(rsp->dcid);
 	result =3D __le16_to_cpu(rsp->result);
@@ -3952,6 +3963,9 @@ static inline int l2cap_config_req(struct l2cap_conn =
*conn,
 	struct l2cap_chan *chan;
 	int len, err =3D 0;
=20
+	if (cmd_len < sizeof(*req))
+		return -EPROTO;
+
 	dcid  =3D __le16_to_cpu(req->dcid);
 	flags =3D __le16_to_cpu(req->flags);
=20
@@ -3975,7 +3989,7 @@ static inline int l2cap_config_req(struct l2cap_conn =
*conn,
=20
 	/* Reject if config buffer is too small. */
 	len =3D cmd_len - sizeof(*req);
-	if (len < 0 || chan->conf_len + len > sizeof(chan->conf_req)) {
+	if (chan->conf_len + len > sizeof(chan->conf_req)) {
 		l2cap_send_cmd(conn, cmd->ident, L2CAP_CONF_RSP,
 			       l2cap_build_conf_rsp(chan, rsp,
 			       L2CAP_CONF_REJECT, flags), rsp);
@@ -4053,14 +4067,18 @@ unlock:
 }
=20
 static inline int l2cap_config_rsp(struct l2cap_conn *conn,
-				   struct l2cap_cmd_hdr *cmd, u8 *data)
+				   struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+				   u8 *data)
 {
 	struct l2cap_conf_rsp *rsp =3D (struct l2cap_conf_rsp *)data;
 	u16 scid, flags, result;
 	struct l2cap_chan *chan;
-	int len =3D le16_to_cpu(cmd->len) - sizeof(*rsp);
+	int len =3D cmd_len - sizeof(*rsp);
 	int err =3D 0;
=20
+	if (cmd_len < sizeof(*rsp))
+		return -EPROTO;
+
 	scid   =3D __le16_to_cpu(rsp->scid);
 	flags  =3D __le16_to_cpu(rsp->flags);
 	result =3D __le16_to_cpu(rsp->result);
@@ -4161,7 +4179,8 @@ done:
 }
=20
 static inline int l2cap_disconnect_req(struct l2cap_conn *conn,
-				       struct l2cap_cmd_hdr *cmd, u8 *data)
+				       struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+				       u8 *data)
 {
 	struct l2cap_disconn_req *req =3D (struct l2cap_disconn_req *) data;
 	struct l2cap_disconn_rsp rsp;
@@ -4169,6 +4188,9 @@ static inline int l2cap_disconnect_req(struct l2cap_c=
onn *conn,
 	struct l2cap_chan *chan;
 	struct sock *sk;
=20
+	if (cmd_len !=3D sizeof(*req))
+		return -EPROTO;
+
 	scid =3D __le16_to_cpu(req->scid);
 	dcid =3D __le16_to_cpu(req->dcid);
=20
@@ -4208,12 +4230,16 @@ static inline int l2cap_disconnect_req(struct l2cap=
_conn *conn,
 }
=20
 static inline int l2cap_disconnect_rsp(struct l2cap_conn *conn,
-				       struct l2cap_cmd_hdr *cmd, u8 *data)
+				       struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+				       u8 *data)
 {
 	struct l2cap_disconn_rsp *rsp =3D (struct l2cap_disconn_rsp *) data;
 	u16 dcid, scid;
 	struct l2cap_chan *chan;
=20
+	if (cmd_len !=3D sizeof(*rsp))
+		return -EPROTO;
+
 	scid =3D __le16_to_cpu(rsp->scid);
 	dcid =3D __le16_to_cpu(rsp->dcid);
=20
@@ -4243,11 +4269,15 @@ static inline int l2cap_disconnect_rsp(struct l2cap=
_conn *conn,
 }
=20
 static inline int l2cap_information_req(struct l2cap_conn *conn,
-					struct l2cap_cmd_hdr *cmd, u8 *data)
+					struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+					u8 *data)
 {
 	struct l2cap_info_req *req =3D (struct l2cap_info_req *) data;
 	u16 type;
=20
+	if (cmd_len !=3D sizeof(*req))
+		return -EPROTO;
+
 	type =3D __le16_to_cpu(req->type);
=20
 	BT_DBG("type 0x%4.4x", type);
@@ -4294,11 +4324,15 @@ static inline int l2cap_information_req(struct l2ca=
p_conn *conn,
 }
=20
 static inline int l2cap_information_rsp(struct l2cap_conn *conn,
-					struct l2cap_cmd_hdr *cmd, u8 *data)
+					struct l2cap_cmd_hdr *cmd, u16 cmd_len,
+					u8 *data)
 {
 	struct l2cap_info_rsp *rsp =3D (struct l2cap_info_rsp *) data;
 	u16 type, result;
=20
+	if (cmd_len !=3D sizeof(*rsp))
+		return -EPROTO;
+
 	type   =3D __le16_to_cpu(rsp->type);
 	result =3D __le16_to_cpu(rsp->result);
=20
@@ -5164,16 +5198,16 @@ static inline int l2cap_bredr_sig_cmd(struct l2cap_=
conn *conn,
=20
 	switch (cmd->code) {
 	case L2CAP_COMMAND_REJ:
-		l2cap_command_rej(conn, cmd, data);
+		l2cap_command_rej(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_CONN_REQ:
-		err =3D l2cap_connect_req(conn, cmd, data);
+		err =3D l2cap_connect_req(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_CONN_RSP:
 	case L2CAP_CREATE_CHAN_RSP:
-		err =3D l2cap_connect_create_rsp(conn, cmd, data);
+		err =3D l2cap_connect_create_rsp(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_CONF_REQ:
@@ -5181,15 +5215,15 @@ static inline int l2cap_bredr_sig_cmd(struct l2cap_=
conn *conn,
 		break;
=20
 	case L2CAP_CONF_RSP:
-		err =3D l2cap_config_rsp(conn, cmd, data);
+		err =3D l2cap_config_rsp(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_DISCONN_REQ:
-		err =3D l2cap_disconnect_req(conn, cmd, data);
+		err =3D l2cap_disconnect_req(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_DISCONN_RSP:
-		err =3D l2cap_disconnect_rsp(conn, cmd, data);
+		err =3D l2cap_disconnect_rsp(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_ECHO_REQ:
@@ -5200,11 +5234,11 @@ static inline int l2cap_bredr_sig_cmd(struct l2cap_=
conn *conn,
 		break;
=20
 	case L2CAP_INFO_REQ:
-		err =3D l2cap_information_req(conn, cmd, data);
+		err =3D l2cap_information_req(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_INFO_RSP:
-		err =3D l2cap_information_rsp(conn, cmd, data);
+		err =3D l2cap_information_rsp(conn, cmd, cmd_len, data);
 		break;
=20
 	case L2CAP_CREATE_CHAN_REQ:
diff --git a/net/bluetooth/mgmt.c b/net/bluetooth/mgmt.c
index 35fef22..f8ecbc7 100644
--- a/net/bluetooth/mgmt.c
+++ b/net/bluetooth/mgmt.c
@@ -2700,7 +2700,7 @@ static int start_discovery(struct sock *sk, struct hc=
i_dev *hdev,
 		break;
=20
 	case DISCOV_TYPE_LE:
-		if (!lmp_host_le_capable(hdev)) {
+		if (!test_bit(HCI_LE_ENABLED, &hdev->dev_flags)) {
 			err =3D cmd_status(sk, hdev->id, MGMT_OP_START_DISCOVERY,
 					 MGMT_STATUS_NOT_SUPPORTED);
 			mgmt_pending_remove(cmd);
@@ -3418,6 +3418,27 @@ new_settings:
 	return err;
 }
=20
+int mgmt_set_powered_failed(struct hci_dev *hdev, int err)
+{
+	struct pending_cmd *cmd;
+	u8 status;
+
+	cmd =3D mgmt_pending_find(MGMT_OP_SET_POWERED, hdev);
+	if (!cmd)
+		return -ENOENT;
+
+	if (err =3D=3D -ERFKILL)
+		status =3D MGMT_STATUS_RFKILLED;
+	else
+		status =3D MGMT_STATUS_FAILED;
+
+	err =3D cmd_status(cmd->sk, hdev->id, MGMT_OP_SET_POWERED, status);
+
+	mgmt_pending_remove(cmd);
+
+	return err;
+}
+
 int mgmt_discoverable(struct hci_dev *hdev, u8 discoverable)
 {
 	struct cmd_lookup match =3D { NULL, hdev };
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index b2296d3..b5562ab 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -770,7 +770,7 @@ int smp_conn_security(struct hci_conn *hcon, __u8 sec_l=
evel)
=20
 	BT_DBG("conn %p hcon %p level 0x%2.2x", conn, hcon, sec_level);
=20
-	if (!lmp_host_le_capable(hcon->hdev))
+	if (!test_bit(HCI_LE_ENABLED, &hcon->hdev->dev_flags))
 		return 1;
=20
 	if (sec_level =3D=3D BT_SECURITY_LOW)
@@ -851,7 +851,7 @@ int smp_sig_channel(struct l2cap_conn *conn, struct sk_=
buff *skb)
 	__u8 reason;
 	int err =3D 0;
=20
-	if (!lmp_host_le_capable(conn->hcon->hdev)) {
+	if (!test_bit(HCI_LE_ENABLED, &conn->hcon->hdev->dev_flags)) {
 		err =3D -ENOTSUPP;
 		reason =3D SMP_PAIRING_NOTSUPP;
 		goto done;
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRrOTxAAoJEJctW/TcYTgGAT0P/RqxDZ45ehRn7nYw5hbMRFE1
DcM0R73abuVWC3+xVf3IeN0gal6CUHhBQyN+dl60oiKo7ZhQIUqCN7DkJUNkGLp7
KKKP+B2wD8Tw3ueu63l6eI4SamwnZCnInfSogK36ZC3XlOw8QlV1JKqfxqZ4549G
8u3jm8qYYXIdiq1e8/ILrNoIGXMpWM/If5E1NQVw0eszdxh5eR0Nd6SkEGhyE3GK
7PjmA739RzSGk927s5mEa7hXr6MJ3ACMQN7/0Y/Cg2lIohrAkZK5Xh3s3i7iEUZq
tAAWavDO+W5W7vbbhftZ57Nto1/P+7USgsLTAEeeeyMV4v+IHxmhxEvbLP/A0Xzq
lham6Var2Tek4CtUa/zBwGvoalraDI6L32pwgsM6H69eN4LguS2V+bolq5rlm1Ug
gli9kvjAlSZKtZQywo7IFACtr83bAjb+TuGHOf31eJVdG04DrS9BZH9ga57+h2Uj
yjQ1mmDXXpFfZ0TvmwT8A4+wkQ0pk1rXxGK1B7J0o23wRCa2R7knqhbwZKr2OlCi
45eDbKsiCgJHOFpVhJlTgHcgGIBvRriDW3Jou5iZ6dh3jEYg81bHot45rRQClY1Y
YP7a5D9LZ6wFpxNHIObqDvWVB8lphHcxrN0kOM0jmTAqKu/xVShKosCvj2CgRL0s
8GhBg6cA1b8u9t/D76op
=nKzt
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
