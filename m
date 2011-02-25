From: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 1/6] Phonet: allow multiple listen() and fix small race condition
Date: Fri, 25 Feb 2011 11:14:56 +0200
Message-ID: <1298625301-13909-1-git-send-email-remi.denis-courmont@nokia.com>
References: <201102251113.41620.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([147.243.128.24]:30563 "EHLO mgw-da01.nokia.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191Ab1BYJOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 04:14:20 -0500
Received: from leon.remlab.com (helruo-dhcp021243.ntc.nokia.com [172.21.21.243])
	by mgw-da01.nokia.com (Switch-3.4.3/Switch-3.4.3) with ESMTP id p1P9EHG0005431
	for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 11:14:18 +0200
In-Reply-To: <201102251113.41620.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/socket.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/phonet/socket.c b/net/phonet/socket.c
index 25f746d..ceb5143 100644
--- a/net/phonet/socket.c
+++ b/net/phonet/socket.c
@@ -428,19 +428,19 @@ static int pn_socket_listen(struct socket *sock, =
int backlog)
 	struct sock *sk =3D sock->sk;
 	int err =3D 0;
=20
-	if (sock->state !=3D SS_UNCONNECTED)
-		return -EINVAL;
 	if (pn_socket_autobind(sock))
 		return -ENOBUFS;
=20
 	lock_sock(sk);
-	if (sk->sk_state !=3D TCP_CLOSE) {
+	if (sock->state !=3D SS_UNCONNECTED) {
 		err =3D -EINVAL;
 		goto out;
 	}
=20
-	sk->sk_state =3D TCP_LISTEN;
-	sk->sk_ack_backlog =3D 0;
+	if (sk->sk_state !=3D TCP_LISTEN) {
+		sk->sk_state =3D TCP_LISTEN;
+		sk->sk_ack_backlog =3D 0;
+	}
 	sk->sk_max_ack_backlog =3D backlog;
 out:
 	release_sock(sk);
--=20
1.7.1

