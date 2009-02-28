From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 16/17] tcp: in sendmsg/pages open code the real goto target
Date: Sat, 28 Feb 2009 16:44:41 +0200
Message-ID: <12358322833023-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322834113-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832283214-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831599-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832879-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831019-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831223-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58368 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbZB1Ooz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:55 -0500
In-Reply-To: <12358322831223-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

copied was assigned zero right before the goto, so if (copied)
cannot ever be true.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 90b2f3c..d3f9bee 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -683,7 +683,7 @@ static ssize_t do_tcp_sendpages(struct sock *sk, st=
ruct page **pages, int poffse
=20
 	err =3D -EPIPE;
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
-		goto do_error;
+		goto out_err;
=20
 	while (psize > 0) {
 		struct sk_buff *skb =3D tcp_write_queue_tail(sk);
@@ -854,7 +854,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct socket *=
sock, struct msghdr *msg,
=20
 	err =3D -EPIPE;
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
-		goto do_error;
+		goto out_err;
=20
 	while (--iovlen >=3D 0) {
 		int seglen =3D iov->iov_len;
--=20
1.5.6.5

