From: Dave Jones <davej@redhat.com>
Subject: swapped memset arguments.
Date: Mon, 21 Mar 2005 21:44:57 -0500
Message-ID: <20050322024457.GA11569@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

You wouldn't believe how many instances of this bug I've
seen in the last few days in both userspace and kernelspace.

Signed-off-by: Dave Jones <davej@redhat.com>

--- bk-linus/net/ipv4/multipath_wrandom.c~	2005-03-21 21:40:15.535597104 -0500
+++ bk-linus/net/ipv4/multipath_wrandom.c	2005-03-21 21:40:41.406664104 -0500
@@ -248,7 +248,7 @@ static void wrandom_set_nhinfo(__u32 net
 
 		target_route->gw = nh->nh_gw;
 		target_route->oif = nh->nh_oif;
-		memset(&target_route->rcu, sizeof(struct rcu_head), 0);
+		memset(&target_route->rcu, 0, sizeof(struct rcu_head));
 		INIT_LIST_HEAD(&target_route->dests);
 
 		list_add_rcu(&target_route->list, &state[state_idx].head);
@@ -271,7 +271,7 @@ static void wrandom_set_nhinfo(__u32 net
 		target_dest->network = network;
 		target_dest->netmask = netmask;
 		target_dest->prefixlen = prefixlen;
-		memset(&target_dest->rcu, sizeof(struct rcu_head), 0);
+		memset(&target_dest->rcu, 0, sizeof(struct rcu_head));
 
 		list_add_rcu(&target_dest->list, &target_route->dests);
 	}
