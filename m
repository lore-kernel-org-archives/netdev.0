From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 17/17] tcp: get rid of two unnecessary u16s in TCP skb flags copying
Date: Sat, 28 Feb 2009 16:44:42 +0200
Message-ID: <12358322832837-git-send-email-ilpo.jarvinen@helsinki.fi>
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
 <12358322833023-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53706 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971AbZB1Oo4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:56 -0500
In-Reply-To: <12358322833023-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

I guess these fields were one day 16-bit in the struct but
nowadays they're just using 8 bits anyway.

This is just a precaution, didn't result any change in my
case but who knows what all those varying gcc versions &
options do. I've been told that 16-bit is not so nice with
some cpus.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index d5c7245..274110e 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -766,7 +766,7 @@ int tcp_fragment(struct sock *sk, struct sk_buff *s=
kb, u32 len,
 	struct sk_buff *buff;
 	int nsize, old_factor;
 	int nlen;
-	u16 flags;
+	u8 flags;
=20
 	BUG_ON(len > skb->len);
=20
@@ -1281,7 +1281,7 @@ static int tso_fragment(struct sock *sk, struct s=
k_buff *skb, unsigned int len,
 {
 	struct sk_buff *buff;
 	int nlen =3D skb->len - len;
-	u16 flags;
+	u8 flags;
=20
 	/* All of a TSO frame must be composed of paged data.  */
 	if (skb->len !=3D skb->data_len)
--=20
1.5.6.5

