From: Joe Perches <joe@perches.com>
Subject: [PATCH net-2.6.25 3/8] net/core: Use ipv4_is_<type>
Date: Thu, 13 Dec 2007 15:38:56 -0800
Message-ID: <1197589141-7020-3-git-send-email-joe@perches.com>
References: <1197589141-7020-1-git-send-email-joe@perches.com>
 <1197589141-7020-2-git-send-email-joe@perches.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4212 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755224AbXLMXjF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Dec 2007 18:39:05 -0500
Received: from localhost.localdomain (192-168-1-128.LABridge.com [192.168.1.128] (may be forged))
	by perches.com (8.9.3/8.9.3) with ESMTP id OAA17669
	for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 14:52:22 -0800
In-Reply-To: <1197589141-7020-2-git-send-email-joe@perches.com>
Message-Id: <63aaea4664a57e3b9a0b7454da94e72b6d462e22.1197432867.git.joe@perches.com>
In-Reply-To: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
References: <e2ebcbf24539c0a3ef2ac77147dbfa55d8ac9e33.1197432867.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/netpoll.c |    3 ++-
 net/core/pktgen.c  |    8 +++++---
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index b1d5acd..6faa128 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -410,7 +410,8 @@ static void arp_reply(struct sk_buff *skb)
 	memcpy(&tip, arp_ptr, 4);
 
 	/* Should we ignore arp? */
-	if (tip != htonl(np->local_ip) || LOOPBACK(tip) || MULTICAST(tip))
+	if (tip != htonl(np->local_ip) ||
+	    ipv4_is_loopback(tip) || ipv4_is_multicast(tip))
 		return;
 
 	size = sizeof(struct arphdr) + 2 * (skb->dev->addr_len + 4);
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 285ec3e..ede1fea 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2358,9 +2358,11 @@ static void mod_cur_headers(struct pktgen_dev *pkt_dev)
 					t = random32() % (imx - imn) + imn;
 					s = htonl(t);
 
-					while (LOOPBACK(s) || MULTICAST(s)
-					       || BADCLASS(s) || ZERONET(s)
-					       || LOCAL_MCAST(s)) {
+					while (ipv4_is_loopback(s) ||
+					       ipv4_is_multicast(s) ||
+					       ipv4_is_badclass(s) ||
+					       ipv4_is_zeronet(s) ||
+					       ipv4_is_local_multicast(s)) {
 						t = random32() % (imx - imn) + imn;
 						s = htonl(t);
 					}
-- 
1.5.3.7.949.g2221a6

