From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 3/8] tipc: silence sparse warnings
Date: Fri, 18 Oct 2013 07:23:16 +0200
Message-ID: <1382073801-22128-4-git-send-email-jon.maloy@ericsson.com>
References: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	=?UTF-8?q?Andreas=20Bofj=C3=A4ll?= <andreas.bofjall@ericsson.com>,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.gq1.yahoo.com ([98.137.12.179]:46724 "HELO
	smtp104.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750859Ab3JRFaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 01:30:19 -0400
In-Reply-To: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ying Xue <ying.xue@windriver.com>

Eliminate below sparse warnings:

net/tipc/link.c:1210:37: warning: cast removes address space of express=
ion
net/tipc/link.c:1218:59: warning: incorrect type in argument 2 (differe=
nt address spaces)
net/tipc/link.c:1218:59:    expected void const [noderef] <asn:1>*from
net/tipc/link.c:1218:59:    got unsigned char const [usertype] *[assign=
ed] sect_crs
net/tipc/socket.c:341:49: warning: Using plain integer as NULL pointer
net/tipc/socket.c:1371:36: warning: Using plain integer as NULL pointer
net/tipc/socket.c:1694:57: warning: Using plain integer as NULL pointer

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Andreas Bofj=C3=A4ll <andreas.bofjall@ericsson.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c   |    4 ++--
 net/tipc/socket.c |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index b02a6dc..be73a1f 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1160,7 +1160,7 @@ static int link_send_sections_long(struct tipc_po=
rt *sender,
 	struct tipc_msg fragm_hdr;
 	struct sk_buff *buf, *buf_chain, *prev;
 	u32 fragm_crs, fragm_rest, hsz, sect_rest;
-	const unchar *sect_crs;
+	const unchar __user *sect_crs;
 	int curr_sect;
 	u32 fragm_no;
 	int res =3D 0;
@@ -1202,7 +1202,7 @@ again:
=20
 		if (!sect_rest) {
 			sect_rest =3D msg_sect[++curr_sect].iov_len;
-			sect_crs =3D (const unchar *)msg_sect[curr_sect].iov_base;
+			sect_crs =3D msg_sect[curr_sect].iov_base;
 		}
=20
 		if (sect_rest < fragm_rest)
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index d224382..3906527 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -338,7 +338,7 @@ static int release(struct socket *sock)
 		buf =3D __skb_dequeue(&sk->sk_receive_queue);
 		if (buf =3D=3D NULL)
 			break;
-		if (TIPC_SKB_CB(buf)->handle !=3D 0)
+		if (TIPC_SKB_CB(buf)->handle !=3D NULL)
 			kfree_skb(buf);
 		else {
 			if ((sock->state =3D=3D SS_CONNECTING) ||
@@ -1364,7 +1364,7 @@ static u32 filter_rcv(struct sock *sk, struct sk_=
buff *buf)
 		return TIPC_ERR_OVERLOAD;
=20
 	/* Enqueue message */
-	TIPC_SKB_CB(buf)->handle =3D 0;
+	TIPC_SKB_CB(buf)->handle =3D NULL;
 	__skb_queue_tail(&sk->sk_receive_queue, buf);
 	skb_set_owner_r(buf, sk);
=20
@@ -1687,7 +1687,7 @@ restart:
 		/* Disconnect and send a 'FIN+' or 'FIN-' message to peer */
 		buf =3D __skb_dequeue(&sk->sk_receive_queue);
 		if (buf) {
-			if (TIPC_SKB_CB(buf)->handle !=3D 0) {
+			if (TIPC_SKB_CB(buf)->handle !=3D NULL) {
 				kfree_skb(buf);
 				goto restart;
 			}
--=20
1.7.9.5
