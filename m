From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net-netlink: Add a new attribute to expose TCLASS values via netlink
Date: Mon,  7 Nov 2011 16:23:11 -0800
Message-ID: <1320711791-11005-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Murali Raja <muralira@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:48106 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466Ab1KHAXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 19:23:38 -0500
Received: by qyk27 with SMTP id 27so3044741qyk.19
        for <netdev@vger.kernel.org>; Mon, 07 Nov 2011 16:23:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

commit 3ceca749668a52bd795585e0f71c6f0b04814f7b added a TOS attribute.

Unfortunately TOS and TCLASS are both present in a dual-stack v6 socket=
,
furthermore they can have different values.  As such one cannot in a
sane way expose both through a single attribute.

Signed-off-by: Maciej =C5=BBenczyowski <maze@google.com>
CC: Murali Raja <muralira@google.com>
CC: Stephen Hemminger <shemminger@vyatta.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
CC: David S. Miller <davem@davemloft.net>
---
 include/linux/inet_diag.h |    3 ++-
 net/ipv4/inet_diag.c      |    4 ++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 80b480c..abf5028 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -98,9 +98,10 @@ enum {
 	INET_DIAG_VEGASINFO,
 	INET_DIAG_CONG,
 	INET_DIAG_TOS,
+	INET_DIAG_TCLASS,
 };
=20
-#define INET_DIAG_MAX INET_DIAG_TOS
+#define INET_DIAG_MAX INET_DIAG_TCLASS
=20
=20
 /* INET_DIAG_MEM */
diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index f5e2bda..68e8ac5 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -133,8 +133,8 @@ static int inet_csk_diag_fill(struct sock *sk,
 			       &np->rcv_saddr);
 		ipv6_addr_copy((struct in6_addr *)r->id.idiag_dst,
 			       &np->daddr);
-		if (ext & (1 << (INET_DIAG_TOS - 1)))
-			RTA_PUT_U8(skb, INET_DIAG_TOS, np->tclass);
+		if (ext & (1 << (INET_DIAG_TCLASS - 1)))
+			RTA_PUT_U8(skb, INET_DIAG_TCLASS, np->tclass);
 	}
 #endif
=20
--=20
1.7.3.1
