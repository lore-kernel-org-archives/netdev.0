From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 09/11] irda: merge exit paths
Date: Sat, 13 Dec 2008 21:21:20 +0200
Message-ID: <1229196082-4162-10-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1229196082-4162-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-8-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1229196082-4162-9-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>,
	Samuel Ortiz <samuel@sortiz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51986 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988AbYLMTVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:21:25 -0500
In-Reply-To: <1229196082-4162-9-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
Cc: Samuel Ortiz <samuel@sortiz.org>
---
 net/irda/irlap_frame.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index f17b65a..2562ebc 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -1325,6 +1325,7 @@ int irlap_driver_rcv(struct sk_buff *skb, struct =
net_device *dev,
 	struct irlap_cb *self;
 	int command;
 	__u8 control;
+	int ret =3D -1;
=20
 	if (!net_eq(dev_net(dev), &init_net))
 		goto out;
@@ -1333,25 +1334,21 @@ int irlap_driver_rcv(struct sk_buff *skb, struc=
t net_device *dev,
 	self =3D (struct irlap_cb *) dev->atalk_ptr;
=20
 	/* If the net device is down, then IrLAP is gone! */
-	if (!self || self->magic !=3D LAP_MAGIC) {
-		dev_kfree_skb(skb);
-		return -1;
-	}
+	if (!self || self->magic !=3D LAP_MAGIC)
+		goto err;
=20
 	/* We are no longer an "old" protocol, so we need to handle
 	 * share and non linear skbs. This should never happen, so
 	 * we don't need to be clever about it. Jean II */
 	if ((skb =3D skb_share_check(skb, GFP_ATOMIC)) =3D=3D NULL) {
 		IRDA_ERROR("%s: can't clone shared skb!\n", __func__);
-		dev_kfree_skb(skb);
-		return -1;
+		goto err;
 	}
=20
 	/* Check if frame is large enough for parsing */
 	if (!pskb_may_pull(skb, 2)) {
 		IRDA_ERROR("%s: frame too short!\n", __func__);
-		dev_kfree_skb(skb);
-		return -1;
+		goto err;
 	}
=20
 	command    =3D skb->data[0] & CMD_FRAME;
@@ -1442,7 +1439,9 @@ int irlap_driver_rcv(struct sk_buff *skb, struct =
net_device *dev,
 		break;
 	}
 out:
+	ret =3D 0;
+err:
 	/* Always drop our reference on the skb */
 	dev_kfree_skb(skb);
-	return 0;
+	return ret;
 }
--=20
1.5.2.2

