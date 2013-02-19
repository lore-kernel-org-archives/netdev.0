From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] b44: use helper function for aligning IP header
Date: Tue, 19 Feb 2013 07:33:43 +0100
Message-ID: <1361255623-26927-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f42.google.com ([74.125.83.42]:53095 "EHLO
	mail-ee0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757485Ab3BSGdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 01:33:52 -0500
Received: by mail-ee0-f42.google.com with SMTP id b47so3265669eek.29
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 22:33:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't duplicate netdev_alloc_skb_ip_align which by the way uses
NET_IP_ALIGN instead of hardcoded "2".

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
I don't have hardware to check this, so please review if it's OK.
It's quite trivial so I hope I couldn't do anything wrong.
---
 drivers/net/ethernet/broadcom/b44.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet=
/broadcom/b44.c
index 330b090..041aea6 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -809,11 +809,10 @@ static int b44_rx(struct b44 *bp, int budget)
 			struct sk_buff *copy_skb;
=20
 			b44_recycle_rx(bp, cons, bp->rx_prod);
-			copy_skb =3D netdev_alloc_skb(bp->dev, len + 2);
+			copy_skb =3D netdev_alloc_skb_ip_align(bp->dev, len);
 			if (copy_skb =3D=3D NULL)
 				goto drop_it_no_recycle;
=20
-			skb_reserve(copy_skb, 2);
 			skb_put(copy_skb, len);
 			/* DMA sync done above, copy just the actual packet */
 			skb_copy_from_linear_data_offset(skb, RX_PKT_OFFSET,
--=20
1.7.10.4
