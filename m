From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/11] ath5k: use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 19:14:58 +0100
Message-ID: <1388427307-8691-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Nick Kossifidis <mickflemm@gmail.com>,
	"Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath5k-devel@lists.ath5k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jiri Slaby <jirislaby@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
used when each argument is an array within a structure that contains at
least two bytes of data beyond the array.

The structures involved are:
ieee80211_mgmt defined in include/linux/ieee80211.h and
ath_common defined in drivers/net/wireless/ath/ath.h

This was done using Coccinelle (http://coccinelle.lip6.fr/).

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch used is rather long and can be found in message 0 of
this patch series.

 drivers/net/wireless/ath/ath5k/base.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index 69f58b0..6396ad4 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -1245,7 +1245,7 @@ ath5k_check_ibss_tsf(struct ath5k_hw *ah, struct sk_buff *skb,
 
 	if (ieee80211_is_beacon(mgmt->frame_control) &&
 	    le16_to_cpu(mgmt->u.beacon.capab_info) & WLAN_CAPABILITY_IBSS &&
-	    ether_addr_equal(mgmt->bssid, common->curbssid)) {
+	    ether_addr_equal_64bits(mgmt->bssid, common->curbssid)) {
 		/*
 		 * Received an IBSS beacon with the same BSSID. Hardware *must*
 		 * have updated the local TSF. We have to work around various
@@ -1309,7 +1309,7 @@ ath5k_update_beacon_rssi(struct ath5k_hw *ah, struct sk_buff *skb, int rssi)
 
 	/* only beacons from our BSSID */
 	if (!ieee80211_is_beacon(mgmt->frame_control) ||
-	    !ether_addr_equal(mgmt->bssid, common->curbssid))
+	    !ether_addr_equal_64bits(mgmt->bssid, common->curbssid))
 		return;
 
 	ewma_add(&ah->ah_beacon_rssi_avg, rssi);
