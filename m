From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH 3/3] [TCP] MIB: Count FRTO's successfully detected spurious RTOs
Date: Mon, 24 Sep 2007 12:04:08 +0300
Message-ID: <11906246481619-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11906246483472-git-send-email-ilpo.jarvinen@helsinki.fi> <11906246483657-git-send-email-ilpo.jarvinen@helsinki.fi> <11906246484144-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55584 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751636AbXIXJEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 05:04:10 -0400
In-Reply-To: <11906246484144-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/snmp.h |    1 +
 net/ipv4/proc.c      |    1 +
 net/ipv4/tcp_input.c |    1 +
 3 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/snmp.h b/include/linux/snmp.h
index d8fd3ec..89f0c2b 100644
--- a/include/linux/snmp.h
+++ b/include/linux/snmp.h
@@ -213,6 +213,7 @@ enum
 	LINUX_MIB_TCPSACKDISCARD,		/* TCPSACKDiscard */
 	LINUX_MIB_TCPDSACKIGNOREDOLD,		/* TCPSACKIgnoredOld */
 	LINUX_MIB_TCPDSACKIGNOREDNOUNDO,	/* TCPSACKIgnoredNoUndo */
+	LINUX_MIB_TCPSPURIOUSRTOS,		/* TCPSpuriousRTOs */
 	__LINUX_MIB_MAX
 };
=20
diff --git a/net/ipv4/proc.c b/net/ipv4/proc.c
index 2015148..9dee70e 100644
--- a/net/ipv4/proc.c
+++ b/net/ipv4/proc.c
@@ -245,6 +245,7 @@ static const struct snmp_mib snmp4_net_list[] =3D {
 	SNMP_MIB_ITEM("TCPSACKDiscard", LINUX_MIB_TCPSACKDISCARD),
 	SNMP_MIB_ITEM("TCPDSACKIgnoredOld", LINUX_MIB_TCPDSACKIGNOREDOLD),
 	SNMP_MIB_ITEM("TCPDSACKIgnoredNoUndo", LINUX_MIB_TCPDSACKIGNOREDNOUND=
O),
+	SNMP_MIB_ITEM("TCPSpuriousRTOs", LINUX_MIB_TCPSPURIOUSRTOS),
 	SNMP_MIB_SENTINEL
 };
=20
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ae06b94..259f517 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2935,6 +2935,7 @@ static int tcp_process_frto(struct sock *sk, int =
flag)
 		}
 		tp->frto_counter =3D 0;
 		tp->undo_marker =3D 0;
+		NET_INC_STATS_BH(LINUX_MIB_TCPSPURIOUSRTOS);
 	}
 	return 0;
 }
--=20
1.5.0.6

