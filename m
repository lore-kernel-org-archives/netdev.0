From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 08/10] tcp: move some parts from tcp_write_xmit
Date: Fri,  5 Dec 2008 22:58:54 +0200
Message-ID: <1228510736-3655-9-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1228510736-3655-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-3-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-4-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-5-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-6-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-7-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1228510736-3655-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50779 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753351AbYLEU7B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2008 15:59:01 -0500
In-Reply-To: <1228510736-3655-8-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |   23 ++++++++++++-----------
 1 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0744b9f..59505ce 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1527,13 +1527,6 @@ static int tcp_write_xmit(struct sock *sk, unsig=
ned int mss_now, int nonagle)
 	int cwnd_quota;
 	int result;
=20
-	/* If we are closed, the bytes will have to remain here.
-	 * In time closedown will finish, we empty the write queue and all
-	 * will be happy.
-	 */
-	if (unlikely(sk->sk_state =3D=3D TCP_CLOSE))
-		return 0;
-
 	sent_pkts =3D 0;
=20
 	/* Do MTU probing. */
@@ -1605,10 +1598,18 @@ void __tcp_push_pending_frames(struct sock *sk,=
 unsigned int cur_mss,
 {
 	struct sk_buff *skb =3D tcp_send_head(sk);
=20
-	if (skb) {
-		if (tcp_write_xmit(sk, cur_mss, nonagle))
-			tcp_check_probe_timer(sk);
-	}
+	if (!skb)
+		return;
+
+	/* If we are closed, the bytes will have to remain here.
+	 * In time closedown will finish, we empty the write queue and
+	 * all will be happy.
+	 */
+	if (unlikely(sk->sk_state =3D=3D TCP_CLOSE))
+		return;
+
+	if (tcp_write_xmit(sk, cur_mss, nonagle))
+		tcp_check_probe_timer(sk);
 }
=20
 /* Send _single_ skb sitting at the send head. This function requires
--=20
1.5.2.2

