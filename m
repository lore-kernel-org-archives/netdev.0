From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [DEVELOPER PATCH 5/5] [TCP]: Track sacktag
Date: Mon, 24 Sep 2007 13:28:47 +0300
Message-ID: <11906297272611-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11906297271684-git-send-email-ilpo.jarvinen@helsinki.fi> <11906297272364-git-send-email-ilpo.jarvinen@helsinki.fi> <11906297271155-git-send-email-ilpo.jarvinen@helsinki.fi> <11906297274028-git-send-email-ilpo.jarvinen@helsinki.fi> <1190629727956-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	SANGTAE HA <sangtae.ha@gmail.com>,
	Tom Quetchenbach <virtualphtn@gmail.com>,
	Baruch Even <bar
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47089 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753499AbXIXK2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 06:28:51 -0400
In-Reply-To: <1190629727956-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/snmp.h |   20 +++++++++++++++++++
 net/ipv4/proc.c      |   20 +++++++++++++++++++
 net/ipv4/tcp_input.c |   52 ++++++++++++++++++++++++++++++++++++++++++=
+++++--
 3 files changed, 89 insertions(+), 3 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 89f0c2b..42b8c07 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -214,6 +214,26 @@ enum
 	LINUX_MIB_TCPDSACKIGNOREDOLD,		/* TCPSACKIgnoredOld */
 	LINUX_MIB_TCPDSACKIGNOREDNOUNDO,	/* TCPSACKIgnoredNoUndo */
 	LINUX_MIB_TCPSPURIOUSRTOS,		/* TCPSpuriousRTOs */
+	LINUX_MIB_TCP_SACKTAG,
+	LINUX_MIB_TCP_SACK0,
+	LINUX_MIB_TCP_SACK1,
+	LINUX_MIB_TCP_SACK2,
+	LINUX_MIB_TCP_SACK3,
+	LINUX_MIB_TCP_SACK4,
+	LINUX_MIB_TCP_WALKEDSKBS,
+	LINUX_MIB_TCP_WALKEDDSACKS,
+	LINUX_MIB_TCP_SKIPPEDSKBS,
+	LINUX_MIB_TCP_NOCACHE,
+	LINUX_MIB_TCP_FULLWALK,
+	LINUX_MIB_TCP_HEADWALK,
+	LINUX_MIB_TCP_TAILWALK,
+	LINUX_MIB_TCP_FULLSKIP,
+	LINUX_MIB_TCP_TAILSKIP,
+	LINUX_MIB_TCP_HEADSKIP,
+	LINUX_MIB_TCP_FULLSKIP_TOHIGH,
+	LINUX_MIB_TCP_TAILSKIP_TOHIGH,
+	LINUX_MIB_TCP_NEWSKIP,
+	LINUX_MIB_TCP_CACHEREMAINING,
 	__LINUX_MIB_MAX
 };
=20
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 9dee70e..4808f82 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -246,6 +246,26 @@ static const struct snmp_mib snmp4_net_list[] =3D =
{
 	SNMP_MIB_ITEM("TCPDSACKIgnoredOld", LINUX_MIB_TCPDSACKIGNOREDOLD),
 	SNMP_MIB_ITEM("TCPDSACKIgnoredNoUndo", LINUX_MIB_TCPDSACKIGNOREDNOUND=
O),
 	SNMP_MIB_ITEM("TCPSpuriousRTOs", LINUX_MIB_TCPSPURIOUSRTOS),
+	SNMP_MIB_ITEM("TCP_SACKTAG", LINUX_MIB_TCP_SACKTAG),
+	SNMP_MIB_ITEM("TCP_SACK0", LINUX_MIB_TCP_SACK0),
+	SNMP_MIB_ITEM("TCP_SACK1", LINUX_MIB_TCP_SACK1),
+	SNMP_MIB_ITEM("TCP_SACK2", LINUX_MIB_TCP_SACK2),
+	SNMP_MIB_ITEM("TCP_SACK3", LINUX_MIB_TCP_SACK3),
+	SNMP_MIB_ITEM("TCP_SACK4", LINUX_MIB_TCP_SACK4),
+	SNMP_MIB_ITEM("TCP_WALKEDSKBS", LINUX_MIB_TCP_WALKEDSKBS),
+	SNMP_MIB_ITEM("TCP_WALKEDDSACKS", LINUX_MIB_TCP_WALKEDDSACKS),
+	SNMP_MIB_ITEM("TCP_SKIPPEDSKBS", LINUX_MIB_TCP_SKIPPEDSKBS),
+	SNMP_MIB_ITEM("TCP_NOCACHE", LINUX_MIB_TCP_NOCACHE),
+	SNMP_MIB_ITEM("TCP_FULLWALK", LINUX_MIB_TCP_FULLWALK),
+	SNMP_MIB_ITEM("TCP_HEADWALK", LINUX_MIB_TCP_HEADWALK),
+	SNMP_MIB_ITEM("TCP_TAILWALK", LINUX_MIB_TCP_TAILWALK),
+	SNMP_MIB_ITEM("TCP_FULLSKIP", LINUX_MIB_TCP_FULLSKIP),
+	SNMP_MIB_ITEM("TCP_TAILSKIP", LINUX_MIB_TCP_TAILSKIP),
+	SNMP_MIB_ITEM("TCP_HEADSKIP", LINUX_MIB_TCP_HEADSKIP),
+	SNMP_MIB_ITEM("TCP_FULLSKIP_TOHIGH", LINUX_MIB_TCP_FULLSKIP_TOHIGH),
+	SNMP_MIB_ITEM("TCP_TAILSKIP_TOHIGH", LINUX_MIB_TCP_TAILSKIP_TOHIGH),
+	SNMP_MIB_ITEM("TCP_NEWSKIP", LINUX_MIB_TCP_NEWSKIP),
+	SNMP_MIB_ITEM("TCP_CACHEREMAINING", LINUX_MIB_TCP_CACHEREMAINING),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9dfdd67..38045c8 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1306,6 +1306,10 @@ static struct sk_buff *tcp_sacktag_walk(struct s=
k_buff *skb, struct sock *sk,
=20
 		tcp_sacktag_one(skb, sk, state, in_sack, dup_sack,
 				state->fack_count, end_seq);
+
+		NET_INC_STATS_BH(LINUX_MIB_TCP_WALKEDSKBS);
+		if (dup_sack)
+			NET_INC_STATS_BH(LINUX_MIB_TCP_WALKEDDSACKS);
 	}
 	return skb;
 }
@@ -1329,6 +1333,7 @@ static struct sk_buff *tcp_sacktag_skip(struct sk=
_buff *skb, struct sock *sk,
 			skb =3D tcp_sacktag_walk(skb, sk, state, state->dup_start,
 					       state->dup_end, 1);
 		}
+		NET_INC_STATS_BH(LINUX_MIB_TCP_SKIPPEDSKBS);
 	}
 	return skb;
 }
@@ -1458,9 +1463,22 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb, u32 prior_snd_
 			cache++;
 	}
=20
+	NET_INC_STATS_BH(LINUX_MIB_TCP_SACKTAG);
+	switch (used_sacks) {
+		case 0: NET_INC_STATS_BH(LINUX_MIB_TCP_SACK0); break;
+		case 1: NET_INC_STATS_BH(LINUX_MIB_TCP_SACK1); break;
+		case 2: NET_INC_STATS_BH(LINUX_MIB_TCP_SACK2); break;
+		case 3: NET_INC_STATS_BH(LINUX_MIB_TCP_SACK3); break;
+		case 4: NET_INC_STATS_BH(LINUX_MIB_TCP_SACK4); break;
+	}
+
+	if (!tcp_sack_cache_ok(tp, cache))
+		NET_INC_STATS_BH(LINUX_MIB_TCP_NOCACHE);
+
 	while (i < used_sacks) {
 		u32 start_seq =3D sp[i].start_seq;
 		u32 end_seq =3D sp[i].end_seq;
+		int fullwalk =3D 0;
=20
 		/* Event "B" in the comment above. */
 		if (after(end_seq, tp->high_seq))
@@ -1473,41 +1491,69 @@ tcp_sacktag_write_queue(struct sock *sk, struct=
 sk_buff *ack_skb, u32 prior_snd_
=20
 		if (tcp_sack_cache_ok(tp, cache)) {
 			if (after(end_seq, cache->start_seq)) {
+				int headskip =3D 0;
+
 				if (before(start_seq, cache->start_seq)) {
 					skb =3D tcp_sacktag_skip(skb, sk, &state, start_seq);
 					skb =3D tcp_sacktag_walk(skb, sk, &state, start_seq, cache->start=
_seq, 0);
-				}
+					NET_INC_STATS_BH(LINUX_MIB_TCP_HEADWALK);
+				} else
+					headskip =3D 1;
+
 				/* Rest of the block already fully processed? */
 				if (!after(end_seq, cache->end_seq)) {
 					i++;
+					if (headskip)
+						NET_INC_STATS_BH(LINUX_MIB_TCP_FULLSKIP);
+					else
+						NET_INC_STATS_BH(LINUX_MIB_TCP_TAILSKIP);
 					continue;
 				}
+
 				if (TCP_SKB_CB(tp->highest_sack)->end_seq !=3D cache->end_seq) {
 					skb =3D tcp_sacktag_skip(skb, sk, &state, cache->end_seq);
 					cache++;
+					if (headskip)
+						NET_INC_STATS_BH(LINUX_MIB_TCP_HEADSKIP);
 					continue;
 				}
=20
 				skb =3D tcp_sacktag_skip_to_highsack(skb, sk, &state, cache);
-			}
+				if (headskip)
+					NET_INC_STATS_BH(LINUX_MIB_TCP_FULLSKIP_TOHIGH);
+				else
+					NET_INC_STATS_BH(LINUX_MIB_TCP_TAILSKIP_TOHIGH);
+			} else
+				fullwalk =3D 1;
 		} else if (!before(start_seq, tcp_highest_sack_seq(sk)) &&
 			   before(TCP_SKB_CB(skb)->seq, tcp_highest_sack_seq(sk))) {
 			skb =3D tcp_write_queue_next(sk, tp->highest_sack);
 			state.fack_count =3D tp->fackets_out;
+			NET_INC_STATS_BH(LINUX_MIB_TCP_NEWSKIP);
+			fullwalk =3D 1;
 		}
=20
 		skb =3D tcp_sacktag_skip(skb, sk, &state, start_seq);
 		skb =3D tcp_sacktag_walk(skb, sk, &state, start_seq, end_seq, 0);
+		if (fullwalk)
+			NET_INC_STATS_BH(LINUX_MIB_TCP_FULLWALK);
+		else
+			NET_INC_STATS_BH(LINUX_MIB_TCP_TAILWALK);
 		i++;
 	}
=20
+	if (tcp_sack_cache_ok(tp, cache))
+		NET_INC_STATS_BH(LINUX_MIB_TCP_CACHEREMAINING);
+
 	/* Clear the head of the cache sack blocks so we can skip it next tim=
e */
 	for (i =3D 0; i < ARRAY_SIZE(tp->recv_sack_cache) - used_sacks; i++) =
{
 		tp->recv_sack_cache[i].start_seq =3D 0;
 		tp->recv_sack_cache[i].end_seq =3D 0;
 	}
-	for (j =3D 0; j < used_sacks; j++)
+	for (j =3D 0; j < used_sacks; j++) {
+		WARN_ON(i >=3D ARRAY_SIZE(tp->recv_sack_cache));
 		tp->recv_sack_cache[i++] =3D sp[j];
+	}
=20
 	/* Check for lost retransmit. This superb idea is
 	 * borrowed from "ratehalving". Event "C".
--=20
1.5.0.6

