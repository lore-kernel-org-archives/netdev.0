From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/3] ath6kl: Add missing newlines and coalesce messages
Date: Sun, 17 Jul 2011 11:43:42 -0700
Message-ID: <d539f182b706bb81b65e666bbbee7afdedf3ab72.1310927985.git.joe@perches.com>
References: <cover.1310927985.git.joe@perches.com>
Cc: devel@linuxdriverproject.org, gregkh@suse.de, error27@gmail.com,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Kalle Valo <kvalo@qca.qualcomm.com>, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1310927985.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Logging messages should end in newlines.
Multiple ath6kl_dbg uses should be coalesced where possible.
Convert two otherwise identical format strings to the same case to
save some space.
Use __func__ in a couple of places as appropriate.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath6kl/cfg80211.c |   13 +++++++------
 drivers/net/wireless/ath/ath6kl/debug.c    |    2 +-
 drivers/net/wireless/ath/ath6kl/htc.c      |   18 ++++++++----------
 drivers/net/wireless/ath/ath6kl/init.c     |    5 ++---
 drivers/net/wireless/ath/ath6kl/txrx.c     |   16 ++++++++++------
 drivers/net/wireless/ath/ath6kl/wmi.c      |   21 +++++++++++----------
 6 files changed, 39 insertions(+), 36 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index ab75e0a..f556e23 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -360,8 +360,9 @@ static int ath6kl_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
 		   "%s: connect called with authmode %d dot11 auth %d"
-		   " PW crypto %d PW crypto Len %d GRP crypto %d"
-		   " GRP crypto Len %d channel hint %u\n", __func__,
+		   " PW crypto %d PW crypto len %d GRP crypto %d"
+		   " GRP crypto len %d channel hint %u\n",
+		   __func__,
 		   ar->auth_mode, ar->dot11_auth_mode, ar->prwise_crypto,
 		   ar->prwise_crypto_len, ar->grp_crypto,
 		   ar->grp_crpto_len, ar->ch_hint);
@@ -929,8 +930,7 @@ static int ath6kl_cfg80211_add_key(struct wiphy *wiphy, struct net_device *ndev,
 		del_timer(&ar->disconnect_timer);
 
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
-		   "%s: index %d, key_len %d, key_type 0x%x,"
-		   " key_usage 0x%x, seq_len %d\n",
+		   "%s: index %d, key_len %d, key_type 0x%x, key_usage 0x%x, seq_len %d\n",
 		   __func__, key_index, key->key_len, key_type,
 		   key_usage, key->seq_len);
 
@@ -1348,7 +1348,8 @@ static int ath6kl_cfg80211_join_ibss(struct wiphy *wiphy,
 	ath6kl_dbg(ATH6KL_DBG_WLAN_CFG,
 		   "%s: connect called with authmode %d dot11 auth %d"
 		   " PW crypto %d PW crypto len %d GRP crypto %d"
-		   " GRP crypto len %d channel hint %u\n", __func__,
+		   " GRP crypto len %d channel hint %u\n",
+		   __func__,
 		   ar->auth_mode, ar->dot11_auth_mode, ar->prwise_crypto,
 		   ar->prwise_crypto_len, ar->grp_crypto,
 		   ar->grp_crpto_len, ar->ch_hint);
@@ -1534,7 +1535,7 @@ static int ath6kl_get_station(struct wiphy *wiphy, struct net_device *dev,
 		sinfo->txrate.flags |= RATE_INFO_FLAGS_40_MHZ_WIDTH;
 		sinfo->txrate.flags |= RATE_INFO_FLAGS_MCS;
 	} else {
-		ath6kl_warn("%s: invalid rate: %d", __func__, rate);
+		ath6kl_warn("%s: invalid rate: %d\n", __func__, rate);
 		return 0;
 	}
 
diff --git a/drivers/net/wireless/ath/ath6kl/debug.c b/drivers/net/wireless/ath/ath6kl/debug.c
index ea11e7b..316136c 100644
--- a/drivers/net/wireless/ath/ath6kl/debug.c
+++ b/drivers/net/wireless/ath/ath6kl/debug.c
@@ -97,7 +97,7 @@ void ath6kl_dump_registers(struct ath6kl_device *dev,
 		ath6kl_dbg(ATH6KL_DBG_ANY, "Counter Int status Enable: 0x%x\n",
 			irq_enable_reg->cntr_int_status_en);
 	}
-	ath6kl_dbg(ATH6KL_DBG_ANY, "<------------------------------->");
+	ath6kl_dbg(ATH6KL_DBG_ANY, "<------------------------------->\n");
 }
 
 static void dump_cred_dist(struct htc_endpoint_credit_dist *ep_dist)
diff --git a/drivers/net/wireless/ath/ath6kl/htc.c b/drivers/net/wireless/ath/ath6kl/htc.c
index f4fa8d2..f9b2294 100644
--- a/drivers/net/wireless/ath/ath6kl/htc.c
+++ b/drivers/net/wireless/ath/ath6kl/htc.c
@@ -81,8 +81,8 @@ static void htc_tx_comp_update(struct htc_target *target,
 	if (!packet->status)
 		return;
 
-	ath6kl_err("htc_tx_comp_update: req failed "
-		   "(status:%d, ep:%d, len:%d creds:%d)\n",
+	ath6kl_err("%s: req failed (status:%d, ep:%d, len:%d creds:%d)\n",
+		   __func__,
 		   packet->status, packet->endpoint, packet->act_len,
 		   packet->info.tx.cred_used);
 
@@ -176,9 +176,8 @@ static int htc_issue_send(struct htc_target *target, struct htc_packet *packet)
 
 	send_len = packet->act_len + HTC_HDR_LENGTH;
 
-	ath6kl_dbg(ATH6KL_DBG_HTC_SEND,
-		"htc_issue_send: transmit len : %d (%s)\n",
-		send_len, sync ? "sync" : "async");
+	ath6kl_dbg(ATH6KL_DBG_HTC_SEND, "%s: transmit len : %d (%s)\n",
+		   __func__, send_len, sync ? "sync" : "async");
 
 	padded_len = CALC_TXRX_PADDED_LEN(target->dev, send_len);
 
@@ -233,8 +232,8 @@ static int htc_check_credits(struct htc_target *target,
 
 		if (ep->cred_dist.credits < *req_cred) {
 			ath6kl_dbg(ATH6KL_DBG_HTC_SEND,
-				   "not enough credits for ep %d leaving "
-				   "packet in queue\n", eid);
+				   "not enough credits for ep %d - leaving packet in queue\n",
+				   eid);
 			return -EINVAL;
 		}
 	}
@@ -907,9 +906,8 @@ static int dev_rx_pkt(struct htc_target *target, struct htc_packet *packet,
 	padded_len = CALC_TXRX_PADDED_LEN(dev, rx_len);
 
 	if (padded_len > packet->buf_len) {
-		ath6kl_err("dev_rx_pkt, not enough space for padlen:%d "
-			   "recvlen:%d bufferlen:%d\n",
-			   padded_len, rx_len, packet->buf_len);
+		ath6kl_err("%s: not enough space for padlen:%d recvlen:%d bufferlen:%d\n",
+			   __func__, padded_len, rx_len, packet->buf_len);
 		return -ENOMEM;
 	}
 
diff --git a/drivers/net/wireless/ath/ath6kl/init.c b/drivers/net/wireless/ath/ath6kl/init.c
index 6094e43..dae5442 100644
--- a/drivers/net/wireless/ath/ath6kl/init.c
+++ b/drivers/net/wireless/ath/ath6kl/init.c
@@ -347,9 +347,8 @@ static int ath6kl_set_htc_params(struct ath6kl *ar, u32 mbox_isr_yield_val,
 				(u8 *)&mbox_isr_yield_val,
 				4);
 		if (status) {
-			ath6kl_err("%s: bmi_write_memory for yield "
-				   "limit failed\n",
-				__func__);
+			ath6kl_err("%s: bmi_write_memory for yield limit failed\n",
+				   __func__);
 			goto out;
 		}
 	}
diff --git a/drivers/net/wireless/ath/ath6kl/txrx.c b/drivers/net/wireless/ath/ath6kl/txrx.c
index c9df26a..1125b37 100644
--- a/drivers/net/wireless/ath/ath6kl/txrx.c
+++ b/drivers/net/wireless/ath/ath6kl/txrx.c
@@ -541,10 +541,6 @@ void ath6kl_tx_complete(void *context, struct list_head *packet_queue)
 		if (!status && (packet->act_len != skb->len))
 			goto fatal;
 
-		ath6kl_dbg(ATH6KL_DBG_WLAN_TX,
-			   "%s: skb=0x%p data=0x%p len=0x%x eid=%d ",
-			   __func__, skb, packet->buf, packet->act_len, eid);
-
 		ar->tx_pending[eid]--;
 
 		if (eid != ar->ctrl_ep)
@@ -568,8 +564,16 @@ void ath6kl_tx_complete(void *context, struct list_head *packet_queue)
 			if (status != -ENOSPC)
 				ath6kl_err("%s: tx error, status: 0x%x\n",
 					   __func__, status);
+			ath6kl_dbg(ATH6KL_DBG_WLAN_TX,
+				   "%s: skb=0x%p data=0x%p len=0x%x eid=%d %s\n",
+				   __func__, skb, packet->buf, packet->act_len,
+				   eid, "error!");
 		} else {
-			ath6kl_dbg(ATH6KL_DBG_WLAN_TX, "OK\n");
+			ath6kl_dbg(ATH6KL_DBG_WLAN_TX,
+				   "%s: skb=0x%p data=0x%p len=0x%x eid=%d %s\n",
+				   __func__, skb, packet->buf, packet->act_len,
+				   eid, "OK");
+
 			flushing = false;
 			ar->net_stats.tx_packets++;
 			ar->net_stats.tx_bytes += skb->len;
@@ -640,7 +644,7 @@ static void ath6kl_alloc_netbufs(struct sk_buff_head *q, u16 num)
 	while (num) {
 		skb = ath6kl_buf_alloc(ATH6KL_BUFFER_SIZE);
 		if (!skb) {
-			ath6kl_err("%s: netbuf allocation failed", __func__);
+			ath6kl_err("%s: netbuf allocation failed\n", __func__);
 			return;
 		}
 		skb_queue_tail(q, skb);
diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index 38270bb..5d95b56 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -570,11 +570,11 @@ static int ath6kl_wmi_peer_node_event_rx(struct wmi *wmi, u8 *datap, int len)
 	ev = (struct wmi_peer_node_event *) datap;
 
 	if (ev->event_code == PEER_NODE_JOIN_EVENT)
-		ath6kl_dbg(ATH6KL_DBG_WMI, "joined node with mac addr: %pM",
-			ev->peer_mac_addr);
+		ath6kl_dbg(ATH6KL_DBG_WMI, "joined node with mac addr: %pM\n",
+			   ev->peer_mac_addr);
 	else if (ev->event_code == PEER_NODE_LEAVE_EVENT)
-		ath6kl_dbg(ATH6KL_DBG_WMI, "left node with mac addr: %pM",
-			ev->peer_mac_addr);
+		ath6kl_dbg(ATH6KL_DBG_WMI, "left node with mac addr: %pM\n",
+			   ev->peer_mac_addr);
 
 	return 0;
 }
@@ -1027,24 +1027,25 @@ static int ath6kl_wmi_scan_complete_rx(struct wmi *wmi, u8 *datap, int len)
  */
 static int ath6kl_wmi_error_event_rx(struct wmi *wmi, u8 *datap, int len)
 {
+	const char *type = "unknown error";
 	struct wmi_cmd_error_event *ev;
-
 	ev = (struct wmi_cmd_error_event *) datap;
 
-	ath6kl_dbg(ATH6KL_DBG_WMI, "programming error, cmd=%d ", ev->cmd_id);
-
 	switch (ev->err_code) {
 	case INVALID_PARAM:
-		ath6kl_dbg(ATH6KL_DBG_WMI, "illegal parameter\n");
+		type = "invalid parameter";
 		break;
 	case ILLEGAL_STATE:
-		ath6kl_dbg(ATH6KL_DBG_WMI, "illegal state\n");
+		type = "invalid state";
 		break;
 	case INTERNAL_ERROR:
-		ath6kl_dbg(ATH6KL_DBG_WMI, "internal error\n");
+		type = "internal error";
 		break;
 	}
 
+	ath6kl_dbg(ATH6KL_DBG_WMI, "programming error, cmd=%d %s\n",
+		   ev->cmd_id, type);
+
 	return 0;
 }
 
-- 
1.7.6.131.g99019
