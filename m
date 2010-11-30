From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] fix hang in dmfe driver on sending of big packet
 (linux-2.6.35)
Date: Tue, 30 Nov 2010 14:57:39 +0100
Message-ID: <1291125459.2904.75.camel@edumazet-laptop>
References: <20101130134626.GA1856@lw.yar.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, tori@unhappy.mine.nu
To: "Alexander V. Lukyanov" <lav@netis.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58752 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752493Ab0K3N5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 08:57:43 -0500
Received: by wwa36 with SMTP id 36so6094526wwa.1
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 05:57:42 -0800 (PST)
In-Reply-To: <20101130134626.GA1856@lw.yar.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Alexander V. Lukyanov <lav@netis.ru>

Le mardi 30 novembre 2010 =C3=A0 16:46 +0300, Alexander V. Lukyanov a =C3=
=A9crit :
> Hello!
>=20
> This patch fixes hang in dmfe driver on attempt of sending a big pack=
et.
> Without this patch the code stops the queue and never wakes it again.
>=20
> Signed-off-by: Alexander V. Lukyanov <lav@netis.ru>
>=20

Nice catch, but your patch is not a "diff -p1" one

I did it for net-2.6 tree :

Thanks

[PATCH] tulip: fix hang in dmfe driver on sending of big packet

This patch fixes hang in dmfe driver on attempt of sending a big packet=
=2E
Without this patch the code stops the queue and never wakes it again.

Signed-off-by: Alexander V. Lukyanov <lav@netis.ru>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/tulip/dmfe.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index a9f7d5d..7064e03 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -688,9 +688,6 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *=
skb,
=20
 	DMFE_DBUG(0, "dmfe_start_xmit", 0);
=20
-	/* Resource flag check */
-	netif_stop_queue(dev);
-
 	/* Too large packet check */
 	if (skb->len > MAX_PACKET_SIZE) {
 		pr_err("big packet =3D %d\n", (u16)skb->len);
@@ -698,6 +695,9 @@ static netdev_tx_t dmfe_start_xmit(struct sk_buff *=
skb,
 		return NETDEV_TX_OK;
 	}
=20
+	/* Resource flag check */
+	netif_stop_queue(dev);
+
 	spin_lock_irqsave(&db->lock, flags);
=20
 	/* No Tx resource check, it never happen nromally */


