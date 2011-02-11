From: =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: [PATCH 01/14] net/fec: no need to cast arguments for memcpy
Date: Fri, 11 Feb 2011 11:32:09 +0100
Message-ID: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shawn Guo <shawn.guo@freescale.com>, kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:52458 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755549Ab1BKKca (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 05:32:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

memcpy takes a const void * as 2nd argument.  So the argument is
converted automatically to void * anyhow.

Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
---
 drivers/net/fec.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 2a71373..3e6e923 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -284,7 +284,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net=
_device *dev)
 	if (((unsigned long) bufaddr) & FEC_ALIGNMENT) {
 		unsigned int index;
 		index =3D bdp - fep->tx_bd_base;
-		memcpy(fep->tx_bounce[index], (void *)skb->data, skb->len);
+		memcpy(fep->tx_bounce[index], skb->data, skb->len);
 		bufaddr =3D fep->tx_bounce[index];
 	}
=20
--=20
1.7.2.3

