From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 14/21] net: tg3: mark bad rx handler behaviour [strict
 refill!]
Date: Sat,  9 Jul 2011 19:17:52 +0200 (CEST)
Message-ID: <9325e72a4729d61dbd1368fec1d1be92c20f1236.1310229312.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:51956 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754222Ab1GIRRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2011 13:17:55 -0400
In-Reply-To: <cover.1310229312.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This could use common rx handler code, but the code is too complex for
a simple conversion. Just warn about its behaviour.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/tg3.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8211b9a..c64b403 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4973,6 +4973,8 @@ static int tg3_rx(struct tg3_napi *tnapi, int bud=
get)
=20
 			skb_size =3D tg3_alloc_rx_skb(tp, tpr, opaque_key,
 						    *post_ptr);
+#warning drops packets from rx queue head on memory pressure
+#warning (like dev_skb_finish_rx_dma_refill() users)
 			if (skb_size < 0)
 				goto drop_it;
=20
--=20
1.7.5.4

