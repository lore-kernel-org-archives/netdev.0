From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 1/6] af_packet: use skb->skb_iif instead of orig_dev->ifindex
Date: Sat, 12 Mar 2011 14:14:34 +0100
Message-ID: <1299935679-18135-2-git-send-email-jpirko@redhat.com>
References: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net, xiaosuo@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753796Ab1CLNO6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 08:14:58 -0500
In-Reply-To: <1299935679-18135-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since skb_iif has the desired value (ifindex of physical device actuall=
y
received the traffic) use that instead.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
Reviewed-by: Changli Gao <xiaosuo@gmail.com>
Reviewed-by: Nicolas de Peslo=C3=BCan <nicolas.2p.debian@free.fr>
---
 net/packet/af_packet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b5362e9..714383c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -627,7 +627,7 @@ static int packet_rcv(struct sk_buff *skb, struct n=
et_device *dev,
 	sll->sll_protocol =3D skb->protocol;
 	sll->sll_pkttype =3D skb->pkt_type;
 	if (unlikely(po->origdev))
-		sll->sll_ifindex =3D orig_dev->ifindex;
+		sll->sll_ifindex =3D skb->skb_iif;
 	else
 		sll->sll_ifindex =3D dev->ifindex;
=20
@@ -812,7 +812,7 @@ static int tpacket_rcv(struct sk_buff *skb, struct =
net_device *dev,
 	sll->sll_protocol =3D skb->protocol;
 	sll->sll_pkttype =3D skb->pkt_type;
 	if (unlikely(po->origdev))
-		sll->sll_ifindex =3D orig_dev->ifindex;
+		sll->sll_ifindex =3D skb->skb_iif;
 	else
 		sll->sll_ifindex =3D dev->ifindex;
=20
--=20
1.7.4

