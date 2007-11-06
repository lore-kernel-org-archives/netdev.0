From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH] [AF_PACKET]: Allow multicast traffic to be caught by ORIGDEV
	when bonded
Date: Tue, 06 Nov 2007 07:25:47 -0800
Message-ID: <20071106152547.14672.10821.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:35192 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754194AbXKFW3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 17:29:45 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The socket option for packet sockets to return the original ifindex instead
of the bonded ifindex will not match multicast traffic.  Since this socket
option is the most useful for layer 2 traffic and multicast traffic, make
the option multicast-aware.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 net/packet/af_packet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 4cb2dfb..23eef6f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -515,7 +515,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev, struct packet
 	sll->sll_hatype = dev->type;
 	sll->sll_protocol = skb->protocol;
 	sll->sll_pkttype = skb->pkt_type;
-	if (unlikely(po->origdev) && skb->pkt_type == PACKET_HOST)
+	if (unlikely(po->origdev))
 		sll->sll_ifindex = orig_dev->ifindex;
 	else
 		sll->sll_ifindex = dev->ifindex;
@@ -661,7 +661,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev, struct packe
 	sll->sll_hatype = dev->type;
 	sll->sll_protocol = skb->protocol;
 	sll->sll_pkttype = skb->pkt_type;
-	if (unlikely(po->origdev) && skb->pkt_type == PACKET_HOST)
+	if (unlikely(po->origdev))
 		sll->sll_ifindex = orig_dev->ifindex;
 	else
 		sll->sll_ifindex = dev->ifindex;
