From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/4] tcpv6: trivial formatting changes to send_(ack|reset)
Date: Thu,  9 Oct 2008 12:35:35 +0300
Message-ID: <1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43448 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313AbYJIJfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 05:35:41 -0400
In-Reply-To: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv6/tcp_ipv6.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2084f5a..3f268a3 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -948,7 +948,7 @@ static void tcp_v6_send_reset(struct sock *sk, stru=
ct sk_buff *skb)
 	struct flowi fl;
 	struct net *net =3D dev_net(skb->dst->dev);
 	struct sock *ctl_sk =3D net->ipv6.tcp_sk;
-	unsigned int tot_len =3D sizeof(*th);
+	unsigned int tot_len =3D sizeof(struct tcphdr);
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
 #endif
@@ -1032,7 +1032,6 @@ static void tcp_v6_send_reset(struct sock *sk, st=
ruct sk_buff *skb)
 	 * namespace
 	 */
 	if (!ip6_dst_lookup(ctl_sk, &buff->dst, &fl)) {
-
 		if (xfrm_lookup(&buff->dst, &fl, NULL, 0) >=3D 0) {
 			ip6_xmit(ctl_sk, buff, &fl, NULL, 0);
 			TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
@@ -1069,13 +1068,13 @@ static void tcp_v6_send_ack(struct sk_buff *skb=
, u32 seq, u32 ack, u32 win, u32
=20
 	skb_reserve(buff, MAX_HEADER + sizeof(struct ipv6hdr) + tot_len);
=20
-	t1 =3D (struct tcphdr *) skb_push(buff,tot_len);
+	t1 =3D (struct tcphdr *) skb_push(buff, tot_len);
=20
 	/* Swap the send and the receive. */
 	memset(t1, 0, sizeof(*t1));
 	t1->dest =3D th->source;
 	t1->source =3D th->dest;
-	t1->doff =3D tot_len/4;
+	t1->doff =3D tot_len / 4;
 	t1->seq =3D htonl(seq);
 	t1->ack_seq =3D htonl(ack);
 	t1->ack =3D 1;
--=20
1.5.2.2

