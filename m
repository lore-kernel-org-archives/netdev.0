From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [net-next-2.6 10/10] caif: remove unesesarry exports
Date: Fri, 13 May 2011 14:44:08 +0200
Message-ID: <1305290648-9613-11-git-send-email-sjur.brandeland@stericsson.com>
References: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sf1.isp.kq.no ([213.172.193.37]:41788 "EHLO
	slow2.isp.as2116.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759146Ab1EMNCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 09:02:37 -0400
Received: from pmx.vmail.no (pmx.vmail.no [193.75.16.11])
	by slow2.isp.as2116.net (Postfix) with ESMTP id B523840B46
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:45:27 +0200 (CEST)
In-Reply-To: <1305290648-9613-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 include/net/caif/cfpkt.h |    1 -
 net/caif/caif_socket.c   |    4 ++--
 net/caif/cfcnfg.c        |    1 -
 net/caif/cfpkt_skbuff.c  |   27 ++++++++-------------------
 net/caif/chnl_net.c      |    5 +++--
 5 files changed, 13 insertions(+), 25 deletions(-)

diff --git a/include/net/caif/cfpkt.h b/include/net/caif/cfpkt.h
index 8b550f8..6bd200a 100644
--- a/include/net/caif/cfpkt.h
+++ b/include/net/caif/cfpkt.h
@@ -195,5 +195,4 @@ void *cfpkt_tonative(struct cfpkt *pkt);
  * @return Packet information
  */
 struct caif_payload_info *cfpkt_info(struct cfpkt *pkt);
-/*! @} */
 #endif				/* CFPKT_H_ */
diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index 5cf9c73..b840395 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -205,7 +205,7 @@ static int caif_sktrecv_cb(struct cflayer *layr, st=
ruct cfpkt *pkt)
 	skb =3D cfpkt_tonative(pkt);
=20
 	if (unlikely(cf_sk->sk.sk_state !=3D CAIF_CONNECTED)) {
-		cfpkt_destroy(pkt);
+		kfree_skb(skb);
 		return 0;
 	}
 	caif_queue_rcv_skb(&cf_sk->sk, skb);
@@ -537,7 +537,7 @@ static int transmit_skb(struct sk_buff *skb, struct=
 caifsock *cf_sk,
 	struct cfpkt *pkt;
=20
 	pkt =3D cfpkt_fromnative(CAIF_DIR_OUT, skb);
-	memset(cfpkt_info(pkt), 0, sizeof(struct caif_payload_info));
+	memset(skb->cb, 0, sizeof(struct caif_payload_info));
=20
 	if (cf_sk->layer.dn =3D=3D NULL)
 		return -EINVAL;
diff --git a/net/caif/cfcnfg.c b/net/caif/cfcnfg.c
index 4230099..351c2ca 100644
--- a/net/caif/cfcnfg.c
+++ b/net/caif/cfcnfg.c
@@ -117,7 +117,6 @@ out_of_mem:
 	kfree(this);
 	return NULL;
 }
-EXPORT_SYMBOL(cfcnfg_create);
=20
 void cfcnfg_remove(struct cfcnfg *cfg)
 {
diff --git a/net/caif/cfpkt_skbuff.c b/net/caif/cfpkt_skbuff.c
index 20c6cb3..75d4bfa 100644
--- a/net/caif/cfpkt_skbuff.c
+++ b/net/caif/cfpkt_skbuff.c
@@ -97,21 +97,20 @@ inline struct cfpkt *cfpkt_create(u16 len)
 {
 	return cfpkt_create_pfx(len + PKT_POSTFIX, PKT_PREFIX);
 }
-EXPORT_SYMBOL(cfpkt_create);
=20
 void cfpkt_destroy(struct cfpkt *pkt)
 {
 	struct sk_buff *skb =3D pkt_to_skb(pkt);
 	kfree_skb(skb);
 }
-EXPORT_SYMBOL(cfpkt_destroy);
+
=20
 inline bool cfpkt_more(struct cfpkt *pkt)
 {
 	struct sk_buff *skb =3D pkt_to_skb(pkt);
 	return skb->len > 0;
 }
-EXPORT_SYMBOL(cfpkt_more);
+
=20
 int cfpkt_peek_head(struct cfpkt *pkt, void *data, u16 len)
 {
@@ -123,7 +122,6 @@ int cfpkt_peek_head(struct cfpkt *pkt, void *data, =
u16 len)
 	return !cfpkt_extr_head(pkt, data, len) &&
 	    !cfpkt_add_head(pkt, data, len);
 }
-EXPORT_SYMBOL(cfpkt_peek_head);
=20
 int cfpkt_extr_head(struct cfpkt *pkt, void *data, u16 len)
 {
@@ -148,7 +146,6 @@ int cfpkt_extr_head(struct cfpkt *pkt, void *data, =
u16 len)
 	memcpy(data, from, len);
 	return 0;
 }
-EXPORT_SYMBOL(cfpkt_extr_head);
=20
 int cfpkt_extr_trail(struct cfpkt *pkt, void *dta, u16 len)
 {
@@ -171,13 +168,13 @@ int cfpkt_extr_trail(struct cfpkt *pkt, void *dta=
, u16 len)
 	memcpy(data, from, len);
 	return 0;
 }
-EXPORT_SYMBOL(cfpkt_extr_trail);
+
=20
 int cfpkt_pad_trail(struct cfpkt *pkt, u16 len)
 {
 	return cfpkt_add_body(pkt, NULL, len);
 }
-EXPORT_SYMBOL(cfpkt_pad_trail);
+
=20
 int cfpkt_add_body(struct cfpkt *pkt, const void *data, u16 len)
 {
@@ -226,13 +223,11 @@ int cfpkt_add_body(struct cfpkt *pkt, const void =
*data, u16 len)
 		memcpy(to, data, len);
 	return 0;
 }
-EXPORT_SYMBOL(cfpkt_add_body);
=20
 inline int cfpkt_addbdy(struct cfpkt *pkt, u8 data)
 {
 	return cfpkt_add_body(pkt, &data, 1);
 }
-EXPORT_SYMBOL(cfpkt_addbdy);
=20
 int cfpkt_add_head(struct cfpkt *pkt, const void *data2, u16 len)
 {
@@ -259,20 +254,20 @@ int cfpkt_add_head(struct cfpkt *pkt, const void =
*data2, u16 len)
 	memcpy(to, data, len);
 	return 0;
 }
-EXPORT_SYMBOL(cfpkt_add_head);
+
=20
 inline int cfpkt_add_trail(struct cfpkt *pkt, const void *data, u16 le=
n)
 {
 	return cfpkt_add_body(pkt, data, len);
 }
-EXPORT_SYMBOL(cfpkt_add_trail);
+
=20
 inline u16 cfpkt_getlen(struct cfpkt *pkt)
 {
 	struct sk_buff *skb =3D pkt_to_skb(pkt);
 	return skb->len;
 }
-EXPORT_SYMBOL(cfpkt_getlen);
+
=20
 inline u16 cfpkt_iterate(struct cfpkt *pkt,
 			    u16 (*iter_func)(u16, void *, u16),
@@ -290,7 +285,7 @@ inline u16 cfpkt_iterate(struct cfpkt *pkt,
 	}
 	return iter_func(data, pkt->skb.data, cfpkt_getlen(pkt));
 }
-EXPORT_SYMBOL(cfpkt_iterate);
+
=20
 int cfpkt_setlen(struct cfpkt *pkt, u16 len)
 {
@@ -315,7 +310,6 @@ int cfpkt_setlen(struct cfpkt *pkt, u16 len)
=20
 	return cfpkt_getlen(pkt);
 }
-EXPORT_SYMBOL(cfpkt_setlen);
=20
 struct cfpkt *cfpkt_append(struct cfpkt *dstpkt,
 			     struct cfpkt *addpkt,
@@ -357,7 +351,6 @@ struct cfpkt *cfpkt_append(struct cfpkt *dstpkt,
 	dst->len +=3D addlen;
 	return skb_to_pkt(dst);
 }
-EXPORT_SYMBOL(cfpkt_append);
=20
 struct cfpkt *cfpkt_split(struct cfpkt *pkt, u16 pos)
 {
@@ -395,17 +388,13 @@ struct cfpkt *cfpkt_split(struct cfpkt *pkt, u16 =
pos)
 	skb2->len +=3D len2nd;
 	return skb_to_pkt(skb2);
 }
-EXPORT_SYMBOL(cfpkt_split);
=20
 bool cfpkt_erroneous(struct cfpkt *pkt)
 {
 	return cfpkt_priv(pkt)->erronous;
 }
-EXPORT_SYMBOL(cfpkt_erroneous);
-
=20
 struct caif_payload_info *cfpkt_info(struct cfpkt *pkt)
 {
 	return (struct caif_payload_info *)&pkt_to_skb(pkt)->cb;
 }
-EXPORT_SYMBOL(cfpkt_info);
diff --git a/net/caif/chnl_net.c b/net/caif/chnl_net.c
index 1a3398a..649ebac 100644
--- a/net/caif/chnl_net.c
+++ b/net/caif/chnl_net.c
@@ -83,10 +83,11 @@ static int chnl_recv_cb(struct cflayer *layr, struc=
t cfpkt *pkt)
 	if (!priv)
 		return -EINVAL;
=20
+	skb =3D (struct sk_buff *) cfpkt_tonative(pkt);
+
 	/* Get length of CAIF packet. */
-	pktlen =3D cfpkt_getlen(pkt);
+	pktlen =3D skb->len;
=20
-	skb =3D (struct sk_buff *) cfpkt_tonative(pkt);
 	/* Pass some minimum information and
 	 * send the packet to the net stack.
 	 */
--=20
1.7.1

