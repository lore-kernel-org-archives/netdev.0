From: akpm@osdl.org
Subject: [patch 4/18] gcc-3.5: decnet
Date: Sun, 25 Jan 2004 03:07:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251107.i0PB75o25060@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



net/decnet/af_decnet.c: In function `dn_alloc_sock':
net/decnet/af_decnet.c:459: error: invalid lvalue in assignment

net/decnet/dn_neigh.c: In function `dn_phase3_output':
net/decnet/dn_neigh.c:330: error: invalid lvalue in assignment



---

 25-akpm/net/decnet/af_decnet.c |    2 +-
 25-akpm/net/decnet/dn_neigh.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff -puN net/decnet/af_decnet.c~gcc-35-decnet net/decnet/af_decnet.c
--- 25/net/decnet/af_decnet.c~gcc-35-decnet	Fri Jan 23 15:37:10 2004
+++ 25-akpm/net/decnet/af_decnet.c	Fri Jan 23 15:37:10 2004
@@ -456,7 +456,7 @@ struct sock *dn_alloc_sock(struct socket
 	if  (!sk)
 		goto out;
 
-	DN_SK(sk) = scp = (struct dn_scp *)(sk + 1);
+	sk->sk_protinfo = scp = (struct dn_scp *)(sk + 1);
 
 	if (sock)
 		sock->ops = &dn_proto_ops;
diff -puN net/decnet/dn_neigh.c~gcc-35-decnet net/decnet/dn_neigh.c
--- 25/net/decnet/dn_neigh.c~gcc-35-decnet	Fri Jan 23 15:39:15 2004
+++ 25-akpm/net/decnet/dn_neigh.c	Fri Jan 23 15:39:56 2004
@@ -327,7 +327,7 @@ static int dn_phase3_output(struct sk_bu
 	}
 
 	data = skb_push(skb, sizeof(struct dn_short_packet) + 2);
-	((unsigned short *)data) = dn_htons(skb->len - 2);
+	data = (unsigned char *)dn_htons(skb->len - 2);
 	sp = (struct dn_short_packet *)(data + 2);
 
 	sp->msgflg   = DN_RT_PKT_SHORT|(cb->rt_flags&(DN_RT_F_RQR|DN_RT_F_RTS));

_
