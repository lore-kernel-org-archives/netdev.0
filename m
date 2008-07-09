From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-07-09
Date: Wed, 9 Jul 2008 16:42:02 -0400
Message-ID: <20080709204202.GA17820@tuxdriver.com>
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

A few more fixes for 2.6.26...the only big parts are either moving
existing code or adding missing initializations to zero.

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 32e8d4948bb0b5f3f0ac5cdb71d0ac8e305b29a5:
  Vlad Yasevich (1):
        sctp: Add documentation for sctp sysctl variable

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Ihar Hrachyshka (1):
      libertas: fix memory alignment problems on the blackfin

Ivo van Doorn (1):
      rt2x00: Disable synchronization during initialization

Luis Carlos Cobo (1):
      zd1211rw: stop beacons on remove_interface

Mattias Nissler (1):
      rc80211_pid: Fix fast_start parameter handling

 drivers/net/wireless/libertas/scan.c    |    4 ++--
 drivers/net/wireless/rt2x00/rt2400pci.c |   11 +++++++++++
 drivers/net/wireless/rt2x00/rt2500pci.c |   11 +++++++++++
 drivers/net/wireless/rt2x00/rt2500usb.c |    7 +++++++
 drivers/net/wireless/rt2x00/rt61pci.c   |    9 +++++++++
 drivers/net/wireless/rt2x00/rt73usb.c   |    9 +++++++++
 drivers/net/wireless/zd1211rw/zd_mac.c  |    1 +
 net/mac80211/rc80211_pid.h              |    5 -----
 net/mac80211/rc80211_pid_algo.c         |   31 +++++++++++++------------------
 9 files changed, 63 insertions(+), 25 deletions(-)

diff --git a/drivers/net/wireless/libertas/scan.c b/drivers/net/wireless/libertas/scan.c
index d448c97..387d487 100644
--- a/drivers/net/wireless/libertas/scan.c
+++ b/drivers/net/wireless/libertas/scan.c
@@ -567,11 +567,11 @@ static int lbs_process_bss(struct bss_descriptor *bss,
 	pos += 8;
 
 	/* beacon interval is 2 bytes long */
-	bss->beaconperiod = le16_to_cpup((void *) pos);
+	bss->beaconperiod = get_unaligned_le16(pos);
 	pos += 2;
 
 	/* capability information is 2 bytes long */
-	bss->capability = le16_to_cpup((void *) pos);
+	bss->capability = get_unaligned_le16(pos);
 	lbs_deb_scan("process_bss: capabilities 0x%04x\n", bss->capability);
 	pos += 2;
 
diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index 560b9c7..b36ed1c 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -731,6 +731,17 @@ static int rt2400pci_init_registers(struct rt2x00_dev *rt2x00dev)
 			   (rt2x00dev->rx->data_size / 128));
 	rt2x00pci_register_write(rt2x00dev, CSR9, reg);
 
+	rt2x00pci_register_read(rt2x00dev, CSR14, &reg);
+	rt2x00_set_field32(&reg, CSR14_TSF_COUNT, 0);
+	rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 0);
+	rt2x00_set_field32(&reg, CSR14_TBCN, 0);
+	rt2x00_set_field32(&reg, CSR14_TCFP, 0);
+	rt2x00_set_field32(&reg, CSR14_TATIMW, 0);
+	rt2x00_set_field32(&reg, CSR14_BEACON_GEN, 0);
+	rt2x00_set_field32(&reg, CSR14_CFP_COUNT_PRELOAD, 0);
+	rt2x00_set_field32(&reg, CSR14_TBCM_PRELOAD, 0);
+	rt2x00pci_register_write(rt2x00dev, CSR14, reg);
+
 	rt2x00pci_register_write(rt2x00dev, CNT3, 0x3f080000);
 
 	rt2x00pci_register_read(rt2x00dev, ARCSR0, &reg);
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index a5ed54b..f7731fb 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -824,6 +824,17 @@ static int rt2500pci_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, CSR11_CW_SELECT, 0);
 	rt2x00pci_register_write(rt2x00dev, CSR11, reg);
 
+	rt2x00pci_register_read(rt2x00dev, CSR14, &reg);
+	rt2x00_set_field32(&reg, CSR14_TSF_COUNT, 0);
+	rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 0);
+	rt2x00_set_field32(&reg, CSR14_TBCN, 0);
+	rt2x00_set_field32(&reg, CSR14_TCFP, 0);
+	rt2x00_set_field32(&reg, CSR14_TATIMW, 0);
+	rt2x00_set_field32(&reg, CSR14_BEACON_GEN, 0);
+	rt2x00_set_field32(&reg, CSR14_CFP_COUNT_PRELOAD, 0);
+	rt2x00_set_field32(&reg, CSR14_TBCM_PRELOAD, 0);
+	rt2x00pci_register_write(rt2x00dev, CSR14, reg);
+
 	rt2x00pci_register_write(rt2x00dev, CNT3, 0);
 
 	rt2x00pci_register_read(rt2x00dev, TXCSR8, &reg);
diff --git a/drivers/net/wireless/rt2x00/rt2500usb.c b/drivers/net/wireless/rt2x00/rt2500usb.c
index 61e59c1..d90512f 100644
--- a/drivers/net/wireless/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/rt2x00/rt2500usb.c
@@ -801,6 +801,13 @@ static int rt2500usb_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field16(&reg, TXRX_CSR8_BBP_ID1_VALID, 0);
 	rt2500usb_register_write(rt2x00dev, TXRX_CSR8, reg);
 
+	rt2500usb_register_read(rt2x00dev, TXRX_CSR19, &reg);
+	rt2x00_set_field16(&reg, TXRX_CSR19_TSF_COUNT, 0);
+	rt2x00_set_field16(&reg, TXRX_CSR19_TSF_SYNC, 0);
+	rt2x00_set_field16(&reg, TXRX_CSR19_TBCN, 0);
+	rt2x00_set_field16(&reg, TXRX_CSR19_BEACON_GEN, 0);
+	rt2500usb_register_write(rt2x00dev, TXRX_CSR19, reg);
+
 	rt2500usb_register_write(rt2x00dev, TXRX_CSR21, 0xe78f);
 	rt2500usb_register_write(rt2x00dev, MAC_CSR9, 0xff1d);
 
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index 14bc7b2..c3afb5c 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1201,6 +1201,15 @@ static int rt61pci_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, TXRX_CSR8_ACK_CTS_54MBS, 42);
 	rt2x00pci_register_write(rt2x00dev, TXRX_CSR8, reg);
 
+	rt2x00pci_register_read(rt2x00dev, TXRX_CSR9, &reg);
+	rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_INTERVAL, 0);
+	rt2x00_set_field32(&reg, TXRX_CSR9_TSF_TICKING, 0);
+	rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC, 0);
+	rt2x00_set_field32(&reg, TXRX_CSR9_TBTT_ENABLE, 0);
+	rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_GEN, 0);
+	rt2x00_set_field32(&reg, TXRX_CSR9_TIMESTAMP_COMPENSATE, 0);
+	rt2x00pci_register_write(rt2x00dev, TXRX_CSR9, reg);
+
 	rt2x00pci_register_write(rt2x00dev, TXRX_CSR15, 0x0000000f);
 
 	rt2x00pci_register_write(rt2x00dev, MAC_CSR6, 0x00000fff);
diff --git a/drivers/net/wireless/rt2x00/rt73usb.c b/drivers/net/wireless/rt2x00/rt73usb.c
index 83cc014..46e9e08 100644
--- a/drivers/net/wireless/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/rt2x00/rt73usb.c
@@ -1006,6 +1006,15 @@ static int rt73usb_init_registers(struct rt2x00_dev *rt2x00dev)
 	rt2x00_set_field32(&reg, TXRX_CSR8_ACK_CTS_54MBS, 42);
 	rt73usb_register_write(rt2x00dev, TXRX_CSR8, reg);
 
+	rt73usb_register_read(rt2x00dev, TXRX_CSR9, &reg);
+	rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_INTERVAL, 0);
+	rt2x00_set_field32(&reg, TXRX_CSR9_TSF_TICKING, 0);
+	rt2x00_set_field32(&reg, TXRX_CSR9_TSF_SYNC, 0);
+	rt2x00_set_field32(&reg, TXRX_CSR9_TBTT_ENABLE, 0);
+	rt2x00_set_field32(&reg, TXRX_CSR9_BEACON_GEN, 0);
+	rt2x00_set_field32(&reg, TXRX_CSR9_TIMESTAMP_COMPENSATE, 0);
+	rt73usb_register_write(rt2x00dev, TXRX_CSR9, reg);
+
 	rt73usb_register_write(rt2x00dev, TXRX_CSR15, 0x0000000f);
 
 	rt73usb_register_read(rt2x00dev, MAC_CSR6, &reg);
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 418606a..694e95d 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -765,6 +765,7 @@ static void zd_op_remove_interface(struct ieee80211_hw *hw,
 {
 	struct zd_mac *mac = zd_hw_mac(hw);
 	mac->type = IEEE80211_IF_TYPE_INVALID;
+	zd_set_beacon_interval(&mac->chip, 0);
 	zd_write_mac_addr(&mac->chip, NULL);
 }
 
diff --git a/net/mac80211/rc80211_pid.h b/net/mac80211/rc80211_pid.h
index 04afc13..4ea7b97 100644
--- a/net/mac80211/rc80211_pid.h
+++ b/net/mac80211/rc80211_pid.h
@@ -141,7 +141,6 @@ struct rc_pid_events_file_info {
  *	rate behaviour values (lower means we should trust more what we learnt
  *	about behaviour of rates, higher means we should trust more the natural
  *	ordering of rates)
- * @fast_start: if Y, push high rates right after initialization
  */
 struct rc_pid_debugfs_entries {
 	struct dentry *dir;
@@ -154,7 +153,6 @@ struct rc_pid_debugfs_entries {
 	struct dentry *sharpen_factor;
 	struct dentry *sharpen_duration;
 	struct dentry *norm_offset;
-	struct dentry *fast_start;
 };
 
 void rate_control_pid_event_tx_status(struct rc_pid_event_buffer *buf,
@@ -267,9 +265,6 @@ struct rc_pid_info {
 	/* Normalization offset. */
 	unsigned int norm_offset;
 
-	/* Fast starst parameter. */
-	unsigned int fast_start;
-
 	/* Rates information. */
 	struct rc_pid_rateinfo *rinfo;
 
diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
index a849b74..bcd27c1 100644
--- a/net/mac80211/rc80211_pid_algo.c
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -398,13 +398,25 @@ static void *rate_control_pid_alloc(struct ieee80211_local *local)
 		return NULL;
 	}
 
+	pinfo->target = RC_PID_TARGET_PF;
+	pinfo->sampling_period = RC_PID_INTERVAL;
+	pinfo->coeff_p = RC_PID_COEFF_P;
+	pinfo->coeff_i = RC_PID_COEFF_I;
+	pinfo->coeff_d = RC_PID_COEFF_D;
+	pinfo->smoothing_shift = RC_PID_SMOOTHING_SHIFT;
+	pinfo->sharpen_factor = RC_PID_SHARPENING_FACTOR;
+	pinfo->sharpen_duration = RC_PID_SHARPENING_DURATION;
+	pinfo->norm_offset = RC_PID_NORM_OFFSET;
+	pinfo->rinfo = rinfo;
+	pinfo->oldrate = 0;
+
 	/* Sort the rates. This is optimized for the most common case (i.e.
 	 * almost-sorted CCK+OFDM rates). Kind of bubble-sort with reversed
 	 * mapping too. */
 	for (i = 0; i < sband->n_bitrates; i++) {
 		rinfo[i].index = i;
 		rinfo[i].rev_index = i;
-		if (pinfo->fast_start)
+		if (RC_PID_FAST_START)
 			rinfo[i].diff = 0;
 		else
 			rinfo[i].diff = i * pinfo->norm_offset;
@@ -425,19 +437,6 @@ static void *rate_control_pid_alloc(struct ieee80211_local *local)
 			break;
 	}
 
-	pinfo->target = RC_PID_TARGET_PF;
-	pinfo->sampling_period = RC_PID_INTERVAL;
-	pinfo->coeff_p = RC_PID_COEFF_P;
-	pinfo->coeff_i = RC_PID_COEFF_I;
-	pinfo->coeff_d = RC_PID_COEFF_D;
-	pinfo->smoothing_shift = RC_PID_SMOOTHING_SHIFT;
-	pinfo->sharpen_factor = RC_PID_SHARPENING_FACTOR;
-	pinfo->sharpen_duration = RC_PID_SHARPENING_DURATION;
-	pinfo->norm_offset = RC_PID_NORM_OFFSET;
-	pinfo->fast_start = RC_PID_FAST_START;
-	pinfo->rinfo = rinfo;
-	pinfo->oldrate = 0;
