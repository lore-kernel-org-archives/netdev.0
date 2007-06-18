From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH tcp-2.6 2/2] [TCP] MIB: Add counter for discarded SACK blocks
Date: Tue, 19 Jun 2007 01:25:58 +0300
Message-ID: <11822055583190-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1182205558580-git-send-email-ilpo.jarvinen@helsinki.fi> <1182205558564-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60342 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762537AbXFRW0B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 18:26:01 -0400
In-Reply-To: <1182205558564-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/snmp.h |    1 +
 net/ipv4/proc.c      |    1 +
 net/ipv4/tcp_input.c |    4 +++-
 3 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index 802b3a3..6e64a70 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -231,6 +231,7 @@ enum
 	LINUX_MIB_TCPABORTONLINGER,		/* TCPAbortOnLinger */
 	LINUX_MIB_TCPABORTFAILED,		/* TCPAbortFailed */
 	LINUX_MIB_TCPMEMORYPRESSURES,		/* TCPMemoryPressures */
+	LINUX_MIB_TCPSACKDISCARD,		/* TCPSACKDiscard */
 	__LINUX_MIB_MAX
 };
=20
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 3b690cf..d5a8de0 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -244,6 +244,7 @@ static const struct snmp_mib snmp4_net_list[] =3D {
 	SNMP_MIB_ITEM("TCPAbortOnLinger", LINUX_MIB_TCPABORTONLINGER),
 	SNMP_MIB_ITEM("TCPAbortFailed", LINUX_MIB_TCPABORTFAILED),
 	SNMP_MIB_ITEM("TCPMemoryPressures", LINUX_MIB_TCPMEMORYPRESSURES),
+	SNMP_MIB_ITEM("TCPSACKDiscard", LINUX_MIB_TCPSACKDISCARD),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ebd9739..e26d8ca 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1283,8 +1283,10 @@ tcp_sacktag_write_queue(struct sock *sk, struct =
sk_buff *ack_skb,
 		/* Discard SACK blocks that are seemingly bad */
 		if (before(start_seq, valid_range_start) ||
 		    after(end_seq, tp->snd_nxt) ||
-		    !before(start_seq, end_seq))
+		    !before(start_seq, end_seq)) {
+			NET_INC_STATS_BH(LINUX_MIB_TCPSACKDISCARD);
 			continue;
+		}
=20
 		skb =3D cached_skb;
 		fack_count =3D cached_fack_count;
--=20
1.5.0.6

