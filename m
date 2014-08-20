From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] decnet: Use time_after_eq
Date: Wed, 20 Aug 2014 23:20:09 +0530
Message-ID: <20140820175009.GA4316@himangi-Dell>
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
- (jiffies - E1) >= E2
+ time_after_eq(jiffies, E1+E2)

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
Acked-by: Julia Lawall <julia.lawall@lip6.fr>
---
 net/decnet/dn_timer.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/decnet/dn_timer.c b/net/decnet/dn_timer.c
index d9c150c..1d330fd 100644
--- a/net/decnet/dn_timer.c
+++ b/net/decnet/dn_timer.c
@@ -23,6 +23,7 @@
 #include <linux/spinlock.h>
 #include <net/sock.h>
 #include <linux/atomic.h>
+#include <linux/jiffies.h>
 #include <net/flow.h>
 #include <net/dn.h>
 
@@ -91,7 +92,7 @@ static void dn_slow_timer(unsigned long arg)
 	 * since the last successful transmission.
 	 */
 	if (scp->keepalive && scp->keepalive_fxn && (scp->state == DN_RUN)) {
-		if ((jiffies - scp->stamp) >= scp->keepalive)
+		if (time_after_eq(jiffies, scp->stamp + scp->keepalive))
 			scp->keepalive_fxn(sk);
 	}
 
-- 
1.9.1
