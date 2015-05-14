From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH v3] cls_flower: Fix compile error
Date: Thu, 14 May 2015 13:20:15 -0400
Message-ID: <5554D94F.8090806@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Pirko <jiri@resnulli.us>, David Miller <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t2353.austin.hp.com ([15.217.128.52]:59141 "EHLO
	g2t2353.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933158AbbENRUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2015 13:20:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix compile error in net/sched/cls_flower.c
   =20
    net/sched/cls_flower.c: In function =E2=80=98fl_set_key=E2=80=99:
    net/sched/cls_flower.c:240:3: error: implicit declaration of
     function =E2=80=98tcf_change_indev=E2=80=99 [-Werror=3Dimplicit-fu=
nction-declaration]
       err =3D tcf_change_indev(net, tb[TCA_FLOWER_INDEV]);

Introduced in 77b9900ef53ae
   =20
=46ixes: 77b9900ef53ae ("tc: introduce Flower classifier")
Signed-off-by: Brian Haley <brian.haley@hp.com>

diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 9bc654c..8c8f34e 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -234,15 +234,15 @@ static void fl_set_key_val(struct nlattr **tb,
 static int fl_set_key(struct net *net, struct nlattr **tb,
 		      struct fl_flow_key *key, struct fl_flow_key *mask)
 {
-	int err;
-
+#ifdef CONFIG_NET_CLS_IND
 	if (tb[TCA_FLOWER_INDEV]) {
-		err =3D tcf_change_indev(net, tb[TCA_FLOWER_INDEV]);
+		int err =3D tcf_change_indev(net, tb[TCA_FLOWER_INDEV]);
 		if (err < 0)
 			return err;
 		key->indev_ifindex =3D err;
 		mask->indev_ifindex =3D 0xffffffff;
 	}
+#endif
=20
 	fl_set_key_val(tb, key->eth.dst, TCA_FLOWER_KEY_ETH_DST,
 		       mask->eth.dst, TCA_FLOWER_KEY_ETH_DST_MASK,
