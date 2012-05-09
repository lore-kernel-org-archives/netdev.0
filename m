From: Joe Perches <joe@perches.com>
Subject: [PATCH 12/13] wireless: Convert compare_ether_addr to ether_addr_equal by hand
Date: Tue,  8 May 2012 21:56:56 -0700
Message-ID: <173dcbff1655387845a430508dcf686cc35af1bb.1336538938.git.joe@perches.com>
References: <cover.1336538937.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1336538937.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

spatch/coccinelle isn't perfect.  It doesn't understand
__aligned(x) and doesn't convert functions it can't parse.

Convert the remaining compare_ether_addr uses.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/wireless/util.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/wireless/util.c b/net/wireless/util.c
index 3ba366f..1cd2558 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -370,7 +370,7 @@ int ieee80211_data_to_8023(struct sk_buff *skb, const u8 *addr,
 		     iftype != NL80211_IFTYPE_P2P_CLIENT &&
 		     iftype != NL80211_IFTYPE_MESH_POINT) ||
 		    (is_multicast_ether_addr(dst) &&
-		     !compare_ether_addr(src, addr)))
+		     ether_addr_equal(src, addr)))
 			return -1;
 		if (iftype == NL80211_IFTYPE_MESH_POINT) {
 			struct ieee80211s_hdr *meshdr =
@@ -398,9 +398,9 @@ int ieee80211_data_to_8023(struct sk_buff *skb, const u8 *addr,
 	payload = skb->data + hdrlen;
 	ethertype = (payload[6] << 8) | payload[7];
 
-	if (likely((compare_ether_addr(payload, rfc1042_header) == 0 &&
+	if (likely((ether_addr_equal(payload, rfc1042_header) &&
 		    ethertype != ETH_P_AARP && ethertype != ETH_P_IPX) ||
-		   compare_ether_addr(payload, bridge_tunnel_header) == 0)) {
+		   ether_addr_equal(payload, bridge_tunnel_header))) {
 		/* remove RFC1042 or Bridge-Tunnel encapsulation and
 		 * replace EtherType */
 		skb_pull(skb, hdrlen + 6);
-- 
1.7.8.111.gad25c.dirty
