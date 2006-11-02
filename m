From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 6/6] IPv6: Fix infinite loop if no matching IPv6 tunnel found
Date: Thu, 02 Nov 2006 13:39:19 +0200
Message-ID: <4549D8E7.1040409@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030400080504010906010702"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:60553 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1750830AbWKBLj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 06:39:28 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030400080504010906010702
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


--------------030400080504010906010702
Content-Type: text/plain;
 name*0="0006-IPv6-Fix-infinite-loop-if-no-matching-IPv6-tunnel-found.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0006-IPv6-Fix-infinite-loop-if-no-matching-IPv6-tunnel-found";
 filename*1=".txt"

>From d9ecea2b1d88bc8702f70fbbca7cde2afb8312ee Mon Sep 17 00:00:00 2001
From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Date: Thu, 2 Nov 2006 13:07:35 +0200
Subject: [PATCH 6/6] IPv6: Fix infinite loop if no matching IPv6 tunnel found

If no matching IPv6 tunnel was found ip6ip6_rcv() would cause
ip6_input_finish() to resubmit the same skb to ip6ip6_rcv().

Many thanks to Tero Kauppinen at Ericsson for reporting this issue.

Signed-off-by: Ville Nuorvala <vnuorval@tcs.hut.fi>
---
 net/ipv6/ip6_tunnel.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 4f64ed7..603ed0d 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -565,11 +565,11 @@ ip6ip6_rcv(struct sk_buff *skb)
 		return 0;
 	}
 	read_unlock(&ip6ip6_lock);
-	return 1;
-
+	icmpv6_send(skb, ICMPV6_DEST_UNREACH,
+		    ICMPV6_ADDR_UNREACH, 0, skb->dev);
 discard:
 	kfree_skb(skb);
-	return 0;
+	return -1;
 }
 
 struct ipv6_tel_txoption {
-- 
1.4.3.2


--------------030400080504010906010702--
