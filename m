From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] proc_net macro's for non-proc-fs case
Date: Fri, 12 Sep 2003 11:21:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030912112120.23300a99.shemminger@osdl.org>
References: <20030911154357.6b31891c.shemminger@osdl.org>
	<20030911235405.GA74116@compsoc.man.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: John Levon <levon@movementarian.org>
In-Reply-To: <20030911235405.GA74116@compsoc.man.ac.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following should work better. They have the desired properties that:
	- return value makes sense for those that might check
	- arguments fops and info don't have to be defined (ie can be #ifdef'd out)
	- generate no warnings for null effect.

diff -Nru a/include/linux/proc_fs.h b/include/linux/proc_fs.h
--- a/include/linux/proc_fs.h	Fri Sep 12 11:19:07 2003
+++ b/include/linux/proc_fs.h	Fri Sep 12 11:19:07 2003
@@ -185,9 +185,10 @@
 #else
 
 #define proc_root_driver NULL
-#define proc_net_fops_create(name,mode,fops) do {} while(0)
-static inline struct proc_dir_entry *proc_net_create(const char *name, mode_t mode, 
-	get_info_t *get_info) {return NULL;}
+#define proc_net NULL
+
+#define proc_net_fops_create(name, mode, fops)  ({ (void)(mode), NULL; })
+#define proc_net_create(name, mode, info)	({ (void)(mode), NULL; })
 static inline void proc_net_remove(const char *name) {}
 
 static inline struct dentry *proc_pid_unhash(struct task_struct *p) { return NULL; }
