From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 7/8] net: bridge: fix sign bug
Date: Thu, 15 Jul 2010 22:47:33 +0400
Message-ID: <1279219653-12791-1-git-send-email-segooon@gmail.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:45460 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934126Ab0GOSsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jul 2010 14:48:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipv6_skip_exthdr() can return error code that is below zero.
'offset' is unsigned, so it makes no sense.
ipv6_skip_exthdr() returns 'int' so we can painlessly change type of
offset to int.

Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>
---
 net/bridge/br_multicast.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 27ae946..85afcda 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1435,7 +1435,7 @@ static int br_multicast_ipv6_rcv(struct net_bridge *br,
 	struct icmp6hdr *icmp6h;
 	u8 nexthdr;
 	unsigned len;
-	unsigned offset;
+	int offset;
 	int err;
 
 	if (!pskb_may_pull(skb, sizeof(*ip6h)))
-- 
1.7.0.4

