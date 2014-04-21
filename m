From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH] bridge: simplify a br_multicast_query_received() function call
Date: Mon, 21 Apr 2014 20:59:35 +0200
Message-ID: <1398106775-14857-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:58131 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328AbaDUS7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2014 14:59:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The call from the IPv6 part can be simplified as the beginning of the
calling function ensures that we end up here when having a proper IPv6
source address only.

Introduced by 6565b9eeef194afbb3beec80d6dd2447f4091f8c
("bridge: multicast: add sanity check for query source addresses")

Reported-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 7b757b5..d2c3aae 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1282,8 +1282,7 @@ static int br_ip6_multicast_query(struct net_brid=
ge *br,
 		goto out;
 	}
=20
-	br_multicast_query_received(br, port, &br->ip6_querier,
-				    !ipv6_addr_any(&ip6h->saddr),
+	br_multicast_query_received(br, port, &br->ip6_querier, 1,
 				    is_general_query, max_delay);
=20
 	if (!group)
--=20
1.7.10.4
