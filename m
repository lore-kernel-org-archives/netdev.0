From: "Adam Langley" <agl@imperialviolet.org>
Subject: [PATCH] MD5: don't warn when an unexpected signature is seen.
Date: Tue, 29 Jul 2008 10:36:00 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe069040@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.169]:27502 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752193AbYG2Rit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jul 2008 13:38:49 -0400
Received: by wf-out-1314.google.com with SMTP id 27so6601335wfd.4
        for <netdev@vger.kernel.org>; Tue, 29 Jul 2008 10:38:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, connecting to a listening socket with an MD5 signature option, when
MD5 is not configured on the listening socket, will generate the following
warning:
  MD5 Hash NOT expected but found

This is rate limited, but too verbose given that it can be induced with an
unverified SYN packet.

This patch removes the warning

Signed-off-by: Adam Langley <agl@imperialviolet.org>
---

 net/ipv4/tcp_ipv4.c |    7 +------
 net/ipv6/tcp_ipv6.c |    7 -------
 2 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a2b06d0..8cafa92 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1123,13 +1123,8 @@ static int tcp_v4_inbound_md5_hash(struct sock *sk, struct sk_buff *skb)
 		return 1;
 	}
 
-	if (!hash_expected && hash_location) {
-		LIMIT_NETDEBUG(KERN_INFO "MD5 Hash NOT expected but found "
-			       "(" NIPQUAD_FMT ", %d)->(" NIPQUAD_FMT ", %d)\n",
-			       NIPQUAD(iph->saddr), ntohs(th->source),
-			       NIPQUAD(iph->daddr), ntohs(th->dest));
+	if (!hash_expected && hash_location)
 		return 1;
-	}
 
 	/* Okay, so this is hash_expected and hash_location -
 	 * so we need to calculate the checksum.
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index cff778b..7bb588c 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -853,13 +853,6 @@ static int tcp_v6_inbound_md5_hash (struct sock *sk, struct sk_buff *skb)
 	if (!hash_expected) {
 		if (!hash_location)
 			return 0;
-		if (net_ratelimit()) {
-			printk(KERN_INFO "MD5 Hash NOT expected but found "
-			       "(" NIP6_FMT ", %u)->"
-			       "(" NIP6_FMT ", %u)\n",
-			       NIP6(ip6h->saddr), ntohs(th->source),
-			       NIP6(ip6h->daddr), ntohs(th->dest));
-		}
 		return 1;
 	}
 
