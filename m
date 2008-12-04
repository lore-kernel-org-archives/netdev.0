From: Martin Willi <martin@strongswan.org>
Subject: [PATCH] xfrm: Accept ESP packets regardless of UDP encapsulation  mode
Date: Thu, 04 Dec 2008 14:18:50 +0100
Message-ID: <1228396731.1643.57.camel@martin>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.km23152-01.keymachine.de ([87.118.114.125]:34971 "EHLO
	km23152-01.keymachine.de" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752196AbYLDNTT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 08:19:19 -0500
Received: from localhost (km23152-01.keymachine.de [127.0.0.1])
	by km23152-01.keymachine.de (Postfix) with SMTP id CC9E32F18142
	for <netdev@vger.kernel.org>; Thu,  4 Dec 2008 11:18:56 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An IPsec node speaking IKEv2 MUST accept incoming UDP encapsulated
ESP packets, even if no NAT situation is detected. This is important
if MOBIKE is in use. Some implementation keep the encapsulation
mode if they move out of a NAT situation.

diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index b4a1317..65bcf09 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -167,11 +167,6 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop_unlock;
 		}
 
-		if ((x->encap ? x->encap->encap_type : 0) != encap_type) {
-			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMISMATCH);
-			goto drop_unlock;
-		}
-
 		if (x->props.replay_window && xfrm_replay_check(x, skb, seq)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATESEQERROR);
 			goto drop_unlock;
-- 
1.5.6.3



