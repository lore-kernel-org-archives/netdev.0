From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ip_tunnel: Remove gratuitous skb scrubbing
Date: Wed, 15 Apr 2015 18:01:07 +0800
Message-ID: <20150415100107.GA3655@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:35885 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755356AbbDOKBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 06:01:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
harmonize cleanup done on skb on rx path") broke anyone trying to
use netfilter marking across IPv4 tunnels.  As the commit message
did not give any justification for this (in fact it shouldn't
even be touching the tx path), I can only assume that it was a typo.

This patch reverts that change.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 88c386c..709e711 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -54,7 +54,8 @@ int iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	struct iphdr *iph;
 	int err;
 
-	skb_scrub_packet(skb, xnet);
+	if (xnet)
+		skb_scrub_packet(skb, true);
 
 	skb_clear_hash(skb);
 	skb_dst_set(skb, &rt->dst);
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
