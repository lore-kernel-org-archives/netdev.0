From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] pktgen: Use pr_debug
Date: Wed, 16 May 2012 20:50:41 -0700
Message-ID: <1337226641.17726.8.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert printk(KERN_DEBUG to pr_debug which can
enable dynamic debugging.

Remove embedded prefixes from the conversions as
pr_fmt adds them.

Align arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/pktgen.c |   41 ++++++++++++++++++-----------------------
 1 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 3391257..d22509b 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -891,8 +891,8 @@ static ssize_t pktgen_if_write(struct file *file,
 		if (copy_from_user(tb, user_buffer, copy))
 			return -EFAULT;
 		tb[copy] = 0;
-		printk(KERN_DEBUG "pktgen: %s,%lu  buffer -:%s:-\n", name,
-		       (unsigned long)count, tb);
+		pr_debug("%s,%lu  buffer -:%s:-\n",
+			 name, (unsigned long)count, tb);
 	}
 
 	if (!strcmp(name, "min_pkt_size")) {
@@ -1261,8 +1261,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->cur_daddr = pkt_dev->daddr_min;
 		}
 		if (debug)
-			printk(KERN_DEBUG "pktgen: dst_min set to: %s\n",
-			       pkt_dev->dst_min);
+			pr_debug("dst_min set to: %s\n", pkt_dev->dst_min);
 		i += len;
 		sprintf(pg_result, "OK: dst_min=%s", pkt_dev->dst_min);
 		return count;
@@ -1284,8 +1283,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->cur_daddr = pkt_dev->daddr_max;
 		}
 		if (debug)
-			printk(KERN_DEBUG "pktgen: dst_max set to: %s\n",
-			       pkt_dev->dst_max);
+			pr_debug("dst_max set to: %s\n", pkt_dev->dst_max);
 		i += len;
 		sprintf(pg_result, "OK: dst_max=%s", pkt_dev->dst_max);
 		return count;
@@ -1307,7 +1305,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		pkt_dev->cur_in6_daddr = pkt_dev->in6_daddr;
 
 		if (debug)
-			printk(KERN_DEBUG "pktgen: dst6 set to: %s\n", buf);
+			pr_debug("dst6 set to: %s\n", buf);
 
 		i += len;
 		sprintf(pg_result, "OK: dst6=%s", buf);
@@ -1329,7 +1327,7 @@ static ssize_t pktgen_if_write(struct file *file,
 
 		pkt_dev->cur_in6_daddr = pkt_dev->min_in6_daddr;
 		if (debug)
-			printk(KERN_DEBUG "pktgen: dst6_min set to: %s\n", buf);
+			pr_debug("dst6_min set to: %s\n", buf);
 
 		i += len;
 		sprintf(pg_result, "OK: dst6_min=%s", buf);
@@ -1350,7 +1348,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		snprintf(buf, sizeof(buf), "%pI6c", &pkt_dev->max_in6_daddr);
 
 		if (debug)
-			printk(KERN_DEBUG "pktgen: dst6_max set to: %s\n", buf);
+			pr_debug("dst6_max set to: %s\n", buf);
 
 		i += len;
 		sprintf(pg_result, "OK: dst6_max=%s", buf);
@@ -1373,7 +1371,7 @@ static ssize_t pktgen_if_write(struct file *file,
 		pkt_dev->cur_in6_saddr = pkt_dev->in6_saddr;
 
 		if (debug)
-			printk(KERN_DEBUG "pktgen: src6 set to: %s\n", buf);
+			pr_debug("src6 set to: %s\n", buf);
 
 		i += len;
 		sprintf(pg_result, "OK: src6=%s", buf);
@@ -1394,8 +1392,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->cur_saddr = pkt_dev->saddr_min;
 		}
 		if (debug)
-			printk(KERN_DEBUG "pktgen: src_min set to: %s\n",
-			       pkt_dev->src_min);
+			pr_debug("src_min set to: %s\n", pkt_dev->src_min);
 		i += len;
 		sprintf(pg_result, "OK: src_min=%s", pkt_dev->src_min);
 		return count;
@@ -1415,8 +1412,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->cur_saddr = pkt_dev->saddr_max;
 		}
 		if (debug)
-			printk(KERN_DEBUG "pktgen: src_max set to: %s\n",
-			       pkt_dev->src_max);
+			pr_debug("src_max set to: %s\n", pkt_dev->src_max);
 		i += len;
 		sprintf(pg_result, "OK: src_max=%s", pkt_dev->src_max);
 		return count;
@@ -1527,7 +1523,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->svlan_id = 0xffff;
 
 			if (debug)
-				printk(KERN_DEBUG "pktgen: VLAN/SVLAN auto turned off\n");
+				pr_debug("VLAN/SVLAN auto turned off\n");
 		}
 		return count;
 	}
@@ -1542,10 +1538,10 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->vlan_id = value;  /* turn on VLAN */
 
 			if (debug)
-				printk(KERN_DEBUG "pktgen: VLAN turned on\n");
+				pr_debug("VLAN turned on\n");
 
 			if (debug && pkt_dev->nr_labels)
-				printk(KERN_DEBUG "pktgen: MPLS auto turned off\n");
+				pr_debug("MPLS auto turned off\n");
 
 			pkt_dev->nr_labels = 0;    /* turn off MPLS */
 			sprintf(pg_result, "OK: vlan_id=%u", pkt_dev->vlan_id);
@@ -1554,7 +1550,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->svlan_id = 0xffff;
 
 			if (debug)
-				printk(KERN_DEBUG "pktgen: VLAN/SVLAN turned off\n");
+				pr_debug("VLAN/SVLAN turned off\n");
 		}
 		return count;
 	}
@@ -1599,10 +1595,10 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->svlan_id = value;  /* turn on SVLAN */
 
 			if (debug)
-				printk(KERN_DEBUG "pktgen: SVLAN turned on\n");
+				pr_debug("SVLAN turned on\n");
 
 			if (debug && pkt_dev->nr_labels)
-				printk(KERN_DEBUG "pktgen: MPLS auto turned off\n");
+				pr_debug("MPLS auto turned off\n");
 
 			pkt_dev->nr_labels = 0;    /* turn off MPLS */
 			sprintf(pg_result, "OK: svlan_id=%u", pkt_dev->svlan_id);
@@ -1611,7 +1607,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			pkt_dev->svlan_id = 0xffff;
 
 			if (debug)
-				printk(KERN_DEBUG "pktgen: VLAN/SVLAN turned off\n");
+				pr_debug("VLAN/SVLAN turned off\n");
 		}
 		return count;
 	}
@@ -1779,8 +1775,7 @@ static ssize_t pktgen_thread_write(struct file *file,
 	i += len;
 
 	if (debug)
-		printk(KERN_DEBUG "pktgen: t=%s, count=%lu\n",
-		       name, (unsigned long)count);
+		pr_debug("t=%s, count=%lu\n", name, (unsigned long)count);
 
 	if (!t) {
 		pr_err("ERROR: No thread\n");
