From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/3] [TCP]: Move prior_in_flight collect to more robust place
Date: Tue,  4 Dec 2007 18:48:49 +0200
Message-ID: <11967869303709-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi> <11967869303567-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37339 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520AbXLDQsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 11:48:52 -0500
In-Reply-To: <11967869303567-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

The previous location is after sacktag processing, which affects
counters tcp_packets_in_flight depends on. This may manifest as
wrong behavior if new SACK blocks are present and all is clear
for call to tcp_cong_avoid, which in the case of
tcp_reno_cong_avoid bails out early because it thinks that
TCP is not limited by cwnd.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5f93d88..fef1191 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3180,6 +3180,7 @@ static int tcp_ack(struct sock *sk, struct sk_buf=
f *skb, int flag)
 	}
=20
 	prior_fackets =3D tp->fackets_out;
+	prior_in_flight =3D tcp_packets_in_flight(tp);
=20
 	if (!(flag&FLAG_SLOWPATH) && after(ack, prior_snd_una)) {
 		/* Window is constant, pure forward advance.
@@ -3219,8 +3220,6 @@ static int tcp_ack(struct sock *sk, struct sk_buf=
f *skb, int flag)
 	if (!prior_packets)
 		goto no_queue;
=20
-	prior_in_flight =3D tcp_packets_in_flight(tp);
-
 	/* See if we can take anything off of the retransmit queue. */
 	flag |=3D tcp_clean_rtx_queue(sk, &seq_rtt, prior_fackets);
=20
--=20
1.5.0.6

