From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 03/10] tcp: more aggressive skipping
Date: Mon, 24 Nov 2008 16:22:00 +0200
Message-ID: <1227536527-29713-4-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1227536527-29713-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-2-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35317 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753079AbYKXOWJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 09:22:09 -0500
In-Reply-To: <1227536527-29713-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I knew already when rewriting the sacktag that this condition
was too conservative, change it now since it prevent lot of
useless work (especially in the sack shifter decision code
that is being added by a later patch). This shouldn't change
anything really, just save some processing regardless of the
shifter.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 01b7458..84ca4f7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1401,7 +1401,7 @@ static struct sk_buff *tcp_sacktag_skip(struct sk=
_buff *skb, struct sock *sk,
 		if (skb =3D=3D tcp_send_head(sk))
 			break;
=20
-		if (!before(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
+		if (after(TCP_SKB_CB(skb)->end_seq, skip_to_seq))
 			break;
=20
 		*fack_count +=3D tcp_skb_pcount(skb);
--=20
1.5.2.2

