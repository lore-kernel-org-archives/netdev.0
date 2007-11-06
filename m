From: Alexey Dobriyan <adobriyan@sw.ru>
Subject: [PATCH -net 2/2] Put proc_net_create() on death row
Date: Tue, 6 Nov 2007 15:23:50 +0300
Message-ID: <20071106122350.GB6215@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757683AbXKFMYU@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

proc_net_create() stands on the way of shrinking the number of
interfaces one can use for /proc files, namely, it uses ->get_info
hook which will be converted, deprecated and deleted on its own
schedule.

Signed-off-by: Alexey Dobriyan <adobriyan@sw.ru>
---

 Documentation/feature-removal-schedule.txt |    9 +++++++++
 include/linux/proc_fs.h                    |    8 ++++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -130,6 +130,15 @@ Who:	Christoph Hellwig <hch@lst.de>
 
 ---------------------------
 
+What:	proc_net_create()
+When:	2.6.25
+Why:	proc_net_create() stands on the way of shrinking the number of
+	interfaces one can use for /proc files, namely, it uses ->get_info
+	hook which will be deleted later.
+Who:	Alexey Dobriyan <adobriyan@gmail.com>
+
+---------------------------
+
 What:	CONFIG_FORCED_INLINING
 When:	June 2006
 Why:	Config option is there to see if gcc is good enough. (in january
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -196,7 +196,7 @@ static inline struct proc_dir_entry *create_proc_info_entry(const char *name,
 	return res;
 }
 
-extern struct proc_dir_entry *proc_net_create(struct net *net,
+extern __deprecated struct proc_dir_entry *proc_net_create(struct net *net,
 	const char *name, mode_t mode, get_info_t *get_info);
 extern struct proc_dir_entry *proc_net_fops_create(struct net *net,
 	const char *name, mode_t mode, const struct file_operations *fops);
@@ -208,7 +208,11 @@ extern void proc_net_remove(struct net *net, const char *name);
 #define proc_bus NULL
 
 #define proc_net_fops_create(net, name, mode, fops)  ({ (void)(mode), NULL; })
-#define proc_net_create(net, name, mode, info)	({ (void)(mode), NULL; })
+static inline __deprecated struct proc_dir_entry *proc_net_create(
+	struct net *net, const char *name, mode_t mode, get_info_t *get_info)
+{
+	return NULL;
+}
 static inline void proc_net_remove(struct net *net, const char *name) {}
 
 static inline void proc_flush_task(struct task_struct *task)
