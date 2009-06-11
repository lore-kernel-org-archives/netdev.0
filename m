From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: ntohs() misuse
Date: Thu, 11 Jun 2009 21:23:15 +0200
Message-ID: <4A3159A3.1070504@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41738 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760709AbZFKTXP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 15:23:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some drivers incorrectly use ntohs() instead of htons()

A cleanup as htons() returns same result than ntohs(),
but better to use the proper one.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/atl1e/atl1e_main.c |    4 ++--
 drivers/net/atlx/atl1.c        |    2 +-
 drivers/net/ioc3-eth.c         |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index e1ae10c..9fc6d6d 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1602,7 +1602,7 @@ static u16 atl1e_cal_tdp_req(const struct sk_buff *skb)
 	}
 
 	if (skb_is_gso(skb)) {
-		if (skb->protocol == ntohs(ETH_P_IP) ||
+		if (skb->protocol == htons(ETH_P_IP) ||
 		   (skb_shinfo(skb)->gso_type == SKB_GSO_TCPV6)) {
 			proto_hdr_len = skb_transport_offset(skb) +
 					tcp_hdrlen(skb);
@@ -1878,7 +1878,7 @@ static int atl1e_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 				TPD_VLAN_SHIFT;
 	}
 
-	if (skb->protocol == ntohs(ETH_P_8021Q))
+	if (skb->protocol == htons(ETH_P_8021Q))
 		tpd->word3 |= 1 << TPD_VL_TAGGED_SHIFT;
 
 	if (skb_network_offset(skb) != ETH_HLEN)
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 560f387..94d7325 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2382,7 +2382,7 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	mss = skb_shinfo(skb)->gso_size;
 	if (mss) {
-		if (skb->protocol == ntohs(ETH_P_IP)) {
+		if (skb->protocol == htons(ETH_P_IP)) {
 			proto_hdr_len = (skb_transport_offset(skb) +
 					 tcp_hdrlen(skb));
 			if (unlikely(proto_hdr_len > len)) {
diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index c5593f4..e3cfefa 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -530,7 +530,7 @@ static void ioc3_tcpudp_checksum(struct sk_buff *skb, uint32_t hwsum, int len)
 	 *   case where the checksum is right the higher layers will still
 	 *   drop the packet as appropriate.
 	 */
-	if (eh->h_proto != ntohs(ETH_P_IP))
+	if (eh->h_proto != htons(ETH_P_IP))
 		return;
 
 	ih = (struct iphdr *) ((char *)eh + ETH_HLEN);
