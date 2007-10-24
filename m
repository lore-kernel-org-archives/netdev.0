From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] warning fixes
Date: Tue, 23 Oct 2007 21:31:25 -0400
Message-ID: <20071024013125.GA17042@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755973AbXJXBbj@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The cgroup change was ack'd by the maintainer.  The drivers/net/ were of
course self-ack'd.

Please pull from 'warnings' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/misc-2.6.git warnings

to receive the following updates:

 drivers/net/eexpress.c |    2 +-
 drivers/net/ni5010.c   |    2 --
 kernel/cgroup.c        |    1 -
 3 files changed, 1 insertions(+), 4 deletions(-)

Jeff Garzik (3):
      cgroup: kill unused variable
      eexpress: fix !SMP unused-var warning
      ni5010: kill unused variable

diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 9c85e50..70509ed 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -651,9 +651,9 @@ static void eexp_timeout(struct net_device *dev)
  */
 static int eexp_xmit(struct sk_buff *buf, struct net_device *dev)
 {
-	struct net_local *lp = netdev_priv(dev);
 	short length = buf->len;
 #ifdef CONFIG_SMP
+	struct net_local *lp = netdev_priv(dev);
 	unsigned long flags;
 #endif
 
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 14a768f..a20005c 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -518,7 +518,6 @@ static void dump_packet(void *buf, int len)
 /* We have a good packet, get it out of the buffer. */
 static void ni5010_rx(struct net_device *dev)
 {
-	struct ni5010_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned char rcv_stat;
 	struct sk_buff *skb;
@@ -577,7 +576,6 @@ static void ni5010_rx(struct net_device *dev)
 
 	PRINTK2((KERN_DEBUG "%s: Received packet, size=%#4.4x\n",
 		dev->name, i_pkt_size));
-
 }
 
 static int process_xmt_interrupt(struct net_device *dev)
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 5987dcc..3fe21e1 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2402,7 +2402,6 @@ struct file_operations proc_cgroup_operations = {
 static int proc_cgroupstats_show(struct seq_file *m, void *v)
 {
 	int i;
-	struct cgroupfs_root *root;
 
 	seq_puts(m, "#subsys_name\thierarchy\tnum_cgroups\n");
 	mutex_lock(&cgroup_mutex);
