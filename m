From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH wireless-dev] d80211: Don't discriminate against 802.11b
 drivers
Date: Thu, 11 May 2006 17:54:26 +0200
Message-ID: <20060511175426.72ae7744@griffin.suse.cz>
References: <200605042232.35446.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Jouni Malinen" <jkm@devicescape.com>, netdev@vger.kernel.org,
	jkmaline@cc.hut.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:64139 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1030290AbWEKPy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 11:54:28 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200605042232.35446.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 4 May 2006 22:32:35 -0400, Michael Wu wrote:
> This makes the current hack used to prevent 802.11g cards from scanning with 
> 802.11b channels not break scanning in 802.11b drivers.

I think this should be better:

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c     |   14 ++++++++++++++
 net/d80211/ieee80211_sta.c |    1 -
 2 files changed, 14 insertions(+), 1 deletion(-)

--- dscape.orig/net/d80211/ieee80211.c
+++ dscape/net/d80211/ieee80211.c
@@ -4014,6 +4014,19 @@ static void ieee80211_precalc_rates(stru
 	}
 }
 
+static inline void ieee80211_apply_modes(struct ieee80211_hw *hw,
+					 struct ieee80211_local *local)
+{
+	struct ieee80211_hw_modes *mode;
+	int i;
+
+	local->scan_skip_11b = 0;
+	for (i = 0; i < hw->num_modes; i++) {
+		mode = &hw->modes[i];
+		if (mode->mode == MODE_IEEE80211G)
+			local->scan_skip_11b = 1;
+	}
+}
 
 struct net_device *ieee80211_alloc_hw(size_t priv_data_len,
 				      void (*setup)(struct net_device *))
@@ -4258,6 +4271,7 @@ int ieee80211_update_hw(struct net_devic
 		return -1;
 
 	ieee80211_precalc_rates(hw);
+	ieee80211_apply_modes(hw, local);
 	local->conf.phymode = hw->modes[0].mode;
 	local->curr_rates = hw->modes[0].rates;
 	local->num_curr_rates = hw->modes[0].num_rates;
--- dscape.orig/net/d80211/ieee80211_sta.c
+++ dscape/net/d80211/ieee80211_sta.c
@@ -2566,7 +2566,6 @@ int ieee80211_sta_req_scan(struct net_de
 		memcpy(local->scan_ssid, ssid, ssid_len);
 	} else
 		local->scan_ssid_len = 0;
-	local->scan_skip_11b = 1; /* FIX: clear this is 11g is not supported */
 	local->scan_state = SCAN_SET_CHANNEL;
 	local->scan_hw_mode_idx = 0;
 	local->scan_channel_idx = 0;


-- 
Jiri Benc
SUSE Labs
