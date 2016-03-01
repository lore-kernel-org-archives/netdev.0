From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [net-next 3/4] mac80211: use reset to set header pointer
Date: Tue,  1 Mar 2016 09:27:37 +0000
Message-ID: <1456824458-19499-4-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1456824458-19499-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: davem@davemloft.net, kvalo@codeaurora.org,
	johannes@sipsolutions.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta1.chinamobile.com ([221.176.66.79]:5358 "EHLO
	cmccmta1.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752700AbcCAJ0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 04:26:37 -0500
In-Reply-To: <1456824458-19499-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since offset is zeor, it's not necessary to use set function. Reset
function is straightforward, and will remove the unnecessary add
operation in set function.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 net/mac80211/mesh_hwmp.c | 6 +++---
 net/mac80211/rx.c        | 2 +-
 net/mac80211/status.c    | 2 +-
 net/mac80211/tx.c        | 8 ++++----
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/mac80211/mesh_hwmp.c b/net/mac80211/mesh_hwmp.c
index c6be0b4..5b6aec1 100644
--- a/net/mac80211/mesh_hwmp.c
+++ b/net/mac80211/mesh_hwmp.c
@@ -205,9 +205,9 @@ static void prepare_frame_for_deferred_tx(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_tx_info *info = IEEE80211_SKB_CB(skb);
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 
-	skb_set_mac_header(skb, 0);
-	skb_set_network_header(skb, 0);
-	skb_set_transport_header(skb, 0);
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
 
 	/* Send all internal mgmt frames on VO. Accordingly set TID to 7. */
 	skb_set_queue_mapping(skb, IEEE80211_AC_VO);
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index bc08185..188e260 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -3073,7 +3073,7 @@ static void ieee80211_rx_cooked_monitor(struct ieee80211_rx_data *rx,
 	ieee80211_add_rx_radiotap_header(local, skb, rate, needed_headroom,
 					 false);
 
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->protocol = htons(ETH_P_802_2);
diff --git a/net/mac80211/status.c b/net/mac80211/status.c
index 6101deb..8b1b2ea 100644
--- a/net/mac80211/status.c
+++ b/net/mac80211/status.c
@@ -697,7 +697,7 @@ void ieee80211_tx_monitor(struct ieee80211_local *local, struct sk_buff *skb,
 					 rtap_len, shift);
 
 	/* XXX: is this sufficient for BPF? */
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	skb->pkt_type = PACKET_OTHERHOST;
 	skb->protocol = htons(ETH_P_802_2);
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index 3311ce0..5fcf025 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2380,7 +2380,7 @@ static struct sk_buff *ieee80211_build_hdr(struct ieee80211_sub_if_data *sdata,
 	/* Update skb pointers to various headers since this modified frame
 	 * is going to go through Linux networking code that may potentially
 	 * need things like pointer to IP header. */
-	skb_set_mac_header(skb, 0);
+	skb_reset_mac_header(skb);
 	skb_set_network_header(skb, nh_pos);
 	skb_set_transport_header(skb, h_pos);
 
@@ -3895,9 +3895,9 @@ void __ieee80211_tx_skb_tid_band(struct ieee80211_sub_if_data *sdata,
 {
 	int ac = ieee802_1d_to_ac[tid & 7];
 
-	skb_set_mac_header(skb, 0);
-	skb_set_network_header(skb, 0);
-	skb_set_transport_header(skb, 0);
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
 
 	skb_set_queue_mapping(skb, ac);
 	skb->priority = tid;
-- 
1.8.3.1
