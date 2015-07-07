From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 3/3] ipmr_free_table() should be called under taken rtnl_lock
Date: Tue, 07 Jul 2015 18:53:55 +0300
Message-ID: <559BF613.7090904@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20581 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757897AbbGGPzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2015 11:55:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ipmr_free_table() calls unregister_netdevice_many() inside
and changes net_todo_list protected by rtnl_lock

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 net/ipv6/ip6mr.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 74ceb73..9108636 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -250,7 +250,9 @@ static int __net_init ip6mr_rules_init(struct net *net)
 	return 0;
 
 err2:
+	rtnl_lock();
 	ip6mr_free_table(mrt);
+	rtnl_unlock();
 err1:
 	fib_rules_unregister(ops);
 	return err;
-- 
1.9.1
