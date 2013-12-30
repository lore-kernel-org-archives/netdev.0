From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 7/11] iwlegacy: use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 19:15:03 +0100
Message-ID: <1388427307-8691-8-git-send-email-Julia.Lawall@lip6.fr>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
used when each argument is an array within a structure that contains at
least two bytes of data beyond the array.

The structures involved are:
ieee80211_hdr defined in include/linux/ieee80211.h,
il_priv defined in drivers/net/wireless/iwlegacy/common.h and
il_rxon_cmd defined in drivers/net/wireless/iwlegacy/commands.h

This was done using Coccinelle (http://coccinelle.lip6.fr/).

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch used is rather long and can be found in message 0 of
this patch series.

 drivers/net/wireless/iwlegacy/3945.c   |    4 ++--
 drivers/net/wireless/iwlegacy/common.c |    8 ++++----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/iwlegacy/3945.c b/drivers/net/wireless/iwlegacy/3945.c
index f09e257..27e543c 100644
--- a/drivers/net/wireless/iwlegacy/3945.c
+++ b/drivers/net/wireless/iwlegacy/3945.c
@@ -466,10 +466,10 @@ il3945_is_network_packet(struct il_priv *il, struct ieee80211_hdr *header)
 	switch (il->iw_mode) {
 	case NL80211_IFTYPE_ADHOC:	/* Header: Dest. | Source    | BSSID */
 		/* packets to our IBSS update information */
-		return ether_addr_equal(header->addr3, il->bssid);
+		return ether_addr_equal_64bits(header->addr3, il->bssid);
 	case NL80211_IFTYPE_STATION:	/* Header: Dest. | AP{BSSID} | Source */
 		/* packets to our IBSS update information */
-		return ether_addr_equal(header->addr2, il->bssid);
+		return ether_addr_equal_64bits(header->addr2, il->bssid);
 	default:
 		return 1;
 	}
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index a27b14c..da4d24d 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -3746,10 +3746,10 @@ il_full_rxon_required(struct il_priv *il)
 
 	/* These items are only settable from the full RXON command */
 	CHK(!il_is_associated(il));
-	CHK(!ether_addr_equal(staging->bssid_addr, active->bssid_addr));
-	CHK(!ether_addr_equal(staging->node_addr, active->node_addr));
-	CHK(!ether_addr_equal(staging->wlap_bssid_addr,
-			      active->wlap_bssid_addr));
+	CHK(!ether_addr_equal_64bits(staging->bssid_addr, active->bssid_addr));
+	CHK(!ether_addr_equal_64bits(staging->node_addr, active->node_addr));
+	CHK(!ether_addr_equal_64bits(staging->wlap_bssid_addr,
+				     active->wlap_bssid_addr));
 	CHK_NEQ(staging->dev_type, active->dev_type);
 	CHK_NEQ(staging->channel, active->channel);
 	CHK_NEQ(staging->air_propagation, active->air_propagation);
