From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v2 2/5] ipvlan: plug memory leak in ipvlan_link_delete
Date: Fri, 03 Jul 2015 15:58:37 +0300
Message-ID: <20150703125837.24121.54113.stgit@buzz>
References: <20150703125132.24121.50592.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>, Jiri Benc <jbenc@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1g.mail.yandex.net ([95.108.253.251]:59517 "EHLO
	forward-corp1g.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755169AbbGCM6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 08:58:40 -0400
In-Reply-To: <20150703125132.24121.50592.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing kfree_rcu(addr, rcu);

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 drivers/net/ipvlan/ipvlan_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 62577b3f01f2..4c3a0ac85381 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -507,6 +507,7 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 	list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
 		ipvlan_ht_addr_del(addr, !dev->dismantle);
 		list_del(&addr->anode);
+		kfree_rcu(addr, rcu);
 	}
 
 	list_del_rcu(&ipvlan->pnode);
