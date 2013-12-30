From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 8/11]  use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 19:15:04 +0100
Message-ID: <1388427307-8691-9-git-send-email-Julia.Lawall@lip6.fr>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
used when each argument is an array within a structure that contains at
least two bytes of data beyond the array.

The structures involved are:
ieee80211_hdr defined in include/linux/ieee80211.h
ath_common defined in drivers/net/wireless/ath/ath.h

This was done using Coccinelle (http://coccinelle.lip6.fr/).

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch used is rather long and can be found in message 0 of
this patch series.

 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c         |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
index c028df7..b41e008 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -1077,7 +1077,7 @@ static bool ath9k_rx_prepare(struct ath9k_htc_priv *priv,
 
 	if (ieee80211_is_beacon(hdr->frame_control) &&
 	    !is_zero_ether_addr(common->curbssid) &&
-	    ether_addr_equal(hdr->addr3, common->curbssid)) {
+	    ether_addr_equal_64bits(hdr->addr3, common->curbssid)) {
 		s8 rssi = rxbuf->rxstatus.rs_rssi;
 
 		if (likely(last_rssi != ATH_RSSI_DUMMY_MARKER))
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/ath/ath9k/recv.c
index 3692b2a..0152318 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -982,7 +982,7 @@ static bool ath9k_is_mybeacon(struct ath_softc *sc, struct ieee80211_hdr *hdr)
 	if (ieee80211_is_beacon(hdr->frame_control)) {
 		RX_STAT_INC(rx_beacons);
 		if (!is_zero_ether_addr(common->curbssid) &&
-		    ether_addr_equal(hdr->addr3, common->curbssid))
+		    ether_addr_equal_64bits(hdr->addr3, common->curbssid))
 			return true;
 	}
 
