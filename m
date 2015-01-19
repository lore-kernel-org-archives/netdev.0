From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 6/7] r8152: replace get_protocol with vlan_get_protocol
Date: Mon, 19 Jan 2015 15:13:36 +0800
Message-ID: <1394712342-15778-124-Taiwan-albertk@realtek.com>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-118-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vlan_get_protocol() has been defined and use it to replace
get_protocol().

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f66ffbd..46440ed 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1342,18 +1342,6 @@ static struct tx_agg *r8152_get_tx_agg(struct r8152 *tp)
 	return agg;
 }
 
-static inline __be16 get_protocol(struct sk_buff *skb)
-{
-	__be16 protocol;
-
-	if (skb->protocol == htons(ETH_P_8021Q))
-		protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
-	else
-		protocol = skb->protocol;
-
-	return protocol;
-}
-
 /* r8152_csum_workaround()
  * The hw limites the value the transport offset. When the offset is out of the
  * range, calculate the checksum by sw.
@@ -1459,7 +1447,7 @@ static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,
 			goto unavailable;
 		}
 
-		switch (get_protocol(skb)) {
+		switch (vlan_get_protocol(skb)) {
 		case htons(ETH_P_IP):
 			opts1 |= GTSENDV4;
 			break;
@@ -1490,7 +1478,7 @@ static int r8152_tx_csum(struct r8152 *tp, struct tx_desc *desc,
 			goto unavailable;
 		}
 
-		switch (get_protocol(skb)) {
+		switch (vlan_get_protocol(skb)) {
 		case htons(ETH_P_IP):
 			opts2 |= IPV4_CS;
 			ip_protocol = ip_hdr(skb)->protocol;
-- 
2.1.0
