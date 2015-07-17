From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2 1/2] sctp: reduce indent level on sctp_v4_get_dst
Date: Fri, 17 Jul 2015 12:34:17 -0300
Message-ID: <3ad52d0eb6028974a0b6c9010de44772bf181169.1437145508.git.marcelo.leitner@gmail.com>
References: <cover.1437145508.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>
To: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51084 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758681AbbGQPe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 11:34:28 -0400
In-Reply-To: <cover.1437145508.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paves the day for the next patch. Functionality stays untouched.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/protocol.c | 32 +++++++++++++++++---------------
 1 file changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 59e80356672bdf89777265ae1f8c384792dfb98c..fa80fe4f23629fc3c3f5c44f99dbf3cc524cc6a0 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -489,21 +489,23 @@ static void sctp_v4_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	list_for_each_entry_rcu(laddr, &bp->address_list, list) {
 		if (!laddr->valid)
 			continue;
-		if ((laddr->state == SCTP_ADDR_SRC) &&
-		    (AF_INET == laddr->a.sa.sa_family)) {
-			fl4->fl4_sport = laddr->a.v4.sin_port;
-			flowi4_update_output(fl4,
-					     asoc->base.sk->sk_bound_dev_if,
-					     RT_CONN_FLAGS(asoc->base.sk),
-					     daddr->v4.sin_addr.s_addr,
-					     laddr->a.v4.sin_addr.s_addr);
-
-			rt = ip_route_output_key(sock_net(sk), fl4);
-			if (!IS_ERR(rt)) {
-				dst = &rt->dst;
-				goto out_unlock;
-			}
-		}
+		if (laddr->state != SCTP_ADDR_SRC ||
+		    AF_INET != laddr->a.sa.sa_family)
+			continue;
+
+		fl4->fl4_sport = laddr->a.v4.sin_port;
+		flowi4_update_output(fl4,
+				     asoc->base.sk->sk_bound_dev_if,
+				     RT_CONN_FLAGS(asoc->base.sk),
+				     daddr->v4.sin_addr.s_addr,
+				     laddr->a.v4.sin_addr.s_addr);
+
+		rt = ip_route_output_key(sock_net(sk), fl4);
+		if (IS_ERR(rt))
+			continue;
+
+		dst = &rt->dst;
+		break;
 	}
 
 out_unlock:
-- 
2.4.1
