From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/3] net: Kill ratelimit.h dependency in linux/net.h
Date: Thu, 26 May 2011 16:43:30 -0400 (EDT)
Message-ID: <20110526.164330.2076981043593394399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47333 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321Ab1EZUng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2011 16:43:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Ingo Molnar noticed that we have this unnecessary ratelimit.h
dependency in linux/net.h, which hid compilation problems from
people doing builds only with CONFIG_NET enabled.

Move this stuff out to a seperate net/net_ratelimit.h file and
include that in the only two places where this thing is needed.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/net.h        |    6 ------
 net/core/sysctl_net_core.c |    1 +
 net/core/utils.c           |    1 +
 3 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index 1da55e9..b299230 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -289,11 +289,5 @@ extern int kernel_sock_shutdown(struct socket *sock,
 	MODULE_ALIAS("net-pf-" __stringify(pf) "-proto-" __stringify(proto) \
 		     "-type-" __stringify(type))
 
-#ifdef CONFIG_SYSCTL
-#include <linux/sysctl.h>
-#include <linux/ratelimit.h>
-extern struct ratelimit_state net_ratelimit_state;
-#endif
-
 #endif /* __KERNEL__ */
 #endif	/* _LINUX_NET_H */
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index a829e3f..77a65f0 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -17,6 +17,7 @@
 
 #include <net/ip.h>
 #include <net/sock.h>
+#include <net/net_ratelimit.h>
 
 #ifdef CONFIG_RPS
 static int rps_sock_flow_sysctl(ctl_table *table, int write,
diff --git a/net/core/utils.c b/net/core/utils.c
index 2012bc7..386e263f 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -27,6 +27,7 @@
 #include <linux/ratelimit.h>
 
 #include <net/sock.h>
+#include <net/net_ratelimit.h>
 
 #include <asm/byteorder.h>
 #include <asm/system.h>
-- 
1.7.4.4

