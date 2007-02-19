From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/18] [TCP] FRTO: Moved tcp_use_frto from tcp.h to tcp_input.c
Date: Mon, 19 Feb 2007 13:37:57 +0200
Message-ID: <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37500 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbXBSLiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:14 -0500
In-Reply-To: <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In addition, removed inline.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h    |   14 +-------------
 net/ipv4/tcp_input.c |   13 +++++++++++++
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5c472f2..572a77b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -341,6 +341,7 @@ extern struct sock *		tcp_check_req(stru
 extern int			tcp_child_process(struct sock *parent,
 						  struct sock *child,
 						  struct sk_buff *skb);
+extern int			tcp_use_frto(const struct sock *sk);
 extern void			tcp_enter_frto(struct sock *sk);
 extern void			tcp_enter_loss(struct sock *sk, int how);
 extern void			tcp_clear_retrans(struct tcp_sock *tp);
@@ -1033,19 +1034,6 @@ static inline int tcp_paws_check(const s
=20
 #define TCP_CHECK_TIMER(sk) do { } while (0)
=20
-static inline int tcp_use_frto(const struct sock *sk)
-{
-	const struct tcp_sock *tp =3D tcp_sk(sk);
-=09
-	/* F-RTO must be activated in sysctl and there must be some
-	 * unsent new data, and the advertised window should allow
-	 * sending it.
-	 */
-	return (sysctl_tcp_frto && sk->sk_send_head &&
-		!after(TCP_SKB_CB(sk->sk_send_head)->end_seq,
-		       tp->snd_una + tp->snd_wnd));
-}
-
 static inline void tcp_mib_init(void)
 {
 	/* See RFC 2012 */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c5be3d0..294cb44 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1236,6 +1236,19 @@ #endif
 	return flag;
 }
=20
+int tcp_use_frto(const struct sock *sk)
+{
+	const struct tcp_sock *tp =3D tcp_sk(sk);
+=09
+	/* F-RTO must be activated in sysctl and there must be some
+	 * unsent new data, and the advertised window should allow
+	 * sending it.
+	 */
+	return (sysctl_tcp_frto && sk->sk_send_head &&
+		!after(TCP_SKB_CB(sk->sk_send_head)->end_seq,
+		       tp->snd_una + tp->snd_wnd));
+}
+
 /* RTO occurred, but do not yet enter loss state. Instead, transmit tw=
o new
  * segments to see from the next ACKs whether any data was really miss=
ing.
  * If the RTO was spurious, new ACKs should arrive.
--=20
1.4.2

