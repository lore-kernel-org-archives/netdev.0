From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 1/2] bridge: multicast: notify on group delete
Date: Wed, 15 Jul 2015 07:16:50 -0700
Message-ID: <1436969811-13237-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1436969811-13237-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: bridge@lists.linux-foundation.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, stephen@networkplumber.org,
	sashok@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35593 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751969AbbGOOR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2015 10:17:57 -0400
Received: by pdrg1 with SMTP id g1so25832632pdr.2
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2015 07:17:56 -0700 (PDT)
In-Reply-To: <1436969811-13237-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Group notifications were not sent when a group expired or was deleted
due to bridge/port device being deleted. So add br_mdb_notify() to
br_multicast_del_pg().

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_multicast.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 5a44cd9473f2..55903d91d0a8 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -273,6 +273,8 @@ static void br_multicast_del_pg(struct net_bridge *br,
 		rcu_assign_pointer(*pp, p->next);
 		hlist_del_init(&p->mglist);
 		del_timer(&p->timer);
+		br_mdb_notify(br->dev, p->port, &pg->addr, RTM_DELMDB,
+			      p->state);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
 
 		if (!mp->ports && !mp->mglist &&
-- 
1.9.3
