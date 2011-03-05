From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 1/8] af_packet: use skb->skb_iif instead of orig_dev->ifindex
Date: Sat,  5 Mar 2011 11:29:22 +0100
Message-ID: <1299320969-7951-2-git-send-email-jpirko@redhat.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751553Ab1CEK3l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 05:29:41 -0500
In-Reply-To: <1299320969-7951-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since skb_iif has the desired value (ifindex of physical device actually
received the traffic) use that instead.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/packet/af_packet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 5efef5b..b34294e 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -627,7 +627,7 @@ static int packet_rcv(struct sk_buff *skb, struct net_device *dev,
 	sll->sll_protocol = skb->protocol;
 	sll->sll_pkttype = skb->pkt_type;
 	if (unlikely(po->origdev))
-		sll->sll_ifindex = orig_dev->ifindex;
+		sll->sll_ifindex = skb->skb_iif;
 	else
 		sll->sll_ifindex = dev->ifindex;
 
@@ -812,7 +812,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct net_device *dev,
 	sll->sll_protocol = skb->protocol;
 	sll->sll_pkttype = skb->pkt_type;
 	if (unlikely(po->origdev))
-		sll->sll_ifindex = orig_dev->ifindex;
+		sll->sll_ifindex = skb->skb_iif;
 	else
 		sll->sll_ifindex = dev->ifindex;
 
-- 
1.7.4

