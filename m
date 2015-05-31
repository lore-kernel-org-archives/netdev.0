From: David Miller <davem@davemloft.net>
Subject: [PATCH] bridge: fix br_multicast_query_expired() bug
Date: Sat, 30 May 2015 23:33:05 -0700 (PDT)
Message-ID: <20150530.233305.2218119917750921299.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39177 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884AbbEaGdG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 02:33:06 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 18E85581AB1
	for <netdev@vger.kernel.org>; Sat, 30 May 2015 23:33:06 -0700 (PDT)
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
Acked-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Acked-by: Linus L=FCssing <linus.luessing@c0d3.blue>
Cc: Linus L=FCssing <linus.luessing@web.de>
Cc: Steinar H. Gunderson <sesse@samfundet.no>
Signed-off-by: David S. Miller <davem@davemloft.net>
---

Posting this to the list so it gets into patchwork and I can properly
queue it up for -stable.

 net/bridge/br_multicast.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index a3abe6e..22fd041 100644
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
--=20
2.1.0
