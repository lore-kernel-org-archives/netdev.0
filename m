From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 4/8] net: vxlan: enable local checksum offload
Date: Thu, 11 Feb 2016 20:57:17 +0000
Message-ID: <alpine.LFD.2.20.1602112051000.15537@ec-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:37323 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751099AbcBKU5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 15:57:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/vxlan.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ebf57d9..9f52203 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1702,10 +1702,8 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 		if (csum_start <= VXLAN_MAX_REMCSUM_START &&
 		    !(csum_start & VXLAN_RCO_SHIFT_MASK) &&
 		    (skb->csum_offset == offsetof(struct udphdr, check) ||
-		     skb->csum_offset == offsetof(struct tcphdr, check))) {
-			udp_sum = false;
+		     skb->csum_offset == offsetof(struct tcphdr, check)))
 			type |= SKB_GSO_TUNNEL_REMCSUM;
-		}
 	}
 
 	min_headroom = LL_RESERVED_SPACE(dst->dev) + dst->header_len
@@ -1723,7 +1721,7 @@ static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
 	if (WARN_ON(!skb))
 		return -ENOMEM;
 
-	skb = iptunnel_handle_offloads(skb, udp_sum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
 
