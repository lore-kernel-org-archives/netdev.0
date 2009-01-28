From: Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/3] wireless: replace uses of __constant_{endian}
Date: Wed, 28 Jan 2009 00:00:09 -0800
Message-ID: <1233129609.6717.43.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: John Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The base versions handle constant folding now.

Signed-off-by: Harvey Harrison <harvey.harrison-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/hostap/hostap_80211_rx.c |    4 ++--
 drivers/net/wireless/hostap/hostap_ap.c       |    8 ++++----
 drivers/net/wireless/hostap/hostap_ioctl.c    |    6 +++---
 drivers/net/wireless/ipw2x00/ipw2200.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945-led.h   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c       |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-calib.c      |    6 +++---
 drivers/net/wireless/iwlwifi/iwl-commands.h   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-led.h        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-power.c      |   14 +++++++-------
 drivers/net/wireless/iwlwifi/iwl-scan.c       |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-tx.c         |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |   22 +++++++++++-----------
 drivers/net/wireless/orinoco/hermes_dld.c     |    4 ++--
 drivers/net/wireless/orinoco/orinoco.c        |    2 +-
 net/mac80211/rx.c                             |    8 ++++----
 17 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/drivers/net/wireless/hostap/hostap_80211_rx.c b/drivers/net/wireless/hostap/hostap_80211_rx.c
index 19b1bf0..2417563 100644
--- a/drivers/net/wireless/hostap/hostap_80211_rx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_rx.c
@@ -193,7 +193,7 @@ hdr->f.status = s; hdr->f.len = l; hdr->f.data = d
 	if (prism_header)
 		skb_pull(skb, phdrlen);
 	skb->pkt_type = PACKET_OTHERHOST;
-	skb->protocol = __constant_htons(ETH_P_802_2);
+	skb->protocol = cpu_to_be16(ETH_P_802_2);
 	memset(skb->cb, 0, sizeof(skb->cb));
 	netif_rx(skb);
 
@@ -1094,7 +1094,7 @@ void hostap_80211_rx(struct net_device *dev, struct sk_buff *skb,
 	if (skb2 != NULL) {
 		/* send to wireless media */
 		skb2->dev = dev;
-		skb2->protocol = __constant_htons(ETH_P_802_3);
+		skb2->protocol = cpu_to_be16(ETH_P_802_3);
 		skb_reset_mac_header(skb2);
 		skb_reset_network_header(skb2);
 		/* skb2->network_header += ETH_HLEN; */
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index 0903db7..0a4bf94 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -609,7 +609,7 @@ static void hostap_ap_tx_cb(struct sk_buff *skb, int ok, void *data)
 	skb->dev = ap->local->apdev;
 	skb_pull(skb, hostap_80211_get_hdrlen(fc));
 	skb->pkt_type = PACKET_OTHERHOST;
-	skb->protocol = __constant_htons(ETH_P_802_2);
+	skb->protocol = cpu_to_be16(ETH_P_802_2);
 	memset(skb->cb, 0, sizeof(skb->cb));
 	netif_rx(skb);
 }
@@ -2281,7 +2281,7 @@ void hostap_rx(struct net_device *dev, struct sk_buff *skb,
 	    WLAN_FC_GET_STYPE(fc) == IEEE80211_STYPE_BEACON)
 		goto drop;
 
-	skb->protocol = __constant_htons(ETH_P_HOSTAP);
+	skb->protocol = cpu_to_be16(ETH_P_HOSTAP);
 	handle_ap_item(local, skb, rx_stats);
 	return;
 
@@ -2310,7 +2310,7 @@ static void schedule_packet_send(local_info_t *local, struct sta_info *sta)
 	hdr = (struct ieee80211_hdr_4addr *) skb_put(skb, 16);
 
 	/* Generate a fake pspoll frame to start packet delivery */
-	hdr->frame_ctl = __constant_cpu_to_le16(
+	hdr->frame_ctl = cpu_to_le16(
 		IEEE80211_FTYPE_CTL | IEEE80211_STYPE_PSPOLL);
 	memcpy(hdr->addr1, local->dev->dev_addr, ETH_ALEN);
 	memcpy(hdr->addr2, sta->addr, ETH_ALEN);
@@ -2754,7 +2754,7 @@ ap_tx_ret hostap_handle_sta_tx(local_info_t *local, struct hostap_tx_data *tx)
 	if (meta->flags & HOSTAP_TX_FLAGS_ADD_MOREDATA) {
 		/* indicate to STA that more frames follow */
 		hdr->frame_ctl |=
-			__constant_cpu_to_le16(IEEE80211_FCTL_MOREDATA);
+			cpu_to_le16(IEEE80211_FCTL_MOREDATA);
 	}
 
 	if (meta->flags & HOSTAP_TX_FLAGS_BUFFERED_FRAME) {
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index c40fdf4..8618b33 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1638,7 +1638,7 @@ static int prism2_request_hostscan(struct net_device *dev,
 	memset(&scan_req, 0, sizeof(scan_req));
 	scan_req.channel_list = cpu_to_le16(local->channel_mask &
 					    local->scan_channel_mask);
-	scan_req.txrate = __constant_cpu_to_le16(HFA384X_RATES_1MBPS);
+	scan_req.txrate = cpu_to_le16(HFA384X_RATES_1MBPS);
 	if (ssid) {
 		if (ssid_len > 32)
 			return -EINVAL;
@@ -1668,7 +1668,7 @@ static int prism2_request_scan(struct net_device *dev)
 	memset(&scan_req, 0, sizeof(scan_req));
 	scan_req.channel_list = cpu_to_le16(local->channel_mask &
 					    local->scan_channel_mask);
-	scan_req.txrate = __constant_cpu_to_le16(HFA384X_RATES_1MBPS);
+	scan_req.txrate = cpu_to_le16(HFA384X_RATES_1MBPS);
 
 	/* FIX:
 	 * It seems to be enough to set roaming mode for a short moment to
@@ -2514,7 +2514,7 @@ static int prism2_ioctl_priv_prism2_param(struct net_device *dev,
 		u16 rate;
 
 		memset(&scan_req, 0, sizeof(scan_req));
-		scan_req.channel_list = __constant_cpu_to_le16(0x3fff);
+		scan_req.channel_list = cpu_to_le16(0x3fff);
 		switch (value) {
 		case 1: rate = HFA384X_RATES_1MBPS; break;
 		case 2: rate = HFA384X_RATES_2MBPS; break;
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 625f2cf..0420d3d 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -8272,7 +8272,7 @@ static void ipw_handle_mgmt_packet(struct ipw_priv *priv,
 		skb_reset_mac_header(skb);
 
 		skb->pkt_type = PACKET_OTHERHOST;
-		skb->protocol = __constant_htons(ETH_P_80211_STATS);
+		skb->protocol = cpu_to_be16(ETH_P_80211_STATS);
 		memset(skb->cb, 0, sizeof(rxb->skb->cb));
 		netif_rx(skb);
 		rxb->skb = NULL;
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-led.h b/drivers/net/wireless/iwlwifi/iwl-3945-led.h
index 749ac03..ad7334d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-led.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-led.h
@@ -32,7 +32,7 @@ struct iwl3945_priv;
 #ifdef CONFIG_IWL3945_LEDS
 #define IWL_LED_SOLID 11
 #define IWL_LED_NAME_LEN 31
-#define IWL_DEF_LED_INTRVL __constant_cpu_to_le32(1000)
+#define IWL_DEF_LED_INTRVL cpu_to_le32(1000)
 
 #define IWL_LED_ACTIVITY       (0<<1)
 #define IWL_LED_LINK           (1<<1)
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.h b/drivers/net/wireless/iwlwifi/iwl-3945.h
index 2c0ddc5..262ac9d 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.h
@@ -294,7 +294,7 @@ struct iwl3945_frame {
 #define SEQ_TO_INDEX(x) ((u8)(x & 0xff))
 #define INDEX_TO_SEQ(x) ((u8)(x & 0xff))
 #define SEQ_HUGE_FRAME  (0x4000)
-#define SEQ_RX_FRAME    __constant_cpu_to_le16(0x8000)
+#define SEQ_RX_FRAME    cpu_to_le16(0x8000)
 #define SEQ_TO_SN(seq) (((seq) & IEEE80211_SCTL_SEQ) >> 4)
 #define SN_TO_SEQ(ssn) (((ssn) << 4) & IEEE80211_SCTL_SEQ)
 #define MAX_SN ((IEEE80211_SCTL_SEQ) >> 4)
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index 5a72bc0..7883cb0 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -1986,8 +1986,8 @@ static u16 iwl4965_build_addsta_hcmd(const struct iwl_addsta_cmd *cmd, u8 *data)
 	addsta->add_immediate_ba_tid = cmd->add_immediate_ba_tid;
 	addsta->remove_immediate_ba_tid = cmd->remove_immediate_ba_tid;
 	addsta->add_immediate_ba_ssn = cmd->add_immediate_ba_ssn;
-	addsta->reserved1 = __constant_cpu_to_le16(0);
-	addsta->reserved2 = __constant_cpu_to_le32(0);
+	addsta->reserved1 = cpu_to_le16(0);
+	addsta->reserved2 = cpu_to_le32(0);
 
 	return (u16)sizeof(struct iwl4965_addsta_cmd);
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-calib.c b/drivers/net/wireless/iwlwifi/iwl-calib.c
index f836ecc..4d89813 100644
--- a/drivers/net/wireless/iwlwifi/iwl-calib.c
+++ b/drivers/net/wireless/iwlwifi/iwl-calib.c
@@ -452,11 +452,11 @@ static int iwl_sensitivity_write(struct iwl_priv *priv)
 				cpu_to_le16((u16)data->nrg_th_ofdm);
 
 	cmd.table[HD_BARKER_CORR_TH_ADD_MIN_INDEX] =
-				__constant_cpu_to_le16(190);
+				cpu_to_le16(190);
 	cmd.table[HD_BARKER_CORR_TH_ADD_MIN_MRC_INDEX] =
-				__constant_cpu_to_le16(390);
+				cpu_to_le16(390);
 	cmd.table[HD_OFDM_ENERGY_TH_IN_INDEX] =
-				__constant_cpu_to_le16(62);
+				cpu_to_le16(62);
 
 	IWL_DEBUG_CALIB("ofdm: ac %u mrc %u x1 %u mrc_x1 %u thresh %u\n",
 			data->auto_corr_ofdm, data->auto_corr_ofdm_mrc,
diff --git a/drivers/net/wireless/iwlwifi/iwl-commands.h b/drivers/net/wireless/iwlwifi/iwl-commands.h
index ba99720..fdd3ba9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-commands.h
+++ b/drivers/net/wireless/iwlwifi/iwl-commands.h
@@ -2418,7 +2418,7 @@ struct statistics_rx_ht_phy {
 	__le32 reserved2;
 } __attribute__ ((packed));
 
-#define INTERFERENCE_DATA_AVAILABLE      __constant_cpu_to_le32(1)
+#define INTERFERENCE_DATA_AVAILABLE      cpu_to_le32(1)
 
 struct statistics_rx_non_phy {
 	__le32 bogus_cts;	/* CTS received when not expecting CTS */
diff --git a/drivers/net/wireless/iwlwifi/iwl-led.h b/drivers/net/wireless/iwlwifi/iwl-led.h
index 021e00b..9ff843b 100644
--- a/drivers/net/wireless/iwlwifi/iwl-led.h
+++ b/drivers/net/wireless/iwlwifi/iwl-led.h
@@ -35,7 +35,7 @@ struct iwl_priv;
 
 #define IWL_LED_SOLID 11
 #define IWL_LED_NAME_LEN 31
-#define IWL_DEF_LED_INTRVL __constant_cpu_to_le32(1000)
+#define IWL_DEF_LED_INTRVL cpu_to_le32(1000)
 
 #define IWL_LED_ACTIVITY       (0<<1)
 #define IWL_LED_LINK           (1<<1)
diff --git a/drivers/net/wireless/iwlwifi/iwl-power.c b/drivers/net/wireless/iwlwifi/iwl-power.c
index 75ca6a5..e9f23e5 100644
--- a/drivers/net/wireless/iwlwifi/iwl-power.c
+++ b/drivers/net/wireless/iwlwifi/iwl-power.c
@@ -60,14 +60,14 @@
 #define IWL_POWER_RANGE_1_MAX  (10)
 

-#define NOSLP __constant_cpu_to_le16(0), 0, 0
+#define NOSLP cpu_to_le16(0), 0, 0
 #define SLP IWL_POWER_DRIVER_ALLOW_SLEEP_MSK, 0, 0
-#define SLP_TOUT(T) __constant_cpu_to_le32((T) * MSEC_TO_USEC)
-#define SLP_VEC(X0, X1, X2, X3, X4) {__constant_cpu_to_le32(X0), \
-				     __constant_cpu_to_le32(X1), \
-				     __constant_cpu_to_le32(X2), \
-				     __constant_cpu_to_le32(X3), \
-				     __constant_cpu_to_le32(X4)}
+#define SLP_TOUT(T) cpu_to_le32((T) * MSEC_TO_USEC)
+#define SLP_VEC(X0, X1, X2, X3, X4) {cpu_to_le32(X0), \
+				     cpu_to_le32(X1), \
+				     cpu_to_le32(X2), \
+				     cpu_to_le32(X3), \
+				     cpu_to_le32(X4)}
 
 #define IWL_POWER_ON_BATTERY		IWL_POWER_INDEX_5
 #define IWL_POWER_ON_AC_DISASSOC	IWL_POWER_MODE_CAM
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index 3c803f6..9089310 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -52,8 +52,8 @@
  * time if it's a quiet channel (nothing responded to our probe, and there's
  * no other traffic).
  * Disable "quiet" feature by setting PLCP_QUIET_THRESH to 0. */
-#define IWL_PLCP_QUIET_THRESH       __constant_cpu_to_le16(1)  /* packets */
-#define IWL_ACTIVE_QUIET_TIME       __constant_cpu_to_le16(10)  /* msec */
+#define IWL_PLCP_QUIET_THRESH       cpu_to_le16(1)  /* packets */
+#define IWL_ACTIVE_QUIET_TIME       cpu_to_le16(10)  /* msec */
 
 /* For passive scan, listen PASSIVE_DWELL_TIME (msec) on each channel.
  * Must be set longer than active dwell time.
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index b0ee86c..47cef3e 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -898,7 +898,7 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 		seq_number = priv->stations[sta_id].tid[tid].seq_number;
 		seq_number &= IEEE80211_SCTL_SEQ;
 		hdr->seq_ctrl = hdr->seq_ctrl &
-				__constant_cpu_to_le16(IEEE80211_SCTL_FRAG);
+				cpu_to_le16(IEEE80211_SCTL_FRAG);
 		hdr->seq_ctrl |= cpu_to_le16(seq_number);
 		seq_number += 0x10;
 		/* aggregation is on for this <sta,tid> */
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 95d0198..86f0468 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -1804,14 +1804,14 @@ static void iwl3945_activate_qos(struct iwl3945_priv *priv, u8 force)
  */
 #define MSEC_TO_USEC 1024
 
-#define NOSLP __constant_cpu_to_le32(0)
+#define NOSLP cpu_to_le32(0)
 #define SLP IWL_POWER_DRIVER_ALLOW_SLEEP_MSK
-#define SLP_TIMEOUT(T) __constant_cpu_to_le32((T) * MSEC_TO_USEC)
-#define SLP_VEC(X0, X1, X2, X3, X4) {__constant_cpu_to_le32(X0), \
-				     __constant_cpu_to_le32(X1), \
-				     __constant_cpu_to_le32(X2), \
-				     __constant_cpu_to_le32(X3), \
-				     __constant_cpu_to_le32(X4)}
+#define SLP_TIMEOUT(T) cpu_to_le32((T) * MSEC_TO_USEC)
+#define SLP_VEC(X0, X1, X2, X3, X4) {cpu_to_le32(X0), \
+				     cpu_to_le32(X1), \
+				     cpu_to_le32(X2), \
+				     cpu_to_le32(X3), \
+				     cpu_to_le32(X4)}
 

 /* default power management (not Tx power) table values */
@@ -2028,7 +2028,7 @@ static int iwl3945_scan_cancel_timeout(struct iwl3945_priv *priv, unsigned long
 }
 
 #define MAX_UCODE_BEACON_INTERVAL	1024
-#define INTEL_CONN_LISTEN_INTERVAL	__constant_cpu_to_le16(0xA)
+#define INTEL_CONN_LISTEN_INTERVAL	cpu_to_le16(0xA)
 
 static __le16 iwl3945_adjust_beacon_interval(u16 beacon_val)
 {
@@ -2530,7 +2530,7 @@ static int iwl3945_tx_skb(struct iwl3945_priv *priv, struct sk_buff *skb)
 				IEEE80211_SCTL_SEQ;
 		hdr->seq_ctrl = cpu_to_le16(seq_number) |
 			(hdr->seq_ctrl &
-				__constant_cpu_to_le16(IEEE80211_SCTL_FRAG));
+				cpu_to_le16(IEEE80211_SCTL_FRAG));
 		seq_number += 0x10;
 	}
 
@@ -4696,8 +4696,8 @@ static void iwl3945_free_channel_map(struct iwl3945_priv *priv)
  * time if it's a quiet channel (nothing responded to our probe, and there's
  * no other traffic).
  * Disable "quiet" feature by setting PLCP_QUIET_THRESH to 0. */
-#define IWL_PLCP_QUIET_THRESH       __constant_cpu_to_le16(1)	/* packets */
-#define IWL_ACTIVE_QUIET_TIME       __constant_cpu_to_le16(10)	/* msec */
+#define IWL_PLCP_QUIET_THRESH       cpu_to_le16(1)	/* packets */
+#define IWL_ACTIVE_QUIET_TIME       cpu_to_le16(10)	/* msec */
 
 /* For passive scan, listen PASSIVE_DWELL_TIME (msec) on each channel.
  * Must be set longer than active dwell time.
diff --git a/drivers/net/wireless/orinoco/hermes_dld.c b/drivers/net/wireless/orinoco/hermes_dld.c
index d8c626e..45aed14 100644
--- a/drivers/net/wireless/orinoco/hermes_dld.c
+++ b/drivers/net/wireless/orinoco/hermes_dld.c
@@ -573,9 +573,9 @@ static const struct {							\
 	__le16 id;							\
 	u8 val[length];							\
 } __attribute__ ((packed)) default_pdr_data_##pid = {			\
-	__constant_cpu_to_le16((sizeof(default_pdr_data_##pid)/		\
+	cpu_to_le16((sizeof(default_pdr_data_##pid)/		\
 				sizeof(__le16)) - 1),			\
-	__constant_cpu_to_le16(pid),					\
+	cpu_to_le16(pid),					\
 	data								\
 }
 
diff --git a/drivers/net/wireless/orinoco/orinoco.c b/drivers/net/wireless/orinoco/orinoco.c
index 45a04fa..4dbd003 100644
--- a/drivers/net/wireless/orinoco/orinoco.c
+++ b/drivers/net/wireless/orinoco/orinoco.c
@@ -1332,7 +1332,7 @@ static void orinoco_rx_monitor(struct net_device *dev, u16 rxfid,
 	skb->dev = dev;
 	skb->ip_summed = CHECKSUM_NONE;
 	skb->pkt_type = PACKET_OTHERHOST;
-	skb->protocol = __constant_htons(ETH_P_802_2);
+	skb->protocol = cpu_to_be16(ETH_P_802_2);
 	
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 7175ae8..7eda1b4 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1138,12 +1138,12 @@ ieee80211_data_to_8023(struct ieee80211_rx_data *rx)
 
 	switch (hdr->frame_control &
 		cpu_to_le16(IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) {
-	case __constant_cpu_to_le16(IEEE80211_FCTL_TODS):
+	case cpu_to_le16(IEEE80211_FCTL_TODS):
 		if (unlikely(sdata->vif.type != NL80211_IFTYPE_AP &&
 			     sdata->vif.type != NL80211_IFTYPE_AP_VLAN))
 			return -1;
 		break;
-	case __constant_cpu_to_le16(IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS):
+	case cpu_to_le16(IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS):
 		if (unlikely(sdata->vif.type != NL80211_IFTYPE_WDS &&
 			     sdata->vif.type != NL80211_IFTYPE_MESH_POINT))
 			return -1;
@@ -1157,13 +1157,13 @@ ieee80211_data_to_8023(struct ieee80211_rx_data *rx)
 			}
 		}
 		break;
-	case __constant_cpu_to_le16(IEEE80211_FCTL_FROMDS):
+	case cpu_to_le16(IEEE80211_FCTL_FROMDS):
 		if (sdata->vif.type != NL80211_IFTYPE_STATION ||
 		    (is_multicast_ether_addr(dst) &&
 		     !compare_ether_addr(src, dev->dev_addr)))
 			return -1;
 		break;
-	case __constant_cpu_to_le16(0):
+	case cpu_to_le16(0):
 		if (sdata->vif.type != NL80211_IFTYPE_ADHOC)
 			return -1;
 		break;
-- 
1.6.1.401.gf39d5


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
