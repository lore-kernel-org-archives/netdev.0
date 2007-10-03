From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/3] [TCP]: "Annotate" another fackets_out state reset
Date: Wed,  3 Oct 2007 14:00:18 +0300
Message-ID: <11914092182230-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi> <11914092183725-git-send-email-ilpo.jarvinen@helsinki.fi> <11914092181600-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48181 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755778AbXJCLAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 07:00:20 -0400
In-Reply-To: <11914092181600-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This should no longer be necessary because fackets_out is
accurate. It indicates bugs elsewhere, thus report it.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e22ffe7..87c9ef5 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1160,7 +1160,8 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 	int first_sack_index;
=20
 	if (!tp->sacked_out) {
-		tp->fackets_out =3D 0;
+		if (WARN_ON(tp->fackets_out))
+			tp->fackets_out =3D 0;
 		tp->highest_sack =3D tp->snd_una;
 	}
 	prior_fackets =3D tp->fackets_out;
--=20
1.5.0.6

