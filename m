From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 08/11] bridge: skb_put_zero() used to optimize code
Date: Wed, 14 Jun 2017 22:55:34 +0800
Message-ID: <1497452134-4867-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:35983 "EHLO m12-15.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751800AbdFNO4R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Jun 2017 10:56:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 net/bridge/netfilter/nft_reject_bridge.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index c16dd3a..22a52d5 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -147,8 +147,7 @@ static void nft_reject_br_send_v4_unreach(struct net *net,
 				   net->ipv4.sysctl_ip_default_ttl);
 
 	skb_reset_transport_header(nskb);
-	icmph = (struct icmphdr *)skb_put(nskb, sizeof(struct icmphdr));
-	memset(icmph, 0, sizeof(*icmph));
+	icmph = (struct icmphdr *)skb_put_zero(nskb, sizeof(struct icmphdr));
 	icmph->type     = ICMP_DEST_UNREACH;
 	icmph->code	= code;
 
@@ -275,8 +274,7 @@ static void nft_reject_br_send_v6_unreach(struct net *net,
 				     net->ipv6.devconf_all->hop_limit);
 
 	skb_reset_transport_header(nskb);
-	icmp6h = (struct icmp6hdr *)skb_put(nskb, sizeof(struct icmp6hdr));
-	memset(icmp6h, 0, sizeof(*icmp6h));
+	icmp6h = (struct icmp6hdr *)skb_put_zero(nskb, sizeof(struct icmp6hdr));
 	icmp6h->icmp6_type = ICMPV6_DEST_UNREACH;
 	icmp6h->icmp6_code = code;
 
-- 
2.7.4
