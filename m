From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 04/17] tcp: deferring in middle of queue makes very little sense
Date: Sat, 28 Feb 2009 16:44:29 +0200
Message-ID: <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53706 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbZB1Oor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:47 -0500
In-Reply-To: <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

If skb can be sent right away, we certainly should do that
if it's in the middle of the queue because it won't get
more data into it.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 2471cd4..fa3c81a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1356,6 +1356,10 @@ static int tcp_tso_should_defer(struct sock *sk,=
 struct sk_buff *skb)
 	if (limit >=3D sk->sk_gso_max_size)
 		goto send_now;
=20
+	/* Middle in queue won't get any more data, full sendable already? */
+	if ((skb !=3D tcp_write_queue_tail(sk)) && (limit >=3D skb->len))
+		goto send_now;
+
 	if (sysctl_tcp_tso_win_divisor) {
 		u32 chunk =3D min(tp->snd_wnd, tp->snd_cwnd * tp->mss_cache);
=20
--=20
1.5.6.5

