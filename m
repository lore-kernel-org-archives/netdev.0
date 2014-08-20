From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] dn_dev: Use time_before
Date: Wed, 20 Aug 2014 23:13:07 +0530
Message-ID: <20140820174306.GA4180@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julia Lawall <julia.lawall@lip6.fr>
To: "David S. Miller" <davem@davemloft.net>,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The functions time_before, time_before_eq, time_after, and time_after_eq
are more robust for comparing jiffies against other values.

A simplified version of the Coccinelle semantic patch making this change
is as follows:

@change@
expression E1,E2;
@@

(
- (jiffies - E1) < E2
+ time_before(jiffies, E1+E2)
)

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 net/decnet/dn_dev.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 3b726f3..4400da7 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -41,6 +41,7 @@
 #include <linux/sysctl.h>
 #include <linux/notifier.h>
 #include <linux/slab.h>
+#include <linux/jiffies.h>
 #include <asm/uaccess.h>
 #include <net/net_namespace.h>
 #include <net/neighbour.h>
@@ -875,7 +876,7 @@ static void dn_send_endnode_hello(struct net_device *dev, struct dn_ifaddr *ifa)
 static int dn_am_i_a_router(struct dn_neigh *dn, struct dn_dev *dn_db, struct dn_ifaddr *ifa)
 {
 	/* First check time since device went up */
-	if ((jiffies - dn_db->uptime) < DRDELAY)
+	if (time_before(jiffies, dn_db->uptime + DRDELAY))
 		return 0;
 
 	/* If there is no router, then yes... */
-- 
1.9.1
