From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v2] x25: convert printks to pr_<level>
Date: Thu, 5 Dec 2013 14:50:27 +0800
Message-ID: <52A02233.6040700@huawei.com>
References: <529FEDBC.9030302@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-x25@vger.kernel.org>, <netdev@vger.kernel.org>,
	Joe Perches <joe@perches.com>
To: David Miller <davem@davemloft.net>, <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:9974 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab3LEGuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 01:50:46 -0500
In-Reply-To: <529FEDBC.9030302@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

use pr_<level> instead of printk(LEVEL)

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 net/x25/af_x25.c         |  4 +++-
 net/x25/x25_dev.c        | 11 +++++++----
 net/x25/x25_facilities.c | 15 +++++++++------
 net/x25/x25_forward.c    |  5 ++++-
 net/x25/x25_in.c         |  4 +++-
 net/x25/x25_link.c       |  6 ++++--
 net/x25/x25_subr.c       |  7 +++++--
 7 files changed, 35 insertions(+), 17 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index 7622789..c8a8297 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -35,6 +35,8 @@
  *					response
  */
 
+#define pr_fmt(fmt) "X25: " fmt
+
 #include <linux/module.h>
 #include <linux/capability.h>
 #include <linux/errno.h>
@@ -1809,7 +1811,7 @@ static int __init x25_init(void)
 	if (rc != 0)
 		goto out_sock;
 
-	printk(KERN_INFO "X.25 for Linux Version 0.2\n");
+	pr_info("Linux Version 0.2\n");
 
 	x25_register_sysctl();
 	rc = x25_proc_init();
diff --git a/net/x25/x25_dev.c b/net/x25/x25_dev.c
index a8a2363..3759ca0 100644
--- a/net/x25/x25_dev.c
+++ b/net/x25/x25_dev.c
@@ -17,6 +17,9 @@
  *      2000-09-04	Henner Eisen	Prevent freeing a dangling skb.
  */
 
+#define pr_fmt(fmt) "X25: " fmt
+#define DEBUG
+
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
@@ -89,7 +92,7 @@ static int x25_receive_data(struct sk_buff *skb, struct x25_neigh *nb)
 */
 
 	if (frametype != X25_CLEAR_CONFIRMATION)
-		printk(KERN_DEBUG "x25_receive_data(): unknown frame type %2x\n",frametype);
+		pr_debug("x25_receive_data(): unknown frame type %2x\n",frametype);
 
 	return 0;
 }
@@ -114,7 +117,7 @@ int x25_lapb_receive_frame(struct sk_buff *skb, struct net_device *dev,
 	 */
 	nb = x25_get_neigh(dev);
 	if (!nb) {
-		printk(KERN_DEBUG "X.25: unknown neighbour - %s\n", dev->name);
+		pr_debug("unknown neighbour - %s\n", dev->name);
 		goto drop;
 	}
 
@@ -154,7 +157,7 @@ void x25_establish_link(struct x25_neigh *nb)
 	switch (nb->dev->type) {
 	case ARPHRD_X25:
 		if ((skb = alloc_skb(1, GFP_ATOMIC)) == NULL) {
-			printk(KERN_ERR "x25_dev: out of memory\n");
+			pr_err("x25_dev: out of memory\n");
 			return;
 		}
 		ptr  = skb_put(skb, 1);
@@ -189,7 +192,7 @@ void x25_terminate_link(struct x25_neigh *nb)
 
 	skb = alloc_skb(1, GFP_ATOMIC);
 	if (!skb) {
-		printk(KERN_ERR "x25_dev: out of memory\n");
+		pr_err("x25_dev: out of memory\n");
 		return;
 	}
 
diff --git a/net/x25/x25_facilities.c b/net/x25/x25_facilities.c
index b825325..199d291 100644
--- a/net/x25/x25_facilities.c
+++ b/net/x25/x25_facilities.c
@@ -21,6 +21,9 @@
  *					on response.
  */
 
+#define pr_fmt(fmt) "X25: " fmt
+#define DEBUG
+
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/skbuff.h>
@@ -109,7 +112,7 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 			case X25_MARKER:
 				break;
 			default:
-				printk(KERN_DEBUG "X.25: unknown facility "
+				pr_debug("unknown facility "
 				       "%02X, value %02X\n",
 				       p[0], p[1]);
 				break;
@@ -132,7 +135,7 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 				*vc_fac_mask |= X25_MASK_WINDOW_SIZE;
 				break;
 			default:
-				printk(KERN_DEBUG "X.25: unknown facility "
+				pr_debug("unknown facility "
 				       "%02X, values %02X, %02X\n",
 				       p[0], p[1], p[2]);
 				break;
@@ -143,7 +146,7 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 		case X25_FAC_CLASS_C:
 			if (len < 4)
 				return -1;
-			printk(KERN_DEBUG "X.25: unknown facility %02X, "
+			pr_debug("unknown facility %02X, "
 			       "values %02X, %02X, %02X\n",
 			       p[0], p[1], p[2], p[3]);
 			p   += 4;
@@ -172,7 +175,7 @@ int x25_parse_facilities(struct sk_buff *skb, struct x25_facilities *facilities,
 				*vc_fac_mask |= X25_MASK_CALLED_AE;
 				break;
 			default:
-				printk(KERN_DEBUG "X.25: unknown facility %02X,"
+				pr_debug("unknown facility %02X,"
 					"length %d\n", p[0], p[1]);
 				break;
 			}
@@ -341,12 +344,12 @@ void x25_limit_facilities(struct x25_facilities *facilities,
 
 	if (!nb->extended) {
 		if (facilities->winsize_in  > 7) {
-			printk(KERN_DEBUG "X.25: incoming winsize limited to 7\n");
+			pr_debug("incoming winsize limited to 7\n");
 			facilities->winsize_in = 7;
 		}
 		if (facilities->winsize_out > 7) {
 			facilities->winsize_out = 7;
-			printk( KERN_DEBUG "X.25: outgoing winsize limited to 7\n");
+			pr_debug("outgoing winsize limited to 7\n");
 		}
 	}
 }
diff --git a/net/x25/x25_forward.c b/net/x25/x25_forward.c
index c541b62..cf561f1 100644
--- a/net/x25/x25_forward.c
+++ b/net/x25/x25_forward.c
@@ -8,6 +8,9 @@
  *	History
  *	03-01-2007	Added forwarding for x.25	Andrew Hendry
  */
+
+#define pr_fmt(fmt) "X25: " fmt
+
 #include <linux/if_arp.h>
 #include <linux/init.h>
 #include <linux/slab.h>
@@ -51,7 +54,7 @@ int x25_forward_call(struct x25_address *dest_addr, struct x25_neigh *from,
 	list_for_each(entry, &x25_forward_list) {
 		x25_frwd = list_entry(entry, struct x25_forward, node);
 		if (x25_frwd->lci == lci) {
-			printk(KERN_WARNING "X.25: call request for lci which is already registered!, transmitting but not registering new pair\n");
+			pr_warn("call request for lci which is already registered!, transmitting but not registering new pair\n");
 			same_lci = 1;
 		}
 	}
diff --git a/net/x25/x25_in.c b/net/x25/x25_in.c
index a49cd4e..d1b0dc7 100644
--- a/net/x25/x25_in.c
+++ b/net/x25/x25_in.c
@@ -23,6 +23,8 @@
  *					  i-frames.
  */
 
+#define pr_fmt(fmt) "X25: " fmt
+
 #include <linux/slab.h>
 #include <linux/errno.h>
 #include <linux/kernel.h>
@@ -317,7 +319,7 @@ static int x25_state3_machine(struct sock *sk, struct sk_buff *skb, int frametyp
 			break;
 
 		default:
-			printk(KERN_WARNING "x25: unknown %02X in state 3\n", frametype);
+			pr_warn("unknown %02X in state 3\n", frametype);
 			break;
 	}
 
diff --git a/net/x25/x25_link.c b/net/x25/x25_link.c
index 4acacf3..fd5ffb2 100644
--- a/net/x25/x25_link.c
+++ b/net/x25/x25_link.c
@@ -21,6 +21,8 @@
  *	2000-09-04	Henner Eisen	  dev_hold() / dev_put() for x25_neigh.
  */
 
+#define pr_fmt(fmt) "X25: " fmt
+
 #include <linux/kernel.h>
 #include <linux/jiffies.h>
 #include <linux/timer.h>
@@ -93,13 +95,13 @@ void x25_link_control(struct sk_buff *skb, struct x25_neigh *nb,
 		if (!pskb_may_pull(skb, X25_STD_MIN_LEN + 4))
 			break;
 
-		printk(KERN_WARNING "x25: diagnostic #%d - %02X %02X %02X\n",
+		pr_warn("diagnostic #%d - %02X %02X %02X\n",
 		       skb->data[3], skb->data[4],
 		       skb->data[5], skb->data[6]);
 		break;
 
 	default:
-		printk(KERN_WARNING "x25: received unknown %02X with LCI 000\n",
+		pr_warn("received unknown %02X with LCI 000\n",
 		       frametype);
 		break;
 	}
diff --git a/net/x25/x25_subr.c b/net/x25/x25_subr.c
index 5170d52..921927d 100644
--- a/net/x25/x25_subr.c
+++ b/net/x25/x25_subr.c
@@ -23,6 +23,9 @@
  *						restriction on response.
  */
 
+#define pr_fmt(fmt) "X25: " fmt
+#define DEBUG
+
 #include <linux/slab.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
@@ -148,7 +151,7 @@ void x25_write_internal(struct sock *sk, int frametype)
 	case X25_RESET_CONFIRMATION:
 		break;
 	default:
-		printk(KERN_ERR "X.25: invalid frame type %02X\n", frametype);
+		pr_err("invalid frame type %02X\n", frametype);
 		return;
 	}
 
@@ -338,7 +341,7 @@ int x25_decode(struct sock *sk, struct sk_buff *skb, int *ns, int *nr, int *q,
 		}
 	}
 
-	printk(KERN_DEBUG "X.25: invalid PLP frame %02X %02X %02X\n",
+	pr_debug("invalid PLP frame %02X %02X %02X\n",
 	       frame[0], frame[1], frame[2]);
 
 	return X25_ILLEGAL;
-- 
1.7.12
