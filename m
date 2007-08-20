From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/5] [TCP]: tcp_packets_out_inc to tcp_output.c (no callers elsewhere)
Date: Mon, 20 Aug 2007 16:16:30 +0300
Message-ID: <1187615793583-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <118761579315-git-send-email-ilpo.jarvinen@helsinki.fi> <1187615793197-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44223 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755594AbXHTNQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 09:16:35 -0400
In-Reply-To: <1187615793197-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/net/tcp.h     |   12 ------------
 net/ipv4/tcp_output.c |   12 ++++++++++++
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6d586ca..f28f382 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -614,18 +614,6 @@ static inline void tcp_dec_pcount_approx(__u32 *co=
unt,
 	tcp_dec_pcount_approx_int(count, tcp_skb_pcount(skb));
 }
=20
-static inline void tcp_packets_out_inc(struct sock *sk,
-				       const struct sk_buff *skb)
-{
-	struct tcp_sock *tp =3D tcp_sk(sk);
-	int orig =3D tp->packets_out;
-
-	tp->packets_out +=3D tcp_skb_pcount(skb);
-	if (!orig)
-		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-					  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
-}
-
 /* Events passed to congestion control interface */
 enum tcp_ca_event {
 	CA_EVENT_TX_START,	/* first transmit when no packets in flight */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1d65ce1..a61a3e3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -61,6 +61,18 @@ int sysctl_tcp_base_mss __read_mostly =3D 512;
 /* By default, RFC2861 behavior.  */
 int sysctl_tcp_slow_start_after_idle __read_mostly =3D 1;
=20
+static inline void tcp_packets_out_inc(struct sock *sk,
+				       const struct sk_buff *skb)
+{
+	struct tcp_sock *tp =3D tcp_sk(sk);
+	int orig =3D tp->packets_out;
+
+	tp->packets_out +=3D tcp_skb_pcount(skb);
+	if (!orig)
+		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
+					  inet_csk(sk)->icsk_rto, TCP_RTO_MAX);
+}
+
 static void update_send_head(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
--=20
1.5.0.6

