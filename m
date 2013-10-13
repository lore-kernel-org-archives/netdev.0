From: baker.kernel@gmail.com
Subject: [PATCH net-next] fib_trie: remove duplicated rcu lock
Date: Sun, 13 Oct 2013 08:13:37 +0800
Message-ID: <1381623217-5883-1-git-send-email-baker.kernel@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"baker.zhang" <baker.kernel@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "baker.zhang" <baker.kernel@gmail.com>

fib_table_lookup has included the rcu lock protection.

Signed-off-by: baker.zhang <baker.kernel@gmail.com>
---
 net/ipv4/fib_frontend.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index b3f627a..0e9127d 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -170,12 +170,10 @@ static inline unsigned int __inet_dev_addr_type(struct net *net,
 	local_table = fib_get_table(net, RT_TABLE_LOCAL);
 	if (local_table) {
 		ret = RTN_UNICAST;
-		rcu_read_lock();
 		if (!fib_table_lookup(local_table, &fl4, &res, FIB_LOOKUP_NOREF)) {
 			if (!dev || dev == res.fi->fib_dev)
 				ret = res.type;
 		}
-		rcu_read_unlock();
 	}
 	return ret;
 }
@@ -933,7 +931,6 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 		local_bh_disable();
 
 		frn->tb_id = tb->tb_id;
-		rcu_read_lock();
 		frn->err = fib_table_lookup(tb, &fl4, &res, FIB_LOOKUP_NOREF);
 
 		if (!frn->err) {
@@ -942,7 +939,6 @@ static void nl_fib_lookup(struct fib_result_nl *frn, struct fib_table *tb)
 			frn->type = res.type;
 			frn->scope = res.scope;
 		}
-		rcu_read_unlock();
 		local_bh_enable();
 	}
 }
-- 
1.8.1.2
