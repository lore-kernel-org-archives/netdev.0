From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Subject: [PATCH] ipv6: sit: Replace rcu_assign_pointer() with
 RCU_INIT_POINTER()
Date: Tue, 26 Aug 2014 16:46:32 +0300
Message-ID: <20140826134632.GA1473@ada>
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

According to RCU_INIT_POINTER()'s block comment 3.a, it can be used if
"3.   The referenced data structure has already been exposed to readers either
at compile time or via rcu_assign_pointer() -and-
 a.   You have not made -any- reader-visible changes to this structure since
then".

This case fulfills the conditions above because between the rtnl_dereference()
call and the rcu_assign_pointer() call there is no update of that value.
Therefore, this patch makes the replacement.

The following Coccinelle semantic patch was used:
@@
@@

- rcu_assign_pointer
+ RCU_INIT_POINTER
  (...,
(
 rtnl_dereference(...)
|
 rcu_dereference_protected(...)
) )

Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>
---
 net/ipv6/sit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 4f40817..24c2dba 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -167,7 +167,7 @@ static void ipip6_tunnel_link(struct sit_net *sitn, struct ip_tunnel *t)
 {
 	struct ip_tunnel __rcu **tp = ipip6_bucket(sitn, t);
 
-	rcu_assign_pointer(t->next, rtnl_dereference(*tp));
+	RCU_INIT_POINTER(t->next, rtnl_dereference(*tp));
 	rcu_assign_pointer(*tp, t);
 }
 
-- 
1.9.1
