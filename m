From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net/veth: Fix packet checksumming
Date: Tue, 14 Dec 2010 23:35:13 +0100 (CET)
Message-ID: <26dfeea6053e4dce108037ecee0fec25b1182937.1292347522.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59124 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759032Ab0LNWfP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 17:35:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can't change ip_summed from CHECKSUM_PARTIAL to CHECKSUM_NONE
or CHECKSUM_UNNECESSARY because checksum in packet's headers is
not valid and will cause invalid checksum when frame is forwarded.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/veth.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 0bbc0c3..cca6a71 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -166,7 +166,9 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, s=
truct net_device *dev)
 	if (!(rcv->flags & IFF_UP))
 		goto tx_drop;
=20
-	if (dev->features & NETIF_F_NO_CSUM)
+	/* don't change ip_summed =3D=3D CHECKSUM_PARTIAL, as that
+	   will cause bad checksum on forwarded packets */
+	if (skb->ip_summed =3D=3D CHECKSUM_NONE)
 		skb->ip_summed =3D rcv_priv->ip_summed;
=20
 	length =3D skb->len + ETH_HLEN;
--=20
1.7.2.3

