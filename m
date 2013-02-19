From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 1/3] net: proc: fix build failed when procfs is not configured
Date: Tue, 19 Feb 2013 18:43:10 +0800
Message-ID: <1361270592-19492-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: davem@davemloft.net, Gao feng <gaofeng@cn.fujitsu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:10602 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750791Ab3BSKmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2013 05:42:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d4beaa66add8aebf83ab16d2fde4e4de8dac36df
"net: proc: change proc_net_fops_create to proc_create"
uses proc_create to replace proc_net_fops_create, when
CONFIG_PROC isn't configured, some build error will
occurs.

net/packet/af_packet.c: In function 'packet_net_init':
net/packet/af_packet.c:3831:48: error: 'packet_seq_fops' undeclared (first use in this function)
net/packet/af_packet.c:3831:48: note: each undeclared identifier is reported only once for each function it appears in

There may be other build fails like above,this patch
change proc_create from function to macros when CONFIG_PROC
is not configured,just like what proc_net_fops_create did
before this commit.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 include/linux/proc_fs.h | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index 319f694..d0a1f2c 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -187,12 +187,9 @@ static inline void proc_flush_task(struct task_struct *task)
 
 static inline struct proc_dir_entry *create_proc_entry(const char *name,
 	umode_t mode, struct proc_dir_entry *parent) { return NULL; }
-static inline struct proc_dir_entry *proc_create(const char *name,
-	umode_t mode, struct proc_dir_entry *parent,
-	const struct file_operations *proc_fops)
-{
-	return NULL;
-}
+
+#define proc_create(name, mode, parent, fops)  ({ (void)(mode), NULL; })
+
 static inline struct proc_dir_entry *proc_create_data(const char *name,
 	umode_t mode, struct proc_dir_entry *parent,
 	const struct file_operations *proc_fops, void *data)
-- 
1.7.11.7
