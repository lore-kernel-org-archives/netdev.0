From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] get rid of unused argument
Date: Tue, 19 Aug 2003 15:56:29 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030819155629.7201f947.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dev_get_idx doesn't need the first arg..

diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Tue Aug 19 15:55:00 2003
+++ b/net/core/dev.c	Tue Aug 19 15:55:00 2003
@@ -1836,8 +1836,7 @@
  *	This is invoked by the /proc filesystem handler to display a device
  *	in detail.
  */
-static __inline__ struct net_device *dev_get_idx(struct seq_file *seq,
-						 loff_t pos)
+static __inline__ struct net_device *dev_get_idx(loff_t pos)
 {
 	struct net_device *dev;
 	loff_t i;
@@ -1850,7 +1849,7 @@
 void *dev_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	read_lock(&dev_base_lock);
-	return *pos ? dev_get_idx(seq, *pos - 1) : (void *)1;
+	return *pos ? dev_get_idx(*pos - 1) : (void *)1;
 }
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
