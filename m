From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 09/46] net: octeon_mgmt: fix DMA unmap size
Date: Mon, 11 Jul 2011 02:52:49 +0200 (CEST)
Message-ID: <be093b6dd643918406479b11667992ce5aacdd9f.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43669 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752594Ab1GKAwv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:51 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also: use netdev_alloc_skb_ip_align() for readability.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/octeon/octeon_mgmt.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octe=
on_mgmt.c
index 429e08c..dd4a57a 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -152,16 +152,15 @@ static void octeon_mgmt_rx_fill_ring(struct net_d=
evice *netdev)
 		struct sk_buff *skb;
=20
 		/* CN56XX pass 1 needs 8 bytes of padding.  */
-		size =3D netdev->mtu + OCTEON_MGMT_RX_HEADROOM + 8 + NET_IP_ALIGN;
+		size =3D netdev->mtu + OCTEON_MGMT_RX_HEADROOM + 8;
=20
-		skb =3D netdev_alloc_skb(netdev, size);
+		skb =3D netdev_alloc_skb_ip_align(netdev, size);
 		if (!skb)
 			break;
-		skb_reserve(skb, NET_IP_ALIGN);
 		__skb_queue_tail(&p->rx_list, skb);
=20
 		re.d64 =3D 0;
-		re.s.len =3D size;
+		re.s.len =3D size =3D skb_tailroom(skb);
 		re.s.addr =3D dma_map_single(p->dev, skb->data,
 					   size,
 					   DMA_FROM_DEVICE);
@@ -297,7 +296,7 @@ static u64 octeon_mgmt_dequeue_rx_buffer(struct oct=
eon_mgmt *p,
 	*pskb =3D __skb_dequeue(&p->rx_list);
=20
 	dma_unmap_single(p->dev, re.s.addr,
-			 ETH_FRAME_LEN + OCTEON_MGMT_RX_HEADROOM,
+			 skb_tailroom(*pskb),
 			 DMA_FROM_DEVICE);
=20
 	return re.d64;
--=20
1.7.5.4

