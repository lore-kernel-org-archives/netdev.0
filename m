From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] bridge: fix br_multicast_query_expired() bug
Date: Thu, 28 May 2015 04:42:54 -0700
Message-ID: <1432813374.16878.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Linus =?ISO-8859-1?Q?L=FCssing?= <linus.luessing@web.de>,
	"Steinar H. Gunderson" <sesse@samfundet.no>,
	Stephen Hemminger <stephen@networkplumber.org>,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35797 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758AbbE1Lm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 07:42:56 -0400
Received: by iesa3 with SMTP id a3so35947576ies.2
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 04:42:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

br_multicast_query_expired() querier argument is a pointer to
a struct bridge_mcast_querier :

struct bridge_mcast_querier {
        struct br_ip addr;
        struct net_bridge_port __rcu    *port;
};

Intent of the code was to clear port field, not the pointer to querier.

=46ixes: 2cd4143192e8 ("bridge: memorize and export selected IGMP/MLD q=
uerier port")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Linus L=C3=BCssing <linus.luessing@web.de>
Cc: Steinar H. Gunderson <sesse@samfundet.no>
---
 net/bridge/br_multicast.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index a3abe6ed111e..22fd0419b314 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1822,7 +1822,7 @@ static void br_multicast_query_expired(struct net=
_bridge *br,
 	if (query->startup_sent < br->multicast_startup_query_count)
 		query->startup_sent++;
=20
-	RCU_INIT_POINTER(querier, NULL);
+	RCU_INIT_POINTER(querier->port, NULL);
 	br_multicast_send_query(br, NULL, query);
 	spin_unlock(&br->multicast_lock);
 }
