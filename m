From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 'upstream' 2008-01-29
Date: Tue, 29 Jan 2008 16:27:03 -0500
Message-ID: <20080129212703.GA3180@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3557 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757262AbYA2Vc1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 16:32:27 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here are some stragglers for 2.6.25.  Most of them are fixes for the
new stuff anyway -- I don't think there is anything convroversial.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/up=
stream

---

The following changes since commit 85040bcb4643cba578839e953f25e2d1965d=
83d0:
  YOSHIFUJI Hideaki (1):
        [IPV6] ADDRLABEL: Fix double free on label deletion.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it upstream

Adrian Bassett (1):
      rtl8180_dev.c: add support for 1799:700f

Bruno Randolf (1):
      ath5k: debug level improvements

Cyrill Gorcunov (1):
      wireless: iwlwifi3945/4965 - fix incorrect counting of memory

Eric Sandeen (1):
      iwlwifi: correct math in elapsed_jiffies

Gregory Greenman (1):
      iwlwifi: Fix uCode error on association

Holger Schurig (1):
      libertas: fix interrupt while removing driver

Ihar Hrachyshka (1):
      libertas: fix memory alignment problems on the blackfin

I=F1aky P=E9rez-Gonz=E1lez (1):
      rfkill: add the WiMAX radio type

Johannes Berg (1):
      mac80211: fix alignment warning

John W. Linville (1):
      rt61pci: fix-up merge damage

Joonwoo Park (1):
      iwlwifi: do not schedule tasklet when rcv unused irq

Maarten Lankhorst (1):
      iwlwifi: Fix an invalid bitmask test in iwl3945 and iwl4965

Marcin Juszkiewicz (1):
      Add another Prism2 card to hostap

Michael Buesch (4):
      b43: Fix rfkill allocation leakage in error paths
      b43legacy: Fix rfkill allocation leakage in error paths
      b43: Fix suspend/resume
      b43: Drop packets that we are not able to encrypt

Michal Piotrowski (1):
      hostap_80211.h: remove duplicate prototype

Reinette Chatre (3):
      iwl4965: fix return code indicating one interface is supported
      iwlwifi: initialize geo/channel information during probe
      iwlwifi: cleanup usage of inline functions

Ron Rindjunsky (1):
      mac80211: fixing null qos data frames check for reordering buffer

Stefano Brivio (1):
      b43legacy: fix MAC control and microcode init

 drivers/net/wireless/ath5k/base.c           |   10 +-
 drivers/net/wireless/ath5k/debug.c          |  124 +++++++++++++++++++=
++----
 drivers/net/wireless/ath5k/debug.h          |   18 ++--
 drivers/net/wireless/b43/dma.c              |   30 +++++-
 drivers/net/wireless/b43/main.c             |   19 +++-
 drivers/net/wireless/b43/xmit.c             |   23 +++--
 drivers/net/wireless/b43/xmit.h             |   10 +-
 drivers/net/wireless/b43legacy/b43legacy.h  |   31 +++----
 drivers/net/wireless/b43legacy/main.c       |  133 ++++++++++++++++++-=
--------
 drivers/net/wireless/b43legacy/phy.c        |   14 ++--
 drivers/net/wireless/b43legacy/pio.c        |    6 +-
 drivers/net/wireless/b43legacy/radio.c      |   16 ++--
 drivers/net/wireless/hostap/hostap_80211.h  |    5 -
 drivers/net/wireless/hostap/hostap_cs.c     |    3 +
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c     |   14 ---
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    2 -
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h  |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    7 --
 drivers/net/wireless/iwlwifi/iwl-4965.h     |    1 -
 drivers/net/wireless/iwlwifi/iwl-helpers.h  |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |   86 +++++++++++++----
 drivers/net/wireless/iwlwifi/iwl4965-base.c |   84 ++++++++++++-----
 drivers/net/wireless/libertas/assoc.c       |    6 +-
 drivers/net/wireless/libertas/dev.h         |    2 +-
 drivers/net/wireless/libertas/if_cs.c       |    6 +-
 drivers/net/wireless/rt2x00/rt61pci.c       |    3 +-
 drivers/net/wireless/rtl8180_dev.c          |    1 +
 include/linux/input.h                       |    2 +
 include/linux/rfkill.h                      |    2 +
 net/mac80211/rx.c                           |   48 +++++++---
 net/rfkill/rfkill-input.c                   |    9 ++
 net/rfkill/rfkill.c                         |    3 +
 33 files changed, 490 insertions(+), 236 deletions(-)

diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/a=
th5k/base.c
index 72bcf32..d6599d2 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -1980,7 +1980,7 @@ ath5k_beacon_send(struct ath5k_softc *sc)
 	struct ath5k_buf *bf =3D sc->bbuf;
 	struct ath5k_hw *ah =3D sc->ah;
=20
-	ATH5K_DBG(sc, ATH5K_DEBUG_BEACON_PROC, "in beacon_send\n");
+	ATH5K_DBG_UNLIMIT(sc, ATH5K_DEBUG_BEACON, "in beacon_send\n");
=20
 	if (unlikely(bf->skb =3D=3D NULL || sc->opmode =3D=3D IEEE80211_IF_TY=
PE_STA ||
 			sc->opmode =3D=3D IEEE80211_IF_TYPE_MNTR)) {
@@ -1996,10 +1996,10 @@ ath5k_beacon_send(struct ath5k_softc *sc)
 	 */
 	if (unlikely(ath5k_hw_num_tx_pending(ah, sc->bhalq) !=3D 0)) {
 		sc->bmisscount++;
-		ATH5K_DBG(sc, ATH5K_DEBUG_BEACON_PROC,
+		ATH5K_DBG(sc, ATH5K_DEBUG_BEACON,
 			"missed %u consecutive beacons\n", sc->bmisscount);
 		if (sc->bmisscount > 3) {		/* NB: 3 is a guess */
-			ATH5K_DBG(sc, ATH5K_DEBUG_BEACON_PROC,
+			ATH5K_DBG(sc, ATH5K_DEBUG_BEACON,
 				"stuck beacon time (%u missed)\n",
 				sc->bmisscount);
 			tasklet_schedule(&sc->restq);
@@ -2007,7 +2007,7 @@ ath5k_beacon_send(struct ath5k_softc *sc)
 		return;
 	}
 	if (unlikely(sc->bmisscount !=3D 0)) {
-		ATH5K_DBG(sc, ATH5K_DEBUG_BEACON_PROC,
+		ATH5K_DBG(sc, ATH5K_DEBUG_BEACON,
 			"resume beacon xmit after %u misses\n",
 			sc->bmisscount);
 		sc->bmisscount =3D 0;
@@ -2027,7 +2027,7 @@ ath5k_beacon_send(struct ath5k_softc *sc)
=20
 	ath5k_hw_put_tx_buf(ah, sc->bhalq, bf->daddr);
 	ath5k_hw_tx_start(ah, sc->bhalq);
-	ATH5K_DBG(sc, ATH5K_DEBUG_BEACON_PROC, "TXDP[%u] =3D %llx (%p)\n",
+	ATH5K_DBG(sc, ATH5K_DEBUG_BEACON, "TXDP[%u] =3D %llx (%p)\n",
 		sc->bhalq, (unsigned long long)bf->daddr, bf->desc);
=20
 	sc->bsent++;
diff --git a/drivers/net/wireless/ath5k/debug.c b/drivers/net/wireless/=
ath5k/debug.c
index 4ba649e..bb581ef 100644
--- a/drivers/net/wireless/ath5k/debug.c
+++ b/drivers/net/wireless/ath5k/debug.c
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2007 Bruno Randolf <bruno@thinktube.com>
+ * Copyright (c) 2007-2008 Bruno Randolf <bruno@thinktube.com>
  *
  *  This file is free software: you may copy, redistribute and/or modi=
fy it
  *  under the terms of the GNU General Public License as published by =
the
@@ -200,7 +200,7 @@ static ssize_t read_file_tsf(struct file *file, cha=
r __user *user_buf,
 {
 	struct ath5k_softc *sc =3D file->private_data;
 	char buf[100];
-	snprintf(buf, 100, "0x%016llx\n", ath5k_hw_get_tsf64(sc->ah));
+	snprintf(buf, sizeof(buf), "0x%016llx\n", ath5k_hw_get_tsf64(sc->ah))=
;
 	return simple_read_from_buffer(user_buf, count, ppos, buf, 19);
 }
=20
@@ -209,7 +209,12 @@ static ssize_t write_file_tsf(struct file *file,
 				 size_t count, loff_t *ppos)
 {
 	struct ath5k_softc *sc =3D file->private_data;
-	if (strncmp(userbuf, "reset", 5) =3D=3D 0) {
+	char buf[20];
+
+	if (copy_from_user(buf, userbuf, min(count, sizeof(buf))))
+		return -EFAULT;
+
+	if (strncmp(buf, "reset", 5) =3D=3D 0) {
 		ath5k_hw_reset_tsf(sc->ah);
 		printk(KERN_INFO "debugfs reset TSF\n");
 	}
@@ -231,8 +236,8 @@ static ssize_t read_file_beacon(struct file *file, =
char __user *user_buf,
 {
 	struct ath5k_softc *sc =3D file->private_data;
 	struct ath5k_hw *ah =3D sc->ah;
-	char buf[1000];
-	int len =3D 0;
+	char buf[500];
+	unsigned int len =3D 0;
 	unsigned int v;
 	u64 tsf;
=20
@@ -277,11 +282,15 @@ static ssize_t write_file_beacon(struct file *fil=
e,
 {
 	struct ath5k_softc *sc =3D file->private_data;
 	struct ath5k_hw *ah =3D sc->ah;
+	char buf[20];
+
+	if (copy_from_user(buf, userbuf, min(count, sizeof(buf))))
+		return -EFAULT;
=20
-	if (strncmp(userbuf, "disable", 7) =3D=3D 0) {
+	if (strncmp(buf, "disable", 7) =3D=3D 0) {
 		AR5K_REG_DISABLE_BITS(ah, AR5K_BEACON, AR5K_BEACON_ENABLE);
 		printk(KERN_INFO "debugfs disable beacons\n");
-	} else if (strncmp(userbuf, "enable", 6) =3D=3D 0) {
+	} else if (strncmp(buf, "enable", 6) =3D=3D 0) {
 		AR5K_REG_ENABLE_BITS(ah, AR5K_BEACON, AR5K_BEACON_ENABLE);
 		printk(KERN_INFO "debugfs enable beacons\n");
 	}
@@ -314,6 +323,82 @@ static const struct file_operations fops_reset =3D=
 {
 };
=20
=20
+/* debugfs: debug level */
+
+static struct {
+	enum ath5k_debug_level level;
+	const char *name;
+	const char *desc;
+} dbg_info[] =3D {
+	{ ATH5K_DEBUG_RESET,	"reset",	"reset and initialization" },
+	{ ATH5K_DEBUG_INTR,	"intr",		"interrupt handling" },
+	{ ATH5K_DEBUG_MODE,	"mode",		"mode init/setup" },
+	{ ATH5K_DEBUG_XMIT,	"xmit",		"basic xmit operation" },
+	{ ATH5K_DEBUG_BEACON,	"beacon",	"beacon handling" },
+	{ ATH5K_DEBUG_CALIBRATE, "calib",	"periodic calibration" },
+	{ ATH5K_DEBUG_TXPOWER,	"txpower",	"transmit power setting" },
+	{ ATH5K_DEBUG_LED,	"led",		"LED mamagement" },
+	{ ATH5K_DEBUG_DUMP_RX,	"dumprx",	"print received skb content" },
+	{ ATH5K_DEBUG_DUMP_TX,	"dumptx",	"print transmit skb content" },
+	{ ATH5K_DEBUG_DUMPMODES, "dumpmodes",	"dump modes" },
+	{ ATH5K_DEBUG_TRACE,	"trace",	"trace function calls" },
+	{ ATH5K_DEBUG_ANY,	"all",		"show all debug levels" },
+};
+
+static ssize_t read_file_debug(struct file *file, char __user *user_bu=
f,
+				   size_t count, loff_t *ppos)
+{
+	struct ath5k_softc *sc =3D file->private_data;
+	char buf[700];
+	unsigned int len =3D 0;
+	unsigned int i;
+
+	len +=3D snprintf(buf+len, sizeof(buf)-len,
+		"DEBUG LEVEL: 0x%08x\n\n", sc->debug.level);
+
+	for (i =3D 0; i < ARRAY_SIZE(dbg_info) - 1; i++) {
+		len +=3D snprintf(buf+len, sizeof(buf)-len,
+			"%10s %c 0x%08x - %s\n", dbg_info[i].name,
+			sc->debug.level & dbg_info[i].level ? '+' : ' ',
+			dbg_info[i].level, dbg_info[i].desc);
+	}
+	len +=3D snprintf(buf+len, sizeof(buf)-len,
+		"%10s %c 0x%08x - %s\n", dbg_info[i].name,
+		sc->debug.level =3D=3D dbg_info[i].level ? '+' : ' ',
+		dbg_info[i].level, dbg_info[i].desc);
+
+	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
+}
+
+static ssize_t write_file_debug(struct file *file,
+				 const char __user *userbuf,
+				 size_t count, loff_t *ppos)
+{
+	struct ath5k_softc *sc =3D file->private_data;
+	unsigned int i;
+	char buf[20];
+
+	if (copy_from_user(buf, userbuf, min(count, sizeof(buf))))
+		return -EFAULT;
+
+	for (i =3D 0; i < ARRAY_SIZE(dbg_info); i++) {
+		if (strncmp(buf, dbg_info[i].name,
+					strlen(dbg_info[i].name)) =3D=3D 0) {
+			sc->debug.level ^=3D dbg_info[i].level; /* toggle bit */
+			break;
+		}
+	}
+	return count;
+}
+
+static const struct file_operations fops_debug =3D {
+	.read =3D read_file_debug,
+	.write =3D write_file_debug,
+	.open =3D ath5k_debugfs_open,
+	.owner =3D THIS_MODULE,
+};
+
+
 /* init */
=20
 void
@@ -326,26 +411,24 @@ void
 ath5k_debug_init_device(struct ath5k_softc *sc)
 {
 	sc->debug.level =3D ath5k_debug;
+
 	sc->debug.debugfs_phydir =3D debugfs_create_dir(wiphy_name(sc->hw->wi=
phy),
-			ath5k_global_debugfs);
-	sc->debug.debugfs_debug =3D debugfs_create_u32("debug",
-			0666, sc->debug.debugfs_phydir, &sc->debug.level);
+				ath5k_global_debugfs);
+
+	sc->debug.debugfs_debug =3D debugfs_create_file("debug", 0666,
+				sc->debug.debugfs_phydir, sc, &fops_debug);
=20
 	sc->debug.debugfs_registers =3D debugfs_create_file("registers", 0444=
,
-				sc->debug.debugfs_phydir,
-				sc, &fops_registers);
+				sc->debug.debugfs_phydir, sc, &fops_registers);
=20
 	sc->debug.debugfs_tsf =3D debugfs_create_file("tsf", 0666,
-				sc->debug.debugfs_phydir,
-				sc, &fops_tsf);
+				sc->debug.debugfs_phydir, sc, &fops_tsf);
=20
 	sc->debug.debugfs_beacon =3D debugfs_create_file("beacon", 0666,
-				sc->debug.debugfs_phydir,
-				sc, &fops_beacon);
+				sc->debug.debugfs_phydir, sc, &fops_beacon);
=20
 	sc->debug.debugfs_reset =3D debugfs_create_file("reset", 0222,
-				sc->debug.debugfs_phydir,
-				sc, &fops_reset);
+				sc->debug.debugfs_phydir, sc, &fops_reset);
 }
=20
 void
@@ -415,8 +498,7 @@ ath5k_debug_printrxbuffs(struct ath5k_softc *sc, st=
ruct ath5k_hw *ah)
 	struct ath5k_buf *bf;
 	int status;
=20
-	if (likely(!(sc->debug.level &
-	    (ATH5K_DEBUG_RESET | ATH5K_DEBUG_FATAL))))
+	if (likely(!(sc->debug.level & ATH5K_DEBUG_RESET)))
 		return;
=20
 	printk(KERN_DEBUG "rx queue %x, link %p\n",
@@ -426,7 +508,7 @@ ath5k_debug_printrxbuffs(struct ath5k_softc *sc, st=
ruct ath5k_hw *ah)
 	list_for_each_entry(bf, &sc->rxbuf, list) {
 		ds =3D bf->desc;
 		status =3D ah->ah_proc_rx_desc(ah, ds);
-		if (!status || (sc->debug.level & ATH5K_DEBUG_FATAL))
+		if (!status)
 			ath5k_debug_printrxbuf(bf, status =3D=3D 0);
 	}
 	spin_unlock_bh(&sc->rxbuflock);
diff --git a/drivers/net/wireless/ath5k/debug.h b/drivers/net/wireless/=
ath5k/debug.h
index 2b491cb..c4fd8c4 100644
--- a/drivers/net/wireless/ath5k/debug.h
+++ b/drivers/net/wireless/ath5k/debug.h
@@ -91,7 +91,6 @@ struct ath5k_dbg_info {
  * @ATH5K_DEBUG_MODE: mode init/setup
  * @ATH5K_DEBUG_XMIT: basic xmit operation
  * @ATH5K_DEBUG_BEACON: beacon handling
- * @ATH5K_DEBUG_BEACON_PROC: beacon ISR proc
  * @ATH5K_DEBUG_CALIBRATE: periodic calibration
  * @ATH5K_DEBUG_TXPOWER: transmit power setting
  * @ATH5K_DEBUG_LED: led management
@@ -99,7 +98,6 @@ struct ath5k_dbg_info {
  * @ATH5K_DEBUG_DUMP_TX: print transmit skb content
  * @ATH5K_DEBUG_DUMPMODES: dump modes
  * @ATH5K_DEBUG_TRACE: trace function calls
- * @ATH5K_DEBUG_FATAL: fatal errors
  * @ATH5K_DEBUG_ANY: show at any debug level
  *
  * The debug level is used to control the amount and type of debugging=
 output
@@ -115,15 +113,13 @@ enum ath5k_debug_level {
 	ATH5K_DEBUG_MODE	=3D 0x00000004,
 	ATH5K_DEBUG_XMIT	=3D 0x00000008,
 	ATH5K_DEBUG_BEACON	=3D 0x00000010,
-	ATH5K_DEBUG_BEACON_PROC	=3D 0x00000020,
-	ATH5K_DEBUG_CALIBRATE	=3D 0x00000100,
-	ATH5K_DEBUG_TXPOWER	=3D 0x00000200,
-	ATH5K_DEBUG_LED		=3D 0x00000400,
-	ATH5K_DEBUG_DUMP_RX	=3D 0x00001000,
-	ATH5K_DEBUG_DUMP_TX	=3D 0x00002000,
-	ATH5K_DEBUG_DUMPMODES	=3D 0x00004000,
-	ATH5K_DEBUG_TRACE	=3D 0x00010000,
-	ATH5K_DEBUG_FATAL	=3D 0x80000000,
+	ATH5K_DEBUG_CALIBRATE	=3D 0x00000020,
+	ATH5K_DEBUG_TXPOWER	=3D 0x00000040,
+	ATH5K_DEBUG_LED		=3D 0x00000080,
+	ATH5K_DEBUG_DUMP_RX	=3D 0x00000100,
+	ATH5K_DEBUG_DUMP_TX	=3D 0x00000200,
+	ATH5K_DEBUG_DUMPMODES	=3D 0x00000400,
+	ATH5K_DEBUG_TRACE	=3D 0x00001000,
 	ATH5K_DEBUG_ANY		=3D 0xffffffff
 };
=20
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/=
dma.c
index 3e73d2a..8a708b7 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -1114,7 +1114,7 @@ static int dma_tx_fragment(struct b43_dmaring *ri=
ng,
 {
 	const struct b43_dma_ops *ops =3D ring->ops;
 	u8 *header;
-	int slot;
+	int slot, old_top_slot, old_used_slots;
 	int err;
 	struct b43_dmadesc_generic *desc;
 	struct b43_dmadesc_meta *meta;
@@ -1126,6 +1126,9 @@ static int dma_tx_fragment(struct b43_dmaring *ri=
ng,
 #define SLOTS_PER_PACKET  2
 	B43_WARN_ON(skb_shinfo(skb)->nr_frags);
=20
+	old_top_slot =3D ring->current_slot;
+	old_used_slots =3D ring->used_slots;
+
 	/* Get a slot for the header. */
 	slot =3D request_slot(ring);
 	desc =3D ops->idx2desc(ring, slot, &meta_hdr);
@@ -1133,13 +1136,21 @@ static int dma_tx_fragment(struct b43_dmaring *=
ring,
=20
 	header =3D &(ring->txhdr_cache[slot * hdrsize]);
 	cookie =3D generate_cookie(ring, slot);
-	b43_generate_txhdr(ring->dev, header,
-			   skb->data, skb->len, ctl, cookie);
+	err =3D b43_generate_txhdr(ring->dev, header,
+				 skb->data, skb->len, ctl, cookie);
+	if (unlikely(err)) {
+		ring->current_slot =3D old_top_slot;
+		ring->used_slots =3D old_used_slots;
+		return err;
+	}
=20
 	meta_hdr->dmaaddr =3D map_descbuffer(ring, (unsigned char *)header,
 					   hdrsize, 1);
-	if (dma_mapping_error(meta_hdr->dmaaddr))
+	if (dma_mapping_error(meta_hdr->dmaaddr)) {
+		ring->current_slot =3D old_top_slot;
+		ring->used_slots =3D old_used_slots;
 		return -EIO;
+	}
 	ops->fill_descriptor(ring, desc, meta_hdr->dmaaddr,
 			     hdrsize, 1, 0, 0);
=20
@@ -1157,6 +1168,8 @@ static int dma_tx_fragment(struct b43_dmaring *ri=
ng,
 	if (dma_mapping_error(meta->dmaaddr)) {
 		bounce_skb =3D __dev_alloc_skb(skb->len, GFP_ATOMIC | GFP_DMA);
 		if (!bounce_skb) {
+			ring->current_slot =3D old_top_slot;
+			ring->used_slots =3D old_used_slots;
 			err =3D -ENOMEM;
 			goto out_unmap_hdr;
 		}
@@ -1167,6 +1180,8 @@ static int dma_tx_fragment(struct b43_dmaring *ri=
ng,
 		meta->skb =3D skb;
 		meta->dmaaddr =3D map_descbuffer(ring, skb->data, skb->len, 1);
 		if (dma_mapping_error(meta->dmaaddr)) {
+			ring->current_slot =3D old_top_slot;
+			ring->used_slots =3D old_used_slots;
 			err =3D -EIO;
 			goto out_free_bounce;
 		}
@@ -1252,6 +1267,13 @@ int b43_dma_tx(struct b43_wldev *dev,
 	B43_WARN_ON(ring->stopped);
=20
 	err =3D dma_tx_fragment(ring, skb, ctl);
+	if (unlikely(err =3D=3D -ENOKEY)) {
+		/* Drop this packet, as we don't have the encryption key
+		 * anymore and must not transmit it unencrypted. */
+		dev_kfree_skb_any(skb);
+		err =3D 0;
+		goto out_unlock;
+	}
 	if (unlikely(err)) {
 		b43err(dev->wl, "DMA tx mapping failure\n");
 		goto out_unlock;
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43=
/main.c
index 88d2c15..64c154d 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -3532,8 +3532,6 @@ static int b43_wireless_core_init(struct b43_wlde=
v *dev)
 	b43_bluetooth_coext_enable(dev);
=20
 	ssb_bus_powerup(bus, 1);	/* Enable dynamic PCTL */
-	memset(wl->bssid, 0, ETH_ALEN);
-	memset(wl->mac_addr, 0, ETH_ALEN);
 	b43_upload_card_macaddress(dev);
 	b43_security_init(dev);
 	b43_rng_init(wl);
@@ -3630,6 +3628,15 @@ static int b43_op_start(struct ieee80211_hw *hw)
 	struct b43_wldev *dev =3D wl->current_dev;
 	int did_init =3D 0;
 	int err =3D 0;
+	bool do_rfkill_exit =3D 0;
+
+	/* Kill all old instance specific information to make sure
+	 * the card won't use it in the short timeframe between start
+	 * and mac80211 reconfiguring it. */
+	memset(wl->bssid, 0, ETH_ALEN);
+	memset(wl->mac_addr, 0, ETH_ALEN);
+	wl->filter_flags =3D 0;
+	wl->radiotap_enabled =3D 0;
=20
 	/* First register RFkill.
 	 * LEDs that are registered later depend on it. */
@@ -3639,8 +3646,10 @@ static int b43_op_start(struct ieee80211_hw *hw)
=20
 	if (b43_status(dev) < B43_STAT_INITIALIZED) {
 		err =3D b43_wireless_core_init(dev);
-		if (err)
+		if (err) {
+			do_rfkill_exit =3D 1;
 			goto out_mutex_unlock;
+		}
 		did_init =3D 1;
 	}
=20
@@ -3649,6 +3658,7 @@ static int b43_op_start(struct ieee80211_hw *hw)
 		if (err) {
 			if (did_init)
 				b43_wireless_core_exit(dev);
+			do_rfkill_exit =3D 1;
 			goto out_mutex_unlock;
 		}
 	}
@@ -3656,6 +3666,9 @@ static int b43_op_start(struct ieee80211_hw *hw)
  out_mutex_unlock:
 	mutex_unlock(&wl->mutex);
=20
+	if (do_rfkill_exit)
+		b43_rfkill_exit(dev);
+
 	return err;
 }
=20
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43=
/xmit.c
index 3fc53e8..7caa26e 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -178,12 +178,12 @@ static u8 b43_calc_fallback_rate(u8 bitrate)
 }
=20
 /* Generate a TX data header. */
-void b43_generate_txhdr(struct b43_wldev *dev,
-			u8 *_txhdr,
-			const unsigned char *fragment_data,
-			unsigned int fragment_len,
-			const struct ieee80211_tx_control *txctl,
-			u16 cookie)
+int b43_generate_txhdr(struct b43_wldev *dev,
+		       u8 *_txhdr,
+		       const unsigned char *fragment_data,
+		       unsigned int fragment_len,
+		       const struct ieee80211_tx_control *txctl,
+		       u16 cookie)
 {
 	struct b43_txhdr *txhdr =3D (struct b43_txhdr *)_txhdr;
 	const struct b43_phy *phy =3D &dev->phy;
@@ -237,7 +237,15 @@ void b43_generate_txhdr(struct b43_wldev *dev,
=20
 		B43_WARN_ON(key_idx >=3D dev->max_nr_keys);
 		key =3D &(dev->key[key_idx]);
-		B43_WARN_ON(!key->keyconf);
+
+		if (unlikely(!key->keyconf)) {
+			/* This key is invalid. This might only happen
+			 * in a short timeframe after machine resume before
+			 * we were able to reconfigure keys.
+			 * Drop this packet completely. Do not transmit it
+			 * unencrypted to avoid leaking information. */
+			return -ENOKEY;
+		}
=20
 		/* Hardware appends ICV. */
 		plcp_fragment_len +=3D txctl->icv_len;
@@ -408,6 +416,7 @@ void b43_generate_txhdr(struct b43_wldev *dev,
 	txhdr->phy_ctl =3D cpu_to_le16(phy_ctl);
 	txhdr->extra_ft =3D extra_ft;
=20
+	return 0;
 }
=20
 static s8 b43_rssi_postprocess(struct b43_wldev *dev,
diff --git a/drivers/net/wireless/b43/xmit.h b/drivers/net/wireless/b43=
/xmit.h
index ca2a2ab..4176503 100644
--- a/drivers/net/wireless/b43/xmit.h
+++ b/drivers/net/wireless/b43/xmit.h
@@ -174,11 +174,11 @@ size_t b43_txhdr_size(struct b43_wldev *dev)
 }
=20
=20
-void b43_generate_txhdr(struct b43_wldev *dev,
-			u8 * txhdr,
-			const unsigned char *fragment_data,
-			unsigned int fragment_len,
-			const struct ieee80211_tx_control *txctl, u16 cookie);
+int b43_generate_txhdr(struct b43_wldev *dev,
+		       u8 * txhdr,
+		       const unsigned char *fragment_data,
+		       unsigned int fragment_len,
+		       const struct ieee80211_tx_control *txctl, u16 cookie);
=20
 /* Transmit Status */
 struct b43_txstatus {
diff --git a/drivers/net/wireless/b43legacy/b43legacy.h b/drivers/net/w=
ireless/b43legacy/b43legacy.h
index 93419ad..c80edd2 100644
--- a/drivers/net/wireless/b43legacy/b43legacy.h
+++ b/drivers/net/wireless/b43legacy/b43legacy.h
@@ -23,7 +23,7 @@
 #include "phy.h"
=20
=20
-#define B43legacy_IRQWAIT_MAX_RETRIES	100
+#define B43legacy_IRQWAIT_MAX_RETRIES	20
=20
 #define B43legacy_RX_MAX_SSI		60 /* best guess at max ssi */
=20
@@ -40,9 +40,8 @@
 #define B43legacy_MMIO_DMA4_IRQ_MASK	0x44
 #define B43legacy_MMIO_DMA5_REASON	0x48
 #define B43legacy_MMIO_DMA5_IRQ_MASK	0x4C
-#define B43legacy_MMIO_MACCTL		0x120
-#define B43legacy_MMIO_STATUS_BITFIELD	0x120
-#define B43legacy_MMIO_STATUS2_BITFIELD	0x124
+#define B43legacy_MMIO_MACCTL		0x120	/* MAC control */
+#define B43legacy_MMIO_MACCMD		0x124	/* MAC command */
 #define B43legacy_MMIO_GEN_IRQ_REASON	0x128
 #define B43legacy_MMIO_GEN_IRQ_MASK	0x12C
 #define B43legacy_MMIO_RAM_CONTROL	0x130
@@ -177,31 +176,25 @@
 #define B43legacy_RADIOCTL_ID		0x01
=20
 /* MAC Control bitfield */
+#define B43legacy_MACCTL_ENABLED	0x00000001 /* MAC Enabled */
+#define B43legacy_MACCTL_PSM_RUN	0x00000002 /* Run Microcode */
+#define B43legacy_MACCTL_PSM_JMP0	0x00000004 /* Microcode jump to 0 */
+#define B43legacy_MACCTL_SHM_ENABLED	0x00000100 /* SHM Enabled */
 #define B43legacy_MACCTL_IHR_ENABLED	0x00000400 /* IHR Region Enabled =
*/
+#define B43legacy_MACCTL_BE		0x00010000 /* Big Endian mode */
 #define B43legacy_MACCTL_INFRA		0x00020000 /* Infrastructure mode */
 #define B43legacy_MACCTL_AP		0x00040000 /* AccessPoint mode */
+#define B43legacy_MACCTL_RADIOLOCK	0x00080000 /* Radio lock */
 #define B43legacy_MACCTL_BEACPROMISC	0x00100000 /* Beacon Promiscuous =
*/
 #define B43legacy_MACCTL_KEEP_BADPLCP	0x00200000 /* Keep bad PLCP fram=
es */
 #define B43legacy_MACCTL_KEEP_CTL	0x00400000 /* Keep control frames */
 #define B43legacy_MACCTL_KEEP_BAD	0x00800000 /* Keep bad frames (FCS) =
*/
 #define B43legacy_MACCTL_PROMISC	0x01000000 /* Promiscuous mode */
+#define B43legacy_MACCTL_HWPS		0x02000000 /* Hardware Power Saving */
+#define B43legacy_MACCTL_AWAKE		0x04000000 /* Device is awake */
+#define B43legacy_MACCTL_TBTTHOLD	0x10000000 /* TBTT Hold */
 #define B43legacy_MACCTL_GMODE		0x80000000 /* G Mode */
=20
-/* StatusBitField */
-#define B43legacy_SBF_MAC_ENABLED	0x00000001
-#define B43legacy_SBF_CORE_READY	0x00000004
-#define B43legacy_SBF_400		0x00000400 /*FIXME: fix name*/
-#define B43legacy_SBF_XFER_REG_BYTESWAP	0x00010000
-#define B43legacy_SBF_MODE_NOTADHOC	0x00020000
-#define B43legacy_SBF_MODE_AP		0x00040000
-#define B43legacy_SBF_RADIOREG_LOCK	0x00080000
-#define B43legacy_SBF_MODE_MONITOR	0x00400000
-#define B43legacy_SBF_MODE_PROMISC	0x01000000
-#define B43legacy_SBF_PS1		0x02000000
-#define B43legacy_SBF_PS2		0x04000000
-#define B43legacy_SBF_NO_SSID_BCAST	0x08000000
-#define B43legacy_SBF_TIME_UPDATE	0x10000000
-
 /* 802.11 core specific TM State Low flags */
 #define B43legacy_TMSLOW_GMODE		0x20000000 /* G Mode Enable */
 #define B43legacy_TMSLOW_PLLREFSEL	0x00200000 /* PLL Freq Ref Select *=
/
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wirele=
ss/b43legacy/main.c
index 4ed4243..aa20d5d 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -225,8 +225,8 @@ static void b43legacy_ram_write(struct b43legacy_wl=
dev *dev, u16 offset,
=20
 	B43legacy_WARN_ON(offset % 4 !=3D 0);
=20
-	status =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
-	if (status & B43legacy_SBF_XFER_REG_BYTESWAP)
+	status =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	if (status & B43legacy_MACCTL_BE)
 		val =3D swab32(val);
=20
 	b43legacy_write32(dev, B43legacy_MMIO_RAM_CONTROL, offset);
@@ -434,9 +434,9 @@ static void b43legacy_time_lock(struct b43legacy_wl=
dev *dev)
 {
 	u32 status;
=20
-	status =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
-	status |=3D B43legacy_SBF_TIME_UPDATE;
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, status);
+	status =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	status |=3D B43legacy_MACCTL_TBTTHOLD;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, status);
 	mmiowb();
 }
=20
@@ -444,9 +444,9 @@ static void b43legacy_time_unlock(struct b43legacy_=
wldev *dev)
 {
 	u32 status;
=20
-	status =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
-	status &=3D ~B43legacy_SBF_TIME_UPDATE;
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, status);
+	status =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	status &=3D ~B43legacy_MACCTL_TBTTHOLD;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, status);
 }
=20
 static void b43legacy_tsf_write_locked(struct b43legacy_wldev *dev, u6=
4 tsf)
@@ -647,7 +647,7 @@ void b43legacy_dummy_transmission(struct b43legacy_=
wldev *dev)
 		b43legacy_ram_write(dev, i * 4, buffer[i]);
=20
 	/* dummy read follows */
-	b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
+	b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
=20
 	b43legacy_write16(dev, 0x0568, 0x0000);
 	b43legacy_write16(dev, 0x07C0, 0x0000);
@@ -794,9 +794,9 @@ static void b43legacy_jssi_write(struct b43legacy_w=
ldev *dev, u32 jssi)
 static void b43legacy_generate_noise_sample(struct b43legacy_wldev *de=
v)
 {
 	b43legacy_jssi_write(dev, 0x7F7F7F7F);
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS2_BITFIELD,
+	b43legacy_write32(dev, B43legacy_MMIO_MACCMD,
 			  b43legacy_read32(dev,
-			  B43legacy_MMIO_STATUS2_BITFIELD)
+			  B43legacy_MMIO_MACCMD)
 			  | (1 << 4));
 	B43legacy_WARN_ON(dev->noisecalc.channel_at_start !=3D
 			    dev->phy.channel);
@@ -895,8 +895,8 @@ static void handle_irq_atim_end(struct b43legacy_wl=
dev *dev)
 {
 	if (!dev->reg124_set_0x4) /*FIXME rename this variable*/
 		return;
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS2_BITFIELD,
-			  b43legacy_read32(dev, B43legacy_MMIO_STATUS2_BITFIELD)
+	b43legacy_write32(dev, B43legacy_MMIO_MACCMD,
+			  b43legacy_read32(dev, B43legacy_MMIO_MACCMD)
 			  | 0x4);
 }
=20
@@ -1106,9 +1106,9 @@ static void b43legacy_update_templates(struct b43=
legacy_wldev *dev)
 	b43legacy_write_probe_resp_template(dev, 0x268, 0x4A,
 					    B43legacy_CCK_RATE_11MB);
=20
-	status =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS2_BITFIELD);
+	status =3D b43legacy_read32(dev, B43legacy_MMIO_MACCMD);
 	status |=3D 0x03;
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS2_BITFIELD, status);
+	b43legacy_write32(dev, B43legacy_MMIO_MACCMD, status);
 }
=20
 static void b43legacy_refresh_templates(struct b43legacy_wldev *dev,
@@ -1166,7 +1166,7 @@ static void handle_irq_beacon(struct b43legacy_wl=
dev *dev)
 		return;
=20
 	dev->irq_savedstate &=3D ~B43legacy_IRQ_BEACON;
-	status =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS2_BITFIELD);
+	status =3D b43legacy_read32(dev, B43legacy_MMIO_MACCMD);
=20
 	if (!dev->cached_beacon || ((status & 0x1) && (status & 0x2))) {
 		/* ACK beacon IRQ. */
@@ -1182,14 +1182,14 @@ static void handle_irq_beacon(struct b43legacy_=
wldev *dev)
 		b43legacy_write_beacon_template(dev, 0x68, 0x18,
 						B43legacy_CCK_RATE_1MB);
 		status |=3D 0x1;
-		b43legacy_write32(dev, B43legacy_MMIO_STATUS2_BITFIELD,
+		b43legacy_write32(dev, B43legacy_MMIO_MACCMD,
 				  status);
 	}
 	if (!(status & 0x2)) {
 		b43legacy_write_beacon_template(dev, 0x468, 0x1A,
 						B43legacy_CCK_RATE_1MB);
 		status |=3D 0x2;
-		b43legacy_write32(dev, B43legacy_MMIO_STATUS2_BITFIELD,
+		b43legacy_write32(dev, B43legacy_MMIO_MACCMD,
 				  status);
 	}
 }
@@ -1548,9 +1548,20 @@ static int b43legacy_upload_microcode(struct b43=
legacy_wldev *dev)
 	u16 fwpatch;
 	u16 fwdate;
 	u16 fwtime;
-	u32 tmp;
+	u32 tmp, macctl;
 	int err =3D 0;
=20
+	/* Jump the microcode PSM to offset 0 */
+	macctl =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	B43legacy_WARN_ON(macctl & B43legacy_MACCTL_PSM_RUN);
+	macctl |=3D B43legacy_MACCTL_PSM_JMP0;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, macctl);
+	/* Zero out all microcode PSM registers and shared memory. */
+	for (i =3D 0; i < 64; i++)
+		b43legacy_shm_write16(dev, B43legacy_SHM_WIRELESS, i, 0);
+	for (i =3D 0; i < 4096; i +=3D 2)
+		b43legacy_shm_write16(dev, B43legacy_SHM_SHARED, i, 0);
+
 	/* Upload Microcode. */
 	data =3D (__be32 *) (dev->fw.ucode->data + hdr_len);
 	len =3D (dev->fw.ucode->size - hdr_len) / sizeof(__be32);
@@ -1581,7 +1592,12 @@ static int b43legacy_upload_microcode(struct b43=
legacy_wldev *dev)
=20
 	b43legacy_write32(dev, B43legacy_MMIO_GEN_IRQ_REASON,
 			  B43legacy_IRQ_ALL);
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, 0x00020402);
+
+	/* Start the microcode PSM */
+	macctl =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	macctl &=3D ~B43legacy_MACCTL_PSM_JMP0;
+	macctl |=3D B43legacy_MACCTL_PSM_RUN;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, macctl);
=20
 	/* Wait for the microcode to load and respond */
 	i =3D 0;
@@ -1594,9 +1610,13 @@ static int b43legacy_upload_microcode(struct b43=
legacy_wldev *dev)
 			b43legacyerr(dev->wl, "Microcode not responding\n");
 			b43legacy_print_fw_helptext(dev->wl);
 			err =3D -ENODEV;
-			goto out;
+			goto error;
+		}
+		msleep_interruptible(50);
+		if (signal_pending(current)) {
+			err =3D -EINTR;
+			goto error;
 		}
-		udelay(10);
 	}
 	/* dummy read follows */
 	b43legacy_read32(dev, B43legacy_MMIO_GEN_IRQ_REASON);
@@ -1617,9 +1637,8 @@ static int b43legacy_upload_microcode(struct b43l=
egacy_wldev *dev)
 			     " is supported. You must change your firmware"
 			     " files.\n");
 		b43legacy_print_fw_helptext(dev->wl);
-		b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, 0);
 		err =3D -EOPNOTSUPP;
-		goto out;
+		goto error;
 	}
 	b43legacydbg(dev->wl, "Loading firmware version 0x%X, patch level %u =
"
 	       "(20%.2i-%.2i-%.2i %.2i:%.2i:%.2i)\n", fwrev, fwpatch,
@@ -1629,7 +1648,14 @@ static int b43legacy_upload_microcode(struct b43=
legacy_wldev *dev)
 	dev->fw.rev =3D fwrev;
 	dev->fw.patch =3D fwpatch;
=20
-out:
+	return 0;
+
+error:
+	macctl =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	macctl &=3D ~B43legacy_MACCTL_PSM_RUN;
+	macctl |=3D B43legacy_MACCTL_PSM_JMP0;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, macctl);
+
 	return err;
 }
=20
@@ -1736,9 +1762,9 @@ static int b43legacy_gpio_init(struct b43legacy_w=
ldev *dev)
 	u32 mask;
 	u32 set;
=20
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD,
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL,
 			  b43legacy_read32(dev,
-			  B43legacy_MMIO_STATUS_BITFIELD)
+			  B43legacy_MMIO_MACCTL)
 			  & 0xFFFF3FFF);
=20
 	b43legacy_write16(dev, B43legacy_MMIO_GPIO_MASK,
@@ -1798,14 +1824,14 @@ void b43legacy_mac_enable(struct b43legacy_wlde=
v *dev)
 	B43legacy_WARN_ON(dev->mac_suspended < 0);
 	B43legacy_WARN_ON(irqs_disabled());
 	if (dev->mac_suspended =3D=3D 0) {
-		b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD,
+		b43legacy_write32(dev, B43legacy_MMIO_MACCTL,
 				  b43legacy_read32(dev,
-				  B43legacy_MMIO_STATUS_BITFIELD)
-				  | B43legacy_SBF_MAC_ENABLED);
+				  B43legacy_MMIO_MACCTL)
+				  | B43legacy_MACCTL_ENABLED);
 		b43legacy_write32(dev, B43legacy_MMIO_GEN_IRQ_REASON,
 				  B43legacy_IRQ_MAC_SUSPENDED);
 		/* the next two are dummy reads */
-		b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
+		b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
 		b43legacy_read32(dev, B43legacy_MMIO_GEN_IRQ_REASON);
 		b43legacy_power_saving_ctl_bits(dev, -1, -1);
=20
@@ -1836,10 +1862,10 @@ void b43legacy_mac_suspend(struct b43legacy_wld=
ev *dev)
 		dev->irq_savedstate =3D tmp;
=20
 		b43legacy_power_saving_ctl_bits(dev, -1, 1);
-		b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD,
+		b43legacy_write32(dev, B43legacy_MMIO_MACCTL,
 				  b43legacy_read32(dev,
-				  B43legacy_MMIO_STATUS_BITFIELD)
-				  & ~B43legacy_SBF_MAC_ENABLED);
+				  B43legacy_MMIO_MACCTL)
+				  & ~B43legacy_MACCTL_ENABLED);
 		b43legacy_read32(dev, B43legacy_MMIO_GEN_IRQ_REASON);
 		for (i =3D 40; i; i--) {
 			tmp =3D b43legacy_read32(dev,
@@ -2007,12 +2033,15 @@ static int b43legacy_chip_init(struct b43legacy=
_wldev *dev)
 	struct b43legacy_phy *phy =3D &dev->phy;
 	int err;
 	int tmp;
-	u32 value32;
+	u32 value32, macctl;
 	u16 value16;
=20
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD,
-			  B43legacy_SBF_CORE_READY
-			  | B43legacy_SBF_400);
+	/* Initialize the MAC control */
+	macctl =3D B43legacy_MACCTL_IHR_ENABLED | B43legacy_MACCTL_SHM_ENABLE=
D;
+	if (dev->phy.gmode)
+		macctl |=3D B43legacy_MACCTL_GMODE;
+	macctl |=3D B43legacy_MACCTL_INFRA;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, macctl);
=20
 	err =3D b43legacy_request_firmware(dev);
 	if (err)
@@ -2052,12 +2081,12 @@ static int b43legacy_chip_init(struct b43legacy=
_wldev *dev)
 	if (dev->dev->id.revision < 5)
 		b43legacy_write32(dev, 0x010C, 0x01000000);
=20
-	value32 =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
-	value32 &=3D ~B43legacy_SBF_MODE_NOTADHOC;
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, value32);
-	value32 =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
-	value32 |=3D B43legacy_SBF_MODE_NOTADHOC;
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, value32);
+	value32 =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	value32 &=3D ~B43legacy_MACCTL_INFRA;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, value32);
+	value32 =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	value32 |=3D B43legacy_MACCTL_INFRA;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, value32);
=20
 	if (b43legacy_using_pio(dev)) {
 		b43legacy_write32(dev, 0x0210, 0x00000100);
@@ -2951,12 +2980,19 @@ static void b43legacy_wireless_core_exit(struct=
 b43legacy_wldev *dev)
 {
 	struct b43legacy_wl *wl =3D dev->wl;
 	struct b43legacy_phy *phy =3D &dev->phy;
+	u32 macctl;
=20
 	B43legacy_WARN_ON(b43legacy_status(dev) > B43legacy_STAT_INITIALIZED)=
;
 	if (b43legacy_status(dev) !=3D B43legacy_STAT_INITIALIZED)
 		return;
 	b43legacy_set_status(dev, B43legacy_STAT_UNINIT);
=20
+	/* Stop the microcode PSM. */
+	macctl =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	macctl &=3D ~B43legacy_MACCTL_PSM_RUN;
+	macctl |=3D B43legacy_MACCTL_PSM_JMP0;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, macctl);
+
 	mutex_unlock(&wl->mutex);
 	/* Must unlock as it would otherwise deadlock. No races here.
 	 * Cancel possibly pending workqueues. */
@@ -3221,6 +3257,7 @@ static int b43legacy_op_start(struct ieee80211_hw=
 *hw)
 	struct b43legacy_wldev *dev =3D wl->current_dev;
 	int did_init =3D 0;
 	int err =3D 0;
+	bool do_rfkill_exit =3D 0;
=20
 	/* First register RFkill.
 	 * LEDs that are registered later depend on it. */
@@ -3230,8 +3267,10 @@ static int b43legacy_op_start(struct ieee80211_h=
w *hw)
=20
 	if (b43legacy_status(dev) < B43legacy_STAT_INITIALIZED) {
 		err =3D b43legacy_wireless_core_init(dev);
-		if (err)
+		if (err) {
+			do_rfkill_exit =3D 1;
 			goto out_mutex_unlock;
+		}
 		did_init =3D 1;
 	}
=20
@@ -3240,6 +3279,7 @@ static int b43legacy_op_start(struct ieee80211_hw=
 *hw)
 		if (err) {
 			if (did_init)
 				b43legacy_wireless_core_exit(dev);
+			do_rfkill_exit =3D 1;
 			goto out_mutex_unlock;
 		}
 	}
@@ -3247,6 +3287,9 @@ static int b43legacy_op_start(struct ieee80211_hw=
 *hw)
 out_mutex_unlock:
 	mutex_unlock(&wl->mutex);
=20
+	if (do_rfkill_exit)
+		b43legacy_rfkill_exit(dev);
+
 	return err;
 }
=20
diff --git a/drivers/net/wireless/b43legacy/phy.c b/drivers/net/wireles=
s/b43legacy/phy.c
index c16febb..8e5c09b 100644
--- a/drivers/net/wireless/b43legacy/phy.c
+++ b/drivers/net/wireless/b43legacy/phy.c
@@ -140,7 +140,7 @@ void b43legacy_phy_calibrate(struct b43legacy_wldev=
 *dev)
 {
 	struct b43legacy_phy *phy =3D &dev->phy;
=20
-	b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD); /* Dummy read.=
 */
+	b43legacy_read32(dev, B43legacy_MMIO_MACCTL); /* Dummy read. */
 	if (phy->calibrated)
 		return;
 	if (phy->type =3D=3D B43legacy_PHYTYPE_G && phy->rev =3D=3D 1) {
@@ -2231,16 +2231,16 @@ bit26 =3D 1;
 		 *	or the latest PS-Poll packet sent was successful,
 		 *	set bit26  */
 	}
-	status =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
+	status =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
 	if (bit25)
-		status |=3D B43legacy_SBF_PS1;
+		status |=3D B43legacy_MACCTL_HWPS;
 	else
-		status &=3D ~B43legacy_SBF_PS1;
+		status &=3D ~B43legacy_MACCTL_HWPS;
 	if (bit26)
-		status |=3D B43legacy_SBF_PS2;
+		status |=3D B43legacy_MACCTL_AWAKE;
 	else
-		status &=3D ~B43legacy_SBF_PS2;
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, status);
+		status &=3D ~B43legacy_MACCTL_AWAKE;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, status);
 	if (bit26 && dev->dev->id.revision >=3D 5) {
 		for (i =3D 0; i < 100; i++) {
 			if (b43legacy_shm_read32(dev, B43legacy_SHM_SHARED,
diff --git a/drivers/net/wireless/b43legacy/pio.c b/drivers/net/wireles=
s/b43legacy/pio.c
index de843ac..e4f4c5c 100644
--- a/drivers/net/wireless/b43legacy/pio.c
+++ b/drivers/net/wireless/b43legacy/pio.c
@@ -334,9 +334,9 @@ struct b43legacy_pioqueue *b43legacy_setup_pioqueue=
(struct b43legacy_wldev *dev,
 	tasklet_init(&queue->txtask, tx_tasklet,
 		     (unsigned long)queue);
=20
-	value =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
-	value &=3D ~B43legacy_SBF_XFER_REG_BYTESWAP;
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, value);
+	value =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	value &=3D ~B43legacy_MACCTL_BE;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, value);
=20
 	qsize =3D b43legacy_read16(dev, queue->mmio_base
 				 + B43legacy_PIO_TXQBUFSIZE);
diff --git a/drivers/net/wireless/b43legacy/radio.c b/drivers/net/wirel=
ess/b43legacy/radio.c
index 318a270..955832e 100644
--- a/drivers/net/wireless/b43legacy/radio.c
+++ b/drivers/net/wireless/b43legacy/radio.c
@@ -91,10 +91,10 @@ void b43legacy_radio_lock(struct b43legacy_wldev *d=
ev)
 {
 	u32 status;
=20
-	status =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
-	B43legacy_WARN_ON(status & B43legacy_SBF_RADIOREG_LOCK);
-	status |=3D B43legacy_SBF_RADIOREG_LOCK;
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, status);
+	status =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	B43legacy_WARN_ON(status & B43legacy_MACCTL_RADIOLOCK);
+	status |=3D B43legacy_MACCTL_RADIOLOCK;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, status);
 	mmiowb();
 	udelay(10);
 }
@@ -104,10 +104,10 @@ void b43legacy_radio_unlock(struct b43legacy_wlde=
v *dev)
 	u32 status;
=20
 	b43legacy_read16(dev, B43legacy_MMIO_PHY_VER); /* dummy read */
-	status =3D b43legacy_read32(dev, B43legacy_MMIO_STATUS_BITFIELD);
-	B43legacy_WARN_ON(!(status & B43legacy_SBF_RADIOREG_LOCK));
-	status &=3D ~B43legacy_SBF_RADIOREG_LOCK;
-	b43legacy_write32(dev, B43legacy_MMIO_STATUS_BITFIELD, status);
+	status =3D b43legacy_read32(dev, B43legacy_MMIO_MACCTL);
+	B43legacy_WARN_ON(!(status & B43legacy_MACCTL_RADIOLOCK));
+	status &=3D ~B43legacy_MACCTL_RADIOLOCK;
+	b43legacy_write32(dev, B43legacy_MMIO_MACCTL, status);
 	mmiowb();
 }
=20
diff --git a/drivers/net/wireless/hostap/hostap_80211.h b/drivers/net/w=
ireless/hostap/hostap_80211.h
index d6b9362..3694b1e 100644
--- a/drivers/net/wireless/hostap/hostap_80211.h
+++ b/drivers/net/wireless/hostap/hostap_80211.h
@@ -71,11 +71,6 @@ struct hostap_80211_rx_status {
 	u16 rate; /* in 100 kbps */
 };
=20
-
-void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
-		     struct hostap_80211_rx_status *rx_stats);
-
-
 /* prism2_rx_80211 'type' argument */
 enum {
 	PRISM2_RX_MONITOR, PRISM2_RX_MGMT, PRISM2_RX_NON_ASSOC,
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wire=
less/hostap/hostap_cs.c
index 0759380..437a9bc 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -891,6 +891,9 @@ static struct pcmcia_device_id hostap_cs_ids[] =3D =
{
 	PCMCIA_DEVICE_PROD_ID123(
 		"The Linksys Group, Inc.", "Wireless Network CF Card", "ISL37300P",
 		0xa5f472c2, 0x9c05598d, 0xc9049a39),
+	PCMCIA_DEVICE_PROD_ID123(
+		"Wireless LAN" , "11Mbps PC Card", "Version 01.02",
+		0x4b8870ff, 0x70e946d1, 0x4b74baa0),
 	PCMCIA_DEVICE_NULL
 };
 MODULE_DEVICE_TABLE(pcmcia, hostap_cs_ids);
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-hw.h b/drivers/net/w=
ireless/iwlwifi/iwl-3945-hw.h
index 6e01873..571815d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-hw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-hw.h
@@ -373,7 +373,7 @@ struct iwl3945_eeprom {
 #define CSR_INT_BIT_HW_ERR       (1 << 29) /* DMA hardware error FH_IN=
T[31] */
 #define CSR_INT_BIT_DNLD         (1 << 28) /* uCode Download */
 #define CSR_INT_BIT_FH_TX        (1 << 27) /* Tx DMA FH_INT[1:0] */
-#define CSR_INT_BIT_MAC_CLK_ACTV (1 << 26) /* NIC controller's clock t=
oggled on/off */
+#define CSR_INT_BIT_SCD          (1 << 26) /* TXQ pointer advanced */
 #define CSR_INT_BIT_SW_ERR       (1 << 25) /* uCode error */
 #define CSR_INT_BIT_RF_KILL      (1 << 7)  /* HW RFKILL switch GP_CNTR=
L[27] toggled */
 #define CSR_INT_BIT_CT_KILL      (1 << 6)  /* Critical temp (chip too =
hot) rfkill */
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wire=
less/iwlwifi/iwl-3945.c
index 76c4ed1..4fdeb53 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -2369,18 +2369,4 @@ struct pci_device_id iwl3945_hw_card_ids[] =3D {
 	{0}
 };
=20
-/*
- * Clear the OWNER_MSK, to establish driver (instead of uCode running =
on
- * embedded controller) as EEPROM reader; each read is a series of pul=
ses
- * to/from the EEPROM chip, not a single event, so even reads could co=
nflict
- * if they weren't arbitrated by some ownership mechanism.  Here, the =
driver
- * simply claims ownership, which should be safe when this function is=
 called
- * (i.e. before loading uCode!).
- */
-inline int iwl3945_eeprom_acquire_semaphore(struct iwl3945_priv *priv)
-{
-	_iwl3945_clear_bit(priv, CSR_EEPROM_GP, CSR_EEPROM_GP_IF_OWNER_MSK);
-	return 0;
-}
-
 MODULE_DEVICE_TABLE(pci, iwl3945_hw_card_ids);
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.h b/drivers/net/wire=
less/iwlwifi/iwl-3945.h
index 20b925f..1da14f9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.h
@@ -671,7 +671,6 @@ extern int iwl3945_hw_channel_switch(struct iwl3945=
_priv *priv, u16 channel);
 /*
  * Forward declare iwl-3945.c functions for iwl-base.c
  */
-extern int iwl3945_eeprom_acquire_semaphore(struct iwl3945_priv *priv)=
;
 extern __le32 iwl3945_get_antenna_flags(const struct iwl3945_priv *pri=
v);
 extern int iwl3945_init_hw_rate_table(struct iwl3945_priv *priv);
 extern void iwl3945_reg_txpower_periodic(struct iwl3945_priv *priv);
@@ -791,7 +790,6 @@ struct iwl3945_priv {
 	u16 active_rate_basic;
=20
 	u8 call_post_assoc_from_beacon;
-	u8 assoc_station_added;
 	/* Rate scaling data */
 	s8 data_retry_limit;
 	u8 retry_rate;
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-hw.h b/drivers/net/w=
ireless/iwlwifi/iwl-4965-hw.h
index ff71c09..ffe1e9d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965-hw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-4965-hw.h
@@ -465,7 +465,7 @@ struct iwl4965_eeprom {
 #define CSR_INT_BIT_HW_ERR       (1 << 29) /* DMA hardware error FH_IN=
T[31] */
 #define CSR_INT_BIT_DNLD         (1 << 28) /* uCode Download */
 #define CSR_INT_BIT_FH_TX        (1 << 27) /* Tx DMA FH_INT[1:0] */
-#define CSR_INT_BIT_MAC_CLK_ACTV (1 << 26) /* NIC controller's clock t=
oggled on/off */
+#define CSR_INT_BIT_SCD          (1 << 26) /* TXQ pointer advanced */
 #define CSR_INT_BIT_SW_ERR       (1 << 25) /* uCode error */
 #define CSR_INT_BIT_RF_KILL      (1 << 7)  /* HW RFKILL switch GP_CNTR=
L[27] toggled */
 #define CSR_INT_BIT_CT_KILL      (1 << 6)  /* Critical temp (chip too =
hot) rfkill */
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wire=
less/iwlwifi/iwl-4965.c
index 04db34b..569347f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -4961,11 +4961,4 @@ int iwl4965_eeprom_acquire_semaphore(struct iwl4=
965_priv *priv)
 	return rc;
 }
=20
-inline void iwl4965_eeprom_release_semaphore(struct iwl4965_priv *priv=
)
-{
-	iwl4965_clear_bit(priv, CSR_HW_IF_CONFIG_REG,
-		CSR_HW_IF_CONFIG_REG_BIT_EEPROM_OWN_SEM);
-}
-
-
 MODULE_DEVICE_TABLE(pci, iwl4965_hw_card_ids);
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.h b/drivers/net/wire=
less/iwlwifi/iwl-4965.h
index 78bc148..9cb82be 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.h
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.h
@@ -750,7 +750,6 @@ struct iwl4965_priv;
  * Forward declare iwl-4965.c functions for iwl-base.c
  */
 extern int iwl4965_eeprom_acquire_semaphore(struct iwl4965_priv *priv)=
;
-extern void iwl4965_eeprom_release_semaphore(struct iwl4965_priv *priv=
);
=20
 extern int iwl4965_tx_queue_update_wr_ptr(struct iwl4965_priv *priv,
 					  struct iwl4965_tx_queue *txq,
diff --git a/drivers/net/wireless/iwlwifi/iwl-helpers.h b/drivers/net/w=
ireless/iwlwifi/iwl-helpers.h
index cd2eb18..cb009f4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-helpers.h
+++ b/drivers/net/wireless/iwlwifi/iwl-helpers.h
@@ -246,10 +246,10 @@ static inline int iwl_check_bits(unsigned long fi=
eld, unsigned long mask)
 static inline unsigned long elapsed_jiffies(unsigned long start,
 					    unsigned long end)
 {
-	if (end > start)
+	if (end >=3D start)
 		return end - start;
=20
-	return end + (MAX_JIFFY_OFFSET - start);
+	return end + (MAX_JIFFY_OFFSET - start) + 1;
 }
=20
 static inline u8 iwl_get_dma_hi_address(dma_addr_t addr)
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/=
wireless/iwlwifi/iwl3945-base.c
index 748ac12..33239f1 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -1557,6 +1557,20 @@ static void get_eeprom_mac(struct iwl3945_priv *=
priv, u8 *mac)
 	memcpy(mac, priv->eeprom.mac_address, 6);
 }
=20
+/*
+ * Clear the OWNER_MSK, to establish driver (instead of uCode running =
on
+ * embedded controller) as EEPROM reader; each read is a series of pul=
ses
+ * to/from the EEPROM chip, not a single event, so even reads could co=
nflict
+ * if they weren't arbitrated by some ownership mechanism.  Here, the =
driver
+ * simply claims ownership, which should be safe when this function is=
 called
+ * (i.e. before loading uCode!).
+ */
+static inline int iwl3945_eeprom_acquire_semaphore(struct iwl3945_priv=
 *priv)
+{
+	_iwl3945_clear_bit(priv, CSR_EEPROM_GP, CSR_EEPROM_GP_IF_OWNER_MSK);
+	return 0;
+}
+
 /**
  * iwl3945_eeprom_init - read EEPROM contents
  *
@@ -2792,7 +2806,7 @@ static int iwl3945_tx_skb(struct iwl3945_priv *pr=
iv,
 #endif
=20
 	/* drop all data frame if we are not associated */
-	if (!iwl3945_is_associated(priv) && !priv->assoc_id &&
+	if ((!iwl3945_is_associated(priv) || !priv->assoc_id) &&
 	    ((fc & IEEE80211_FCTL_FTYPE) =3D=3D IEEE80211_FTYPE_DATA)) {
 		IWL_DEBUG_DROP("Dropping - !iwl3945_is_associated\n");
 		goto drop_unlock;
@@ -4745,8 +4759,9 @@ static void iwl3945_irq_tasklet(struct iwl3945_pr=
iv *priv)
 #ifdef CONFIG_IWL3945_DEBUG
 	if (iwl3945_debug_level & (IWL_DL_ISR)) {
 		/* NIC fires this, but we don't use it, redundant with WAKEUP */
-		if (inta & CSR_INT_BIT_MAC_CLK_ACTV)
-			IWL_DEBUG_ISR("Microcode started or stopped.\n");
+		if (inta & CSR_INT_BIT_SCD)
+			IWL_DEBUG_ISR("Scheduler finished to transmit "
+				      "the frame/frames.\n");
=20
 		/* Alive notification via Rx interrupt will do the real work */
 		if (inta & CSR_INT_BIT_ALIVE)
@@ -4754,7 +4769,7 @@ static void iwl3945_irq_tasklet(struct iwl3945_pr=
iv *priv)
 	}
 #endif
 	/* Safely ignore these bits for debug checks below */
-	inta &=3D ~(CSR_INT_BIT_MAC_CLK_ACTV | CSR_INT_BIT_ALIVE);
+	inta &=3D ~(CSR_INT_BIT_SCD | CSR_INT_BIT_ALIVE);
=20
 	/* HW RF KILL switch toggled (4965 only) */
 	if (inta & CSR_INT_BIT_RF_KILL) {
@@ -4890,8 +4905,11 @@ static irqreturn_t iwl3945_isr(int irq, void *da=
ta)
 	IWL_DEBUG_ISR("ISR inta 0x%08x, enabled 0x%08x, fh 0x%08x\n",
 		      inta, inta_mask, inta_fh);
=20
+	inta &=3D ~CSR_INT_BIT_SCD;
+
 	/* iwl3945_irq_tasklet() will service interrupts and re-enable them *=
/
-	tasklet_schedule(&priv->irq_tasklet);
+	if (likely(inta || inta_fh))
+		tasklet_schedule(&priv->irq_tasklet);
 unplugged:
 	spin_unlock(&priv->lock);
=20
@@ -5146,6 +5164,15 @@ static int iwl3945_init_channel_map(struct iwl39=
45_priv *priv)
 	return 0;
 }
=20
+/*
+ * iwl3945_free_channel_map - undo allocations in iwl3945_init_channel=
_map
+ */
+static void iwl3945_free_channel_map(struct iwl3945_priv *priv)
+{
+	kfree(priv->channel_info);
+	priv->channel_count =3D 0;
+}
+
 /* For active scan, listen ACTIVE_DWELL_TIME (msec) on each channel af=
ter
  * sending probe req.  This should be set long enough to hear probe re=
sponses
  * from more than one AP.  */
@@ -5471,6 +5498,17 @@ static int iwl3945_init_geos(struct iwl3945_priv=
 *priv)
 	return 0;
 }
=20
+/*
+ * iwl3945_free_geos - undo allocations in iwl3945_init_geos
+ */
+static void iwl3945_free_geos(struct iwl3945_priv *priv)
+{
+	kfree(priv->modes);
+	kfree(priv->ieee_channels);
+	kfree(priv->ieee_rates);
+	clear_bit(STATUS_GEO_CONFIGURED, &priv->status);
+}
+
 /*********************************************************************=
*********
  *
  * uCode download functions
@@ -6130,15 +6168,6 @@ static void iwl3945_alive_start(struct iwl3945_p=
riv *priv)
 	/* Clear out the uCode error bit if it is set */
 	clear_bit(STATUS_FW_ERROR, &priv->status);
=20
-	rc =3D iwl3945_init_channel_map(priv);
-	if (rc) {
-		IWL_ERROR("initializing regulatory failed: %d\n", rc);
-		return;
-	}
-
-	iwl3945_init_geos(priv);
-	iwl3945_reset_channel_flag(priv);
-
 	if (iwl3945_is_rfkill(priv))
 		return;
=20
@@ -6599,7 +6628,7 @@ static void iwl3945_bg_request_scan(struct work_s=
truct *data)
 	 * that based on the direct_mask added to each channel entry */
 	scan->tx_cmd.len =3D cpu_to_le16(
 		iwl3945_fill_probe_req(priv, (struct ieee80211_mgmt *)scan->data,
-			IWL_MAX_SCAN_SIZE - sizeof(scan), 0));
+			IWL_MAX_SCAN_SIZE - sizeof(*scan), 0));
 	scan->tx_cmd.tx_flags =3D TX_CMD_FLG_SEQ_CTL_MSK;
 	scan->tx_cmd.sta_id =3D priv->hw_setting.bcast_sta_id;
 	scan->tx_cmd.stop_time.life_time =3D TX_CMD_LIFE_TIME_INFINITE;
@@ -7120,7 +7149,7 @@ static void iwl3945_config_ap(struct iwl3945_priv=
 *priv)
 {
 	int rc =3D 0;
=20
-	if (priv->status & STATUS_EXIT_PENDING)
+	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
 		return;
=20
 	/* The following should be done only at AP bring up */
@@ -8614,11 +8643,24 @@ static int iwl3945_pci_probe(struct pci_dev *pd=
ev, const struct pci_device_id *e
 	IWL_DEBUG_INFO("MAC address: %s\n", print_mac(mac, priv->mac_addr));
 	SET_IEEE80211_PERM_ADDR(priv->hw, priv->mac_addr);
=20
+	err =3D iwl3945_init_channel_map(priv);
+	if (err) {
+		IWL_ERROR("initializing regulatory failed: %d\n", err);
+		goto out_remove_sysfs;
+	}
+
+	err =3D iwl3945_init_geos(priv);
+	if (err) {
+		IWL_ERROR("initializing geos failed: %d\n", err);
+		goto out_free_channel_map;
+	}
+	iwl3945_reset_channel_flag(priv);
+
 	iwl3945_rate_control_register(priv->hw);
 	err =3D ieee80211_register_hw(priv->hw);
 	if (err) {
 		IWL_ERROR("Failed to register network device (error %d)\n", err);
-		goto out_remove_sysfs;
+		goto out_free_geos;
 	}
=20
 	priv->hw->conf.beacon_int =3D 100;
@@ -8628,6 +8670,10 @@ static int iwl3945_pci_probe(struct pci_dev *pde=
v, const struct pci_device_id *e
=20
 	return 0;
=20
+ out_free_geos:
+	iwl3945_free_geos(priv);
+ out_free_channel_map:
+	iwl3945_free_channel_map(priv);
  out_remove_sysfs:
 	sysfs_remove_group(&pdev->dev.kobj, &iwl3945_attribute_group);
=20
@@ -8702,10 +8748,8 @@ static void iwl3945_pci_remove(struct pci_dev *p=
dev)
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
=20
-	kfree(priv->channel_info);
-
-	kfree(priv->ieee_channels);
-	kfree(priv->ieee_rates);
+	iwl3945_free_channel_map(priv);
+	iwl3945_free_geos(priv);
=20
 	if (priv->ibss_beacon)
 		dev_kfree_skb(priv->ibss_beacon);
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/=
wireless/iwlwifi/iwl4965-base.c
index c86da5c..bf3a60c 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -1639,6 +1639,12 @@ static void get_eeprom_mac(struct iwl4965_priv *=
priv, u8 *mac)
 	memcpy(mac, priv->eeprom.mac_address, 6);
 }
=20
+static inline void iwl4965_eeprom_release_semaphore(struct iwl4965_pri=
v *priv)
+{
+	iwl4965_clear_bit(priv, CSR_HW_IF_CONFIG_REG,
+		CSR_HW_IF_CONFIG_REG_BIT_EEPROM_OWN_SEM);
+}
+
 /**
  * iwl4965_eeprom_init - read EEPROM contents
  *
@@ -2927,8 +2933,10 @@ static int iwl4965_tx_skb(struct iwl4965_priv *p=
riv,
 #endif
=20
 	/* drop all data frame if we are not associated */
-	if (!iwl4965_is_associated(priv) && !priv->assoc_id &&
-	    ((fc & IEEE80211_FCTL_FTYPE) =3D=3D IEEE80211_FTYPE_DATA)) {
+	if (((fc & IEEE80211_FCTL_FTYPE) =3D=3D IEEE80211_FTYPE_DATA) &&
+	   (!iwl4965_is_associated(priv) ||
+	    !priv->assoc_id ||
+	    !priv->assoc_station_added)) {
 		IWL_DEBUG_DROP("Dropping - !iwl4965_is_associated\n");
 		goto drop_unlock;
 	}
@@ -5131,8 +5139,9 @@ static void iwl4965_irq_tasklet(struct iwl4965_pr=
iv *priv)
 #ifdef CONFIG_IWL4965_DEBUG
 	if (iwl4965_debug_level & (IWL_DL_ISR)) {
 		/* NIC fires this, but we don't use it, redundant with WAKEUP */
-		if (inta & CSR_INT_BIT_MAC_CLK_ACTV)
-			IWL_DEBUG_ISR("Microcode started or stopped.\n");
+		if (inta & CSR_INT_BIT_SCD)
+			IWL_DEBUG_ISR("Scheduler finished to transmit "
+				      "the frame/frames.\n");
=20
 		/* Alive notification via Rx interrupt will do the real work */
 		if (inta & CSR_INT_BIT_ALIVE)
@@ -5140,7 +5149,7 @@ static void iwl4965_irq_tasklet(struct iwl4965_pr=
iv *priv)
 	}
 #endif
 	/* Safely ignore these bits for debug checks below */
-	inta &=3D ~(CSR_INT_BIT_MAC_CLK_ACTV | CSR_INT_BIT_ALIVE);
+	inta &=3D ~(CSR_INT_BIT_SCD | CSR_INT_BIT_ALIVE);
=20
 	/* HW RF KILL switch toggled */
 	if (inta & CSR_INT_BIT_RF_KILL) {
@@ -5269,8 +5278,11 @@ static irqreturn_t iwl4965_isr(int irq, void *da=
ta)
 	IWL_DEBUG_ISR("ISR inta 0x%08x, enabled 0x%08x, fh 0x%08x\n",
 		      inta, inta_mask, inta_fh);
=20
+	inta &=3D ~CSR_INT_BIT_SCD;
+
 	/* iwl4965_irq_tasklet() will service interrupts and re-enable them *=
/
-	tasklet_schedule(&priv->irq_tasklet);
+	if (likely(inta || inta_fh))
+		tasklet_schedule(&priv->irq_tasklet);
=20
  unplugged:
 	spin_unlock(&priv->lock);
@@ -5576,6 +5588,15 @@ static int iwl4965_init_channel_map(struct iwl49=
65_priv *priv)
 	return 0;
 }
=20
+/*
+ * iwl4965_free_channel_map - undo allocations in iwl4965_init_channel=
_map
+ */
+static void iwl4965_free_channel_map(struct iwl4965_priv *priv)
+{
+	kfree(priv->channel_info);
+	priv->channel_count =3D 0;
+}
+
 /* For active scan, listen ACTIVE_DWELL_TIME (msec) on each channel af=
ter
  * sending probe req.  This should be set long enough to hear probe re=
sponses
  * from more than one AP.  */
@@ -5909,6 +5930,17 @@ static int iwl4965_init_geos(struct iwl4965_priv=
 *priv)
 	return 0;
 }
=20
+/*
+ * iwl4965_free_geos - undo allocations in iwl4965_init_geos
+ */
+static void iwl4965_free_geos(struct iwl4965_priv *priv)
+{
+	kfree(priv->modes);
+	kfree(priv->ieee_channels);
+	kfree(priv->ieee_rates);
+	clear_bit(STATUS_GEO_CONFIGURED, &priv->status);
+}
+
 /*********************************************************************=
*********
  *
  * uCode download functions
@@ -6560,15 +6592,6 @@ static void iwl4965_alive_start(struct iwl4965_p=
riv *priv)
 	/* Clear out the uCode error bit if it is set */
 	clear_bit(STATUS_FW_ERROR, &priv->status);
=20
-	rc =3D iwl4965_init_channel_map(priv);
-	if (rc) {
-		IWL_ERROR("initializing regulatory failed: %d\n", rc);
-		return;
-	}
-
-	iwl4965_init_geos(priv);
-	iwl4965_reset_channel_flag(priv);
-
 	if (iwl4965_is_rfkill(priv))
 		return;
=20
@@ -7023,7 +7046,7 @@ static void iwl4965_bg_request_scan(struct work_s=
truct *data)
 	 * that based on the direct_mask added to each channel entry */
 	scan->tx_cmd.len =3D cpu_to_le16(
 		iwl4965_fill_probe_req(priv, (struct ieee80211_mgmt *)scan->data,
-			IWL_MAX_SCAN_SIZE - sizeof(scan), 0));
+			IWL_MAX_SCAN_SIZE - sizeof(*scan), 0));
 	scan->tx_cmd.tx_flags =3D TX_CMD_FLG_SEQ_CTL_MSK;
 	scan->tx_cmd.sta_id =3D priv->hw_setting.bcast_sta_id;
 	scan->tx_cmd.stop_time.life_time =3D TX_CMD_LIFE_TIME_INFINITE;
@@ -7448,7 +7471,7 @@ static int iwl4965_mac_add_interface(struct ieee8=
0211_hw *hw,
=20
 	if (priv->vif) {
 		IWL_DEBUG_MAC80211("leave - vif !=3D NULL\n");
-		return 0;
+		return -EOPNOTSUPP;
 	}
=20
 	spin_lock_irqsave(&priv->lock, flags);
@@ -7580,7 +7603,7 @@ static void iwl4965_config_ap(struct iwl4965_priv=
 *priv)
 {
 	int rc =3D 0;
=20
-	if (priv->status & STATUS_EXIT_PENDING)
+	if (test_bit(STATUS_EXIT_PENDING, &priv->status))
 		return;
=20
 	/* The following should be done only at AP bring up */
@@ -9198,11 +9221,24 @@ static int iwl4965_pci_probe(struct pci_dev *pd=
ev, const struct pci_device_id *e
 	IWL_DEBUG_INFO("MAC address: %s\n", print_mac(mac, priv->mac_addr));
 	SET_IEEE80211_PERM_ADDR(priv->hw, priv->mac_addr);
=20
+	err =3D iwl4965_init_channel_map(priv);
+	if (err) {
+		IWL_ERROR("initializing regulatory failed: %d\n", err);
+		goto out_remove_sysfs;
+	}
+
+	err =3D iwl4965_init_geos(priv);
+	if (err) {
+		IWL_ERROR("initializing geos failed: %d\n", err);
+		goto out_free_channel_map;
+	}
+	iwl4965_reset_channel_flag(priv);
+
 	iwl4965_rate_control_register(priv->hw);
 	err =3D ieee80211_register_hw(priv->hw);
 	if (err) {
 		IWL_ERROR("Failed to register network device (error %d)\n", err);
-		goto out_remove_sysfs;
+		goto out_free_geos;
 	}
=20
 	priv->hw->conf.beacon_int =3D 100;
@@ -9212,6 +9248,10 @@ static int iwl4965_pci_probe(struct pci_dev *pde=
v, const struct pci_device_id *e
=20
 	return 0;
=20
+ out_free_geos:
+	iwl4965_free_geos(priv);
+ out_free_channel_map:
+	iwl4965_free_channel_map(priv);
  out_remove_sysfs:
 	sysfs_remove_group(&pdev->dev.kobj, &iwl4965_attribute_group);
=20
@@ -9286,10 +9326,8 @@ static void iwl4965_pci_remove(struct pci_dev *p=
dev)
 	pci_disable_device(pdev);
 	pci_set_drvdata(pdev, NULL);
=20
-	kfree(priv->channel_info);
-
-	kfree(priv->ieee_channels);
-	kfree(priv->ieee_rates);
+	iwl4965_free_channel_map(priv);
+	iwl4965_free_geos(priv);
=20
 	if (priv->ibss_beacon)
 		dev_kfree_skb(priv->ibss_beacon);
diff --git a/drivers/net/wireless/libertas/assoc.c b/drivers/net/wirele=
ss/libertas/assoc.c
index c622e9b..87e145f 100644
--- a/drivers/net/wireless/libertas/assoc.c
+++ b/drivers/net/wireless/libertas/assoc.c
@@ -12,8 +12,10 @@
 #include "cmd.h"
=20
=20
-static const u8 bssid_any[ETH_ALEN] =3D { 0xFF, 0xFF, 0xFF, 0xFF, 0xFF=
, 0xFF };
-static const u8 bssid_off[ETH_ALEN] =3D { 0x00, 0x00, 0x00, 0x00, 0x00=
, 0x00 };
+static const u8 bssid_any[ETH_ALEN]  __attribute__ ((aligned (2))) =3D
+	{ 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF };
+static const u8 bssid_off[ETH_ALEN]  __attribute__ ((aligned (2))) =3D
+	{ 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
=20
=20
 static int assoc_helper_essid(struct lbs_private *priv,
diff --git a/drivers/net/wireless/libertas/dev.h b/drivers/net/wireless=
/libertas/dev.h
index 58d7ef6..5a69f2b 100644
--- a/drivers/net/wireless/libertas/dev.h
+++ b/drivers/net/wireless/libertas/dev.h
@@ -349,7 +349,7 @@ struct assoc_request {
 	u8 channel;
 	u8 band;
 	u8 mode;
-	u8 bssid[ETH_ALEN];
+	u8 bssid[ETH_ALEN] __attribute__ ((aligned (2)));
=20
 	/** WEP keys */
 	struct enc_key wep_keys[4];
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wirele=
ss/libertas/if_cs.c
index 4b5ab9a..5a9cadb 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -249,14 +249,14 @@ static irqreturn_t if_cs_interrupt(int irq, void =
*data)
 	lbs_deb_enter(LBS_DEB_CS);
=20
 	int_cause =3D if_cs_read16(card, IF_CS_C_INT_CAUSE);
-	if(int_cause =3D=3D 0x0) {
+	if (int_cause =3D=3D 0x0) {
 		/* Not for us */
 		return IRQ_NONE;
=20
 	} else if (int_cause =3D=3D 0xffff) {
 		/* Read in junk, the card has probably been removed */
 		card->priv->surpriseremoved =3D 1;
-
+		return IRQ_HANDLED;
 	} else {
 		if (int_cause & IF_CS_H_IC_TX_OVER)
 			lbs_host_to_card_done(card->priv);
@@ -717,8 +717,8 @@ static void if_cs_release(struct pcmcia_device *p_d=
ev)
=20
 	lbs_deb_enter(LBS_DEB_CS);
=20
-	pcmcia_disable_device(p_dev);
 	free_irq(p_dev->irq.AssignedIRQ, card);
+	pcmcia_disable_device(p_dev);
 	if (card->iobase)
 		ioport_unmap(card->iobase);
=20
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wirele=
ss/rt2x00/rt61pci.c
index ab52f22..b31f0c2 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1736,7 +1736,8 @@ static void rt61pci_txdone(struct rt2x00_dev *rt2=
x00dev)
 			WARNING(rt2x00dev,
 				"TX status report missed for entry %p\n",
 				entry_done);
-			rt2x00lib_txdone(entry_done, TX_FAIL_OTHER, 0);
+			rt2x00pci_txdone(rt2x00dev, entry_done, TX_FAIL_OTHER,
+					 0);
 			entry_done =3D rt2x00_get_data_entry_done(ring);
 		}
=20
diff --git a/drivers/net/wireless/rtl8180_dev.c b/drivers/net/wireless/=
rtl8180_dev.c
index 07f37b0..27ebd68 100644
--- a/drivers/net/wireless/rtl8180_dev.c
+++ b/drivers/net/wireless/rtl8180_dev.c
@@ -36,6 +36,7 @@ MODULE_LICENSE("GPL");
 static struct pci_device_id rtl8180_table[] __devinitdata =3D {
 	/* rtl8185 */
 	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK, 0x8185) },
+	{ PCI_DEVICE(PCI_VENDOR_ID_BELKIN, 0x700f) },
 	{ PCI_DEVICE(PCI_VENDOR_ID_BELKIN, 0x701f) },
=20
 	/* rtl8180 */
diff --git a/include/linux/input.h b/include/linux/input.h
index 2075d6d..056a17a 100644
--- a/include/linux/input.h
+++ b/include/linux/input.h
@@ -371,6 +371,8 @@ struct input_absinfo {
 #define KEY_BRIGHTNESS_ZERO	244	/* brightness off, use ambient */
 #define KEY_DISPLAY_OFF		245	/* display device to off state */
=20
+#define KEY_WIMAX		246
+
 #define BTN_MISC		0x100
 #define BTN_0			0x100
 #define BTN_1			0x101
diff --git a/include/linux/rfkill.h b/include/linux/rfkill.h
index 0ce5e0b..e3ab21d 100644
--- a/include/linux/rfkill.h
+++ b/include/linux/rfkill.h
@@ -33,11 +33,13 @@
  * RFKILL_TYPE_WLAN: switch is on a 802.11 wireless network device.
  * RFKILL_TYPE_BLUETOOTH: switch is on a bluetooth device.
  * RFKILL_TYPE_UWB: switch is on a ultra wideband device.
+ * RFKILL_TYPE_WIMAX: switch is on a WiMAX device.
  */
 enum rfkill_type {
 	RFKILL_TYPE_WLAN ,
 	RFKILL_TYPE_BLUETOOTH,
 	RFKILL_TYPE_UWB,
+	RFKILL_TYPE_WIMAX,
 	RFKILL_TYPE_MAX,
 };
=20
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 89e1e30..d44c872 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -340,9 +340,42 @@ static u32 ieee80211_rx_load_stats(struct ieee8021=
1_local *local,
 	return load;
 }
=20
+static ieee80211_txrx_result
+ieee80211_rx_h_verify_ip_alignment(struct ieee80211_txrx_data *rx)
+{
+	int hdrlen;
+
+	/*
+	 * Drivers are required to align the payload data in a way that
+	 * guarantees that the contained IP header is aligned to a four-
+	 * byte boundary. In the case of regular frames, this simply means
+	 * aligning the payload to a four-byte boundary (because either
+	 * the IP header is directly contained, or IV/RFC1042 headers that
+	 * have a length divisible by four are in front of it.
+	 *
+	 * With A-MSDU frames, however, the payload data address must
+	 * yield two modulo four because there are 14-byte 802.3 headers
+	 * within the A-MSDU frames that push the IP header further back
+	 * to a multiple of four again. Thankfully, the specs were sane
+	 * enough this time around to require padding each A-MSDU subframe
+	 * to a length that is a multiple of four.
+	 *
+	 * Padding like atheros hardware adds which is inbetween the 802.11
+	 * header and the payload is not supported, the driver is required
+	 * to move the 802.11 header further back in that case.
+	 */
+	hdrlen =3D ieee80211_get_hdrlen(rx->fc);
+	if (rx->flags & IEEE80211_TXRXD_RX_AMSDU)
+		hdrlen +=3D ETH_HLEN;
+	WARN_ON_ONCE(((unsigned long)(rx->skb->data + hdrlen)) & 3);
+
+	return TXRX_CONTINUE;
+}
+
 ieee80211_rx_handler ieee80211_rx_pre_handlers[] =3D
 {
 	ieee80211_rx_h_parse_qos,
+	ieee80211_rx_h_verify_ip_alignment,
 	NULL
 };
=20
@@ -1679,7 +1712,6 @@ static void __ieee80211_rx_handle_packet(struct i=
eee80211_hw *hw,
 	struct ieee80211_sub_if_data *prev =3D NULL;
 	struct sk_buff *skb_new;
 	u8 *bssid;
-	int hdrlen;
=20
 	hdr =3D (struct ieee80211_hdr *) skb->data;
 	memset(&rx, 0, sizeof(rx));
@@ -1691,18 +1723,6 @@ static void __ieee80211_rx_handle_packet(struct =
ieee80211_hw *hw,
 	rx.fc =3D le16_to_cpu(hdr->frame_control);
 	type =3D rx.fc & IEEE80211_FCTL_FTYPE;
=20
-	/*
-	 * Drivers are required to align the payload data to a four-byte
-	 * boundary, so the last two bits of the address where it starts
-	 * may not be set. The header is required to be directly before
-	 * the payload data, padding like atheros hardware adds which is
-	 * inbetween the 802.11 header and the payload is not supported,
-	 * the driver is required to move the 802.11 header further back
-	 * in that case.
-	 */
-	hdrlen =3D ieee80211_get_hdrlen(rx.fc);
-	WARN_ON_ONCE(((unsigned long)(skb->data + hdrlen)) & 3);
-
 	if (type =3D=3D IEEE80211_FTYPE_DATA || type =3D=3D IEEE80211_FTYPE_M=
GMT)
 		local->dot11ReceivedFragmentCount++;
=20
@@ -1952,7 +1972,7 @@ static u8 ieee80211_rx_reorder_ampdu(struct ieee8=
0211_local *local,
 		goto end_reorder;
=20
 	/* null data frames are excluded */
-	if (unlikely(fc & IEEE80211_STYPE_QOS_NULLFUNC))
+	if (unlikely(fc & IEEE80211_STYPE_NULLFUNC))
 		goto end_reorder;
=20
 	/* new un-ordered ampdu frame - process it */
diff --git a/net/rfkill/rfkill-input.c b/net/rfkill/rfkill-input.c
index d1e9d68..e4b051d 100644
--- a/net/rfkill/rfkill-input.c
+++ b/net/rfkill/rfkill-input.c
@@ -84,6 +84,7 @@ static void rfkill_schedule_toggle(struct rfkill_task=
 *task)
 static DEFINE_RFKILL_TASK(rfkill_wlan, RFKILL_TYPE_WLAN);
 static DEFINE_RFKILL_TASK(rfkill_bt, RFKILL_TYPE_BLUETOOTH);
 static DEFINE_RFKILL_TASK(rfkill_uwb, RFKILL_TYPE_UWB);
+static DEFINE_RFKILL_TASK(rfkill_wimax, RFKILL_TYPE_WIMAX);
=20
 static void rfkill_event(struct input_handle *handle, unsigned int typ=
e,
 			unsigned int code, int down)
@@ -99,6 +100,9 @@ static void rfkill_event(struct input_handle *handle=
, unsigned int type,
 		case KEY_UWB:
 			rfkill_schedule_toggle(&rfkill_uwb);
 			break;
+		case KEY_WIMAX:
+			rfkill_schedule_toggle(&rfkill_wimax);
+			break;
 		default:
 			break;
 		}
@@ -159,6 +163,11 @@ static const struct input_device_id rfkill_ids[] =3D=
 {
 		.evbit =3D { BIT_MASK(EV_KEY) },
 		.keybit =3D { [BIT_WORD(KEY_UWB)] =3D BIT_MASK(KEY_UWB) },
 	},
+	{
+		.flags =3D INPUT_DEVICE_ID_MATCH_EVBIT | INPUT_DEVICE_ID_MATCH_KEYBI=
T,
+		.evbit =3D { BIT_MASK(EV_KEY) },
+		.keybit =3D { [BIT_WORD(KEY_WIMAX)] =3D BIT_MASK(KEY_WIMAX) },
+	},
 	{ }
 };
=20
diff --git a/net/rfkill/rfkill.c b/net/rfkill/rfkill.c
index d06d338..6562f86 100644
--- a/net/rfkill/rfkill.c
+++ b/net/rfkill/rfkill.c
@@ -126,6 +126,9 @@ static ssize_t rfkill_type_show(struct device *dev,
 	case RFKILL_TYPE_UWB:
 		type =3D "ultrawideband";
 		break;
+	case RFKILL_TYPE_WIMAX:
+		type =3D "wimax";
+		break;
 	default:
 		BUG();
 	}
--=20
John W. Linville
linville@tuxdriver.com
