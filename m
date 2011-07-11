From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 16/46] net: cxgb3: don't drop packets on memory pressure
 in driver
Date: Mon, 11 Jul 2011 02:52:50 +0200 (CEST)
Message-ID: <2144ac70eb11917185acd1c7c27625e178c70e2f.1310339688.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Divy Le Ray <divy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43662 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753378Ab1GKAwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 10 Jul 2011 20:52:53 -0400
In-Reply-To: <cover.1310339688.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dropping received packets should be left to upper layers.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/cxgb3/sge.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 3196fdd..d322d3e 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -66,7 +66,6 @@
 #define FL1_PG_ORDER (PAGE_SIZE > 8192 ? 0 : 1)
 #define FL1_PG_ALLOC_SIZE (PAGE_SIZE << FL1_PG_ORDER)
=20
-#define SGE_RX_DROP_THRES 16
 #define RX_RECLAIM_PERIOD (HZ/4)
=20
 /*
@@ -2338,13 +2337,10 @@ no_mem:
 				}
=20
 				skb =3D get_packet_pg(adap, fl, q,
-						    G_RSPD_LEN(len),
-						    eth ?
-						    SGE_RX_DROP_THRES : 0);
+						    G_RSPD_LEN(len), 0);
 				q->pg_skb =3D skb;
 			} else
-				skb =3D get_packet(adap, fl, G_RSPD_LEN(len),
-						 eth ? SGE_RX_DROP_THRES : 0);
+				skb =3D get_packet(adap, fl, G_RSPD_LEN(len), 0);
 			if (unlikely(!skb)) {
 				if (!eth)
 					goto no_mem;
--=20
1.7.5.4

