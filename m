From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make get_proc_net() static
Date: Tue, 22 Jul 2008 20:20:33 +0300
Message-ID: <20080722172033.GQ14846@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5.pp.htv.fi ([213.243.153.39]:34764 "EHLO smtp5.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754709AbYGVRUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2008 13:20:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

get_proc_net() can now become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 fs/proc/proc_net.c      |   11 +++++------
 include/linux/proc_fs.h |    2 --
 2 files changed, 5 insertions(+), 8 deletions(-)

48b48347bed28ecad3c612d2fdffbde73dc98584 
diff --git a/fs/proc/proc_net.c b/fs/proc/proc_net.c
index b224a28..7bc296f 100644
--- a/fs/proc/proc_net.c
+++ b/fs/proc/proc_net.c
@@ -27,6 +27,11 @@
 #include "internal.h"
 
 
+static struct net *get_proc_net(const struct inode *inode)
+{
+	return maybe_get_net(PDE_NET(PDE(inode)));
+}
+
 int seq_open_net(struct inode *ino, struct file *f,
 		 const struct seq_operations *ops, int size)
 {
@@ -185,12 +190,6 @@ void proc_net_remove(struct net *net, const char *name)
 }
 EXPORT_SYMBOL_GPL(proc_net_remove);
 
-struct net *get_proc_net(const struct inode *inode)
-{
-	return maybe_get_net(PDE_NET(PDE(inode)));
-}
-EXPORT_SYMBOL_GPL(get_proc_net);
-
 static __net_init int proc_net_ns_init(struct net *net)
 {
 	struct proc_dir_entry *netd, *net_statd;
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index fff1d27..15a9eaf 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -305,8 +305,6 @@ static inline struct net *PDE_NET(struct proc_dir_entry *pde)
 	return pde->parent->data;
 }
 
-struct net *get_proc_net(const struct inode *inode);
-
 struct proc_maps_private {
 	struct pid *pid;
 	struct task_struct *task;

