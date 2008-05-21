From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] netfilter: conntrack_helper needs to include rculist.h
Date: Wed, 21 May 2008 14:21:39 -0700
Message-ID: <20080521142139.f0bc5698.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, akpm <akpm@linux-foundation.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

nf_conntrack_helper users rcu hlist functions so it needs to #include
rculist.h.

linux-next-20080521/net/netfilter/nf_conntrack_helper.c:58: error: implicit declaration of function 'hlist_for_each_entry_rcu'
linux-next-20080521/net/netfilter/nf_conntrack_helper.c:58: error: 'hnode' undeclared (first use in this function)
linux-next-20080521/net/netfilter/nf_conntrack_helper.c:58: error: (Each undeclared identifier is reported only once
linux-next-20080521/net/netfilter/nf_conntrack_helper.c:58: error: for each function it appears in.)
linux-next-20080521/net/netfilter/nf_conntrack_helper.c:58: error: expected ';' before '{' token
linux-next-20080521/net/netfilter/nf_conntrack_helper.c:50: warning: unused variable 'mask'
linux-next-20080521/net/netfilter/nf_conntrack_helper.c:74: error: 'hnode' undeclared (first use in this function)
linux-next-20080521/net/netfilter/nf_conntrack_helper.c:74: error: expected ';' before '{' token
linux-next-20080521/net/netfilter/nf_conntrack_helper.c:117: error: implicit declaration of function 'hlist_add_head_rcu'
linux-next-20080521/net/netfilter/nf_conntrack_helper.c:133: error: implicit declaration of function 'hlist_del_rcu'
filter/nf_conntrack_helper.o] Error 1

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/netfilter/nf_conntrack_helper.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20080521.orig/net/netfilter/nf_conntrack_helper.c
+++ linux-next-20080521/net/netfilter/nf_conntrack_helper.c
@@ -10,6 +10,7 @@
  */
 
 #include <linux/types.h>
+#include <linux/rculist.h>
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
