From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] udp: fix a typo in __udp4_lib_mcast_demux_lookup
Date: Tue, 08 Oct 2013 21:47:29 -0700
Message-ID: <1381294049.4971.3.camel@edumazet-glaptop.roam.corp.google.com>
References: <1381161700-14453-1-git-send-email-shawn.bohrer@gmail.com>
	 <20131008.165147.1204109363656237950.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: shawn.bohrer@gmail.com, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, sbohrer@rgmadvisors.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:48037 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042Ab3JIErc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 00:47:32 -0400
Received: by mail-pa0-f53.google.com with SMTP id kq14so458257pab.40
        for <netdev@vger.kernel.org>; Tue, 08 Oct 2013 21:47:32 -0700 (PDT)
In-Reply-To: <20131008.165147.1204109363656237950.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

At this point sk might contain garbage.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 4226c53..9f27bb8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1847,7 +1847,7 @@ begin:
 		if (count != 1 ||
 		    unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
 			result = NULL;
-		else if (unlikely(!__udp_is_mcast_sock(net, sk,
+		else if (unlikely(!__udp_is_mcast_sock(net, result,
 						       loc_port, loc_addr,
 						       rmt_port, rmt_addr,
 						       dif, hnum))) {
