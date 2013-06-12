From: Calvin Owens <jcalvinowens@gmail.com>
Subject: [PATCH] mac80211: Use RCU protection in ieee80211_get_tx_rates()
Date: Wed, 12 Jun 2013 03:00:42 -0500
Message-ID: <20130612080042.GA1695@gmail.com>
References: <20130609225120.GA2789@gmail.com>
 <20130610042959.GA1902@gmail.com>
 <1370950926.8356.14.camel@jlt4.sipsolutions.net>
 <20130611171304.GA2189@gmail.com>
 <1370980523.8356.70.camel@jlt4.sipsolutions.net>
 <20130612075634.GA1649@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Felix Fietkau <nbd@openwrt.org>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, netdev@vger.kernel.org,
	jcalvinowens@gmail.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130612075634.GA1649@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Copying the rate table should be done in an RCU read-side critical
section.

Signed-off-by: Calvin Owens <jcalvinowens@gmail.com>
---
 net/mac80211/rate.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index d3f414f..090d9b0 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -538,6 +538,8 @@ static void rate_control_fill_sta_table(struct ieee80211_sta *sta,
 	struct ieee80211_sta_rates *ratetbl = NULL;
 	int i;
 
+	rcu_read_lock();
+
 	if (sta && !info->control.skip_table)
 		ratetbl = rcu_dereference(sta->rates);
 
@@ -566,6 +568,8 @@ static void rate_control_fill_sta_table(struct ieee80211_sta *sta,
 		if (rates[i].idx < 0 || !rates[i].count)
 			break;
 	}
+
+	rcu_read_unlock();
 }
 
 static void rate_control_apply_mask(struct ieee80211_sub_if_data *sdata,
-- 
1.8.2.1
