From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Subject: [PATCH] net/ipv4/igmp.c: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Sun, 17 Aug 2014 15:49:41 +0300
Message-ID: <20140817124941.GA14000@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck@linux.vnet.ibm.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "rcu_dereference()" call is used directly in a condition.
Since its return value is never dereferenced it is recommended to use
"rcu_access_pointer()" instead of "rcu_dereference()".
Therefore, this patch makes the replacement.

The following Coccinelle semantic patch was used:
@@
@@

(
 if(
 (<+...
- rcu_dereference
+ rcu_access_pointer
  (...)
  ...+>)) {...}
|
 while(
 (<+...
- rcu_dereference
+ rcu_access_pointer
  (...)
  ...+>)) {...}
)

Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
---
 net/ipv4/igmp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 6748d42..94a96ad 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2537,7 +2537,7 @@ static int igmp_mc_seq_show(struct seq_file *seq, void *v)
 		querier = "NONE";
 #endif
 
-		if (rcu_dereference(state->in_dev->mc_list) == im) {
+		if (rcu_access_pointer(state->in_dev->mc_list) == im) {
 			seq_printf(seq, "%d\t%-10s: %5d %7s\n",
 				   state->dev->ifindex, state->dev->name, state->in_dev->mc_count, querier);
 		}
-- 
1.9.1
