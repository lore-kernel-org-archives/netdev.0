From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] pktgen: Use ip_send_check() to compute checksum
Date: Thu, 25 Jul 2013 14:08:04 +0200
Message-ID: <54f9ca8fb7748c23eec49ad0fa055f2036cde5b7.1374753893.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:36384 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755386Ab3GYMIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 08:08:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/core/pktgen.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 929eb7b..2b3a74e 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -2755,8 +2755,7 @@ static struct sk_buff *fill_packet_ipv4(struct net_device *odev,
 	iph->frag_off = 0;
 	iplen = 20 + 8 + datalen;
 	iph->tot_len = htons(iplen);
-	iph->check = 0;
-	iph->check = ip_fast_csum((void *)iph, iph->ihl);
+	ip_send_check(iph);
 	skb->protocol = protocol;
 	skb->dev = odev;
 	skb->pkt_type = PACKET_HOST;
-- 
1.8.3.1
