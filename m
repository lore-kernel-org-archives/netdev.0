From: Zhang Zhaolong <zhangzl2013@126.com>
Subject: [PATCH] proc: proc_create() should return true if CONFIG_PROC_FS is not configured
Date: Wed, 25 Feb 2015 13:14:19 +0800
Message-ID: <1424841259-8470-1-git-send-email-zhangzl2013@126.com>
Cc: netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	dhowells@redhat.com, Zhang Zhaolong <zhangzl2013@126.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m15-114.126.com ([220.181.15.114]:53964 "EHLO m15-114.126.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703AbbBYFOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 00:14:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

proc_create() should return true if CONFIG_PROC_FS is not configured.
Otherwise if-statement like this "if (!proc_create())" would go to the false path.

Signed-off-by: Zhang Zhaolong <zhangzl2013@126.com>
---
 include/linux/proc_fs.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index b97bf2e..1fc07b9 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -60,8 +60,8 @@ static inline struct proc_dir_entry *proc_mkdir_data(const char *name,
 	umode_t mode, struct proc_dir_entry *parent, void *data) { return NULL; }
 static inline struct proc_dir_entry *proc_mkdir_mode(const char *name,
 	umode_t mode, struct proc_dir_entry *parent) { return NULL; }
-#define proc_create(name, mode, parent, proc_fops) ({NULL;})
-#define proc_create_data(name, mode, parent, proc_fops, data) ({NULL;})
+#define proc_create(name, mode, parent, proc_fops) ({ 1; })
+#define proc_create_data(name, mode, parent, proc_fops, data) ({ 1; })
 
 static inline void proc_set_size(struct proc_dir_entry *de, loff_t size) {}
 static inline void proc_set_user(struct proc_dir_entry *de, kuid_t uid, kgid_t gid) {}
-- 
1.9.1
