From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 02/15] tcp: move tcp_verify_retransmit_hint
Date: Sat, 20 Sep 2008 20:52:20 +0300
Message-ID: <1221933153-11874-3-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1221933153-11874-1-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1221933153-11874-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49080 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbYITRwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2008 13:52:36 -0400
In-Reply-To: <1221933153-11874-2-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7306bfb..9e95ad6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -979,6 +979,19 @@ static void tcp_update_reordering(struct sock *sk,=
 const int metric,
 	}
 }
=20
+/* RFC: This is from the original, I doubt that this is necessary at a=
ll:
+ * clear xmit_retrans hint if seq of this skb is beyond hint. How coul=
d we
+ * retransmitted past LOST markings in the first place? I'm not fully =
sure
+ * about undo and end of connection cases, which can cause R without L=
?
+ */
+static void tcp_verify_retransmit_hint(struct tcp_sock *tp, struct sk_=
buff *skb)
+{
+	if ((tp->retransmit_skb_hint !=3D NULL) &&
+	    before(TCP_SKB_CB(skb)->seq,
+		   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
+		tp->retransmit_skb_hint =3D NULL;
+}
+
 /* This procedure tags the retransmission queue when SACKs arrive.
  *
  * We have three tag bits: SACKED(S), RETRANS(R) and LOST(L).
@@ -2156,19 +2169,6 @@ static int tcp_time_to_recover(struct sock *sk)
 	return 0;
 }
=20
-/* RFC: This is from the original, I doubt that this is necessary at a=
ll:
- * clear xmit_retrans hint if seq of this skb is beyond hint. How coul=
d we
- * retransmitted past LOST markings in the first place? I'm not fully =
sure
- * about undo and end of connection cases, which can cause R without L=
?
- */
-static void tcp_verify_retransmit_hint(struct tcp_sock *tp, struct sk_=
buff *skb)
-{
-	if ((tp->retransmit_skb_hint !=3D NULL) &&
-	    before(TCP_SKB_CB(skb)->seq,
-		   TCP_SKB_CB(tp->retransmit_skb_hint)->seq))
-		tp->retransmit_skb_hint =3D NULL;
-}
-
 /* Mark head of queue up as lost. With RFC3517 SACK, the packets is
  * is against sacked "cnt", otherwise it's against facked "cnt"
  */
--=20
1.5.2.2

