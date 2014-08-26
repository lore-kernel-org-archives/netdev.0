From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Subject: [PATCH] ipv6: ip6_gre: Replace rcu_assign_pointer() with
 RCU_INIT_POINTER()
Date: Tue, 26 Aug 2014 17:13:50 +0300
Message-ID: <20140826141350.GA2036@ada>
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
 net/ipv6/ip6_gre.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 3873181..67dcaca 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -261,7 +261,7 @@ static void ip6gre_tunnel_link(struct ip6gre_net *ign, struct ip6_tnl *t)
 {
 	struct ip6_tnl __rcu **tp = ip6gre_bucket(ign, t);
 
-	rcu_assign_pointer(t->next, rtnl_dereference(*tp));
+	RCU_INIT_POINTER(t->next, rtnl_dereference(*tp));
 	rcu_assign_pointer(*tp, t);
 }
 
-- 
1.9.1
