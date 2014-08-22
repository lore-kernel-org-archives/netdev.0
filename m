From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Subject: [PATCH] br_multicast: Replace rcu_assign_pointer() with
 RCU_INIT_POINTER()
Date: Fri, 22 Aug 2014 16:06:09 +0300
Message-ID: <20140822130609.GA19576@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com
To: stephen@networkplumber.org, davem@davemloft.net,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The use of "rcu_assign_pointer()" is NULLing out the pointer.
According to RCU_INIT_POINTER()'s block comment:
"1.   This use of RCU_INIT_POINTER() is NULLing out the pointer"
it is better to use it instead of rcu_assign_pointer() because it has a
smaller overhead.

The following Coccinelle semantic patch was used:
@@
@@

- rcu_assign_pointer
+ RCU_INIT_POINTER
  (..., NULL)

Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
---
 net/bridge/br_multicast.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index abfa0b65..9b64383 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1822,7 +1822,7 @@ static void br_multicast_query_expired(struct net_bridge *br,
 	if (query->startup_sent < br->multicast_startup_query_count)
 		query->startup_sent++;
 
-	rcu_assign_pointer(querier, NULL);
+	RCU_INIT_POINTER(querier, NULL);
 	br_multicast_send_query(br, NULL, query);
 	spin_unlock(&br->multicast_lock);
 }
-- 
1.9.1
