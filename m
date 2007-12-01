From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 17/21] [TCP]: Move tcp_write_queue_empty
Date: Sun,  2 Dec 2007 00:48:12 +0200
Message-ID: <11965492972309-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962214-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963057-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296324-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492962283-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961234-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492963381-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492973133-git-send-email-ilpo.ja
 rvinen@helsinki.fi> <11965492972855-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549297779-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492971864-git-send-email-ilpo.jarvinen@helsinki.f
 i>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59570 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753535AbXLAWsZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:25 -0500
In-Reply-To: <11965492971864-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 0883697..117fcc4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1222,6 +1222,11 @@ static inline struct sk_buff *tcp_write_queue_ta=
il(struct sock *sk)
 	return skb;
 }
=20
+static inline int tcp_write_queue_empty(struct sock *sk)
+{
+	return skb_queue_empty(&sk->sk_write_queue);
+}
+
 static inline struct sk_buff *tcp_write_queue_next(struct sock *sk, st=
ruct sk_buff *skb)
 {
 	return skb->next;
@@ -1409,11 +1414,6 @@ static inline int tcp_skb_is_last(const struct s=
ock *sk,
 	return skb->next =3D=3D (struct sk_buff *)&sk->sk_write_queue;
 }
=20
-static inline int tcp_write_queue_empty(struct sock *sk)
-{
-	return skb_queue_empty(&sk->sk_write_queue);
-}
-
 /* Start sequence of the highest skb with SACKed bit, valid only if
  * sacked > 0 or when the caller has ensured validity by itself.
  */
--=20
1.5.0.6

