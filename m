From: Sonic Zhang <sonic.adi@gmail.com>
Subject: [PATCH] bug[#43]: kgdboe: netpoll: Should handle ETH_P_ARP other than ETH_P_IP in netpoll_neigh_reply
Date: Wed, 11 Sep 2013 11:31:53 +0800
Message-ID: <1378870313-14161-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adi-buildroot-devel@lists.sourceforge.net>,
	Sonic Zhang <sonic.zhang@analog.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.187] ([216.32.180.187]:41794 "EHLO
	co1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752605Ab3IKDYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 23:24:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

The received ARP request type in the Ethernet packet head is ETH_P_ARP other than ETH_P_IP.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
---
 net/core/netpoll.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 2c637e9..c3c7b27 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -550,7 +550,7 @@ static void netpoll_neigh_reply(struct sk_buff *skb, struct netpoll_info *npinfo
 		return;
 
 	proto = ntohs(eth_hdr(skb)->h_proto);
-	if (proto == ETH_P_IP) {
+	if (proto == ETH_P_ARP) {
 		struct arphdr *arp;
 		unsigned char *arp_ptr;
 		/* No arp on this interface */
-- 
1.8.2.3
