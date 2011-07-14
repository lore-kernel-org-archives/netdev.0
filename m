From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH 10/10] net: remove SK_ROUTE_CAPS from meta ematch
Date: Thu, 14 Jul 2011 02:10:30 +0200 (CEST)
Message-ID: <b06d1da00c5f333bb5d8d9f01aa306ff69b99df5.1310601401.git.mirq-linux@rere.qmqm.pl>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jamal Hadi Salim <hadi@cyberus.ca>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:59825 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752845Ab1GNAKc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 20:10:32 -0400
In-Reply-To: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove it, as it indirectly exposes netdev features. It's not used in
iproute2 (2.6.38) - is anything else using its interface?

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 include/linux/tc_ematch/tc_em_meta.h |    2 +-
 net/sched/em_meta.c                  |    7 -------
 2 files changed, 1 insertions(+), 8 deletions(-)

diff --git a/include/linux/tc_ematch/tc_em_meta.h b/include/linux/tc_em=
atch/tc_em_meta.h
index 7138962..b11f8ce 100644
--- a/include/linux/tc_ematch/tc_em_meta.h
+++ b/include/linux/tc_ematch/tc_em_meta.h
@@ -67,7 +67,7 @@ enum {
 	TCF_META_ID_SK_FORWARD_ALLOCS,
 	TCF_META_ID_SK_SNDBUF,
  	TCF_META_ID_SK_ALLOCS,
- 	TCF_META_ID_SK_ROUTE_CAPS,
+	__TCF_META_ID_SK_ROUTE_CAPS,	/* unimplemented but in ABI already */
  	TCF_META_ID_SK_HASH,
  	TCF_META_ID_SK_LINGERTIME,
  	TCF_META_ID_SK_ACK_BACKLOG,
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 49130e8..1363bf1 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -404,12 +404,6 @@ META_COLLECTOR(int_sk_alloc)
 	dst->value =3D (__force int) skb->sk->sk_allocation;
 }
=20
-META_COLLECTOR(int_sk_route_caps)
-{
-	SKIP_NONLOCAL(skb);
-	dst->value =3D skb->sk->sk_route_caps;
-}
-
 META_COLLECTOR(int_sk_hash)
 {
 	SKIP_NONLOCAL(skb);
@@ -530,7 +524,6 @@ static struct meta_ops __meta_ops[TCF_META_TYPE_MAX=
 + 1][TCF_META_ID_MAX + 1] =3D
 		[META_ID(SK_ERR_QLEN)]		=3D META_FUNC(int_sk_err_qlen),
 		[META_ID(SK_FORWARD_ALLOCS)]	=3D META_FUNC(int_sk_fwd_alloc),
 		[META_ID(SK_ALLOCS)]		=3D META_FUNC(int_sk_alloc),
-		[META_ID(SK_ROUTE_CAPS)]	=3D META_FUNC(int_sk_route_caps),
 		[META_ID(SK_HASH)]		=3D META_FUNC(int_sk_hash),
 		[META_ID(SK_LINGERTIME)]	=3D META_FUNC(int_sk_lingertime),
 		[META_ID(SK_ACK_BACKLOG)]	=3D META_FUNC(int_sk_ack_bl),
--=20
1.7.5.4

