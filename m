From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v2 net-next 4/5] fou: enable LCO in FOU and GUE
Date: Thu, 7 Jan 2016 17:13:16 +0000
Message-ID: <568E9CAC.6070906@solarflare.com>
References: <568E9BF9.2050001@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:36696 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753007AbcAGRNe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 12:13:34 -0500
In-Reply-To: <568E9BF9.2050001@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 net/ipv4/fou.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index e0fcbbb..2b0002f 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -773,7 +773,6 @@ static void fou_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	uh->dest = e->dport;
 	uh->source = sport;
 	uh->len = htons(skb->len);
-	uh->check = 0;
 	udp_set_csum(!(e->flags & TUNNEL_ENCAP_FLAG_CSUM), skb,
 		     fl4->saddr, fl4->daddr, skb->len);
 
@@ -787,7 +786,7 @@ int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 	__be16 sport;
 
-	skb = iptunnel_handle_offloads(skb, csum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
@@ -821,7 +820,7 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 
 	optlen += need_priv ? GUE_LEN_PRIV : 0;
 
-	skb = iptunnel_handle_offloads(skb, csum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
