From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make sta_rx_agg_session_timer_expired() static
Date: Mon, 21 Apr 2008 11:47:51 +0300
Message-ID: <20080421084751.GI26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Ron Rindjunsky <ron.rindjunsky@intel.com>,
	Tomas Winkler <tomas.winkler@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:40987 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754620AbYDUIsT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:48:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sta_rx_agg_session_timer_expired() can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 net/mac80211/ieee80211_i.h |    1 -
 net/mac80211/mlme.c        |    3 ++-
 2 files changed, 2 insertions(+), 2 deletions(-)

64e9b87bbd66ecaad44e27fe3b02ea465d4be36d diff --git a/net/mac80211/ieee80211_i.h b/net/mac80211/ieee80211_i.h
index 8e53ce7..a202cb6 100644
--- a/net/mac80211/ieee80211_i.h
+++ b/net/mac80211/ieee80211_i.h
@@ -940,7 +940,6 @@ void ieee80211_send_delba(struct net_device *dev, const u8 *da, u16 tid,
 
 void ieee80211_sta_stop_rx_ba_session(struct net_device *dev, u8 *da,
 				u16 tid, u16 initiator, u16 reason);
-void sta_rx_agg_session_timer_expired(unsigned long data);
 void sta_addba_resp_timer_expired(unsigned long data);
 void ieee80211_sta_tear_down_BA_sessions(struct net_device *dev, u8 *addr);
 u64 ieee80211_sta_get_rates(struct ieee80211_local *local,
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 6b75cb6..43bcfe5 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -87,6 +87,7 @@ static int ieee80211_sta_start_scan(struct net_device *dev,
 				    u8 *ssid, size_t ssid_len);
 static int ieee80211_sta_config_auth(struct net_device *dev,
 				     struct ieee80211_if_sta *ifsta);
+static void sta_rx_agg_session_timer_expired(unsigned long data);
 
 
 void ieee802_11_parse_elems(u8 *start, size_t len,
@@ -1616,7 +1617,7 @@ timer_expired_exit:
  * resetting it after each frame that arrives from the originator.
  * if this timer expires ieee80211_sta_stop_rx_ba_session will be executed.
  */
-void sta_rx_agg_session_timer_expired(unsigned long data)
+static void sta_rx_agg_session_timer_expired(unsigned long data)
 {
 	/* not an elegant detour, but there is no choice as the timer passes
 	 * only one argument, and verious sta_info are needed here, so init

