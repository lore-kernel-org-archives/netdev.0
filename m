From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 6/6] openvswitch: Compute checksum in skb_gso_segment() if needed
Date: Fri, 13 Dec 2013 15:22:22 +0100
Message-ID: <4220a182739328641da98ef62f7b7699c3459c88.1386943635.git.tgraf@suug.ch>
References: <cover.1386943635.git.tgraf@suug.ch>
Cc: dev@openvswitch.org, eric.dumazet@gmail.com, fleitner@redhat.com,
	ffusco@redhat.com, dborkmann@redhat.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, davem@davemloft.net
To: jesse@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:43951 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855Ab3LMOWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 09:22:48 -0500
In-Reply-To: <cover.1386943635.git.tgraf@suug.ch>
In-Reply-To: <cover.1386943635.git.tgraf@suug.ch>
References: <cover.1386943635.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The copy & csum optimization is no longer present with zerocopy
enabled. Compute the checksum in skb_gso_segment() directly by
dropping the HW CSUM capability from the features passed in.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/openvswitch/datapath.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index ffed1cd..20ac30e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -311,7 +311,7 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 	struct sk_buff *segs, *nskb;
 	int err;
 
-	segs = __skb_gso_segment(skb, NETIF_F_SG | NETIF_F_HW_CSUM, false);
+	segs = __skb_gso_segment(skb, NETIF_F_SG, false);
 	if (IS_ERR(segs))
 		return PTR_ERR(segs);
 
-- 
1.8.3.1
