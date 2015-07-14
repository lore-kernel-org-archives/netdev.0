From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH v3 2/5] ipvlan: plug memory leak in ipvlan_link_delete
Date: Tue, 14 Jul 2015 16:35:51 +0300
Message-ID: <20150714133551.22448.48397.stgit@buzz>
References: <20150714132941.22448.42175.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jiri Benc <jbenc@redhat.com>
To: linux-netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1m.cmail.yandex.net ([5.255.216.100]:34842 "EHLO
	forward-corp1m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751971AbbGNNf4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 09:35:56 -0400
In-Reply-To: <20150714132941.22448.42175.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing kfree_rcu(addr, rcu);

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 drivers/net/ipvlan/ipvlan_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 048ecf0c76fb..7d81e37c3f76 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -507,6 +507,7 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 	list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
 		ipvlan_ht_addr_del(addr, !dev->dismantle);
 		list_del(&addr->anode);
+		kfree_rcu(addr, rcu);
 	}
 
 	list_del_rcu(&ipvlan->pnode);
