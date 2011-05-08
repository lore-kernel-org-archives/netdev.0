From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 049/115] sysctl: delete unused register_sysctl_table function
Date: Mon,  9 May 2011 00:39:01 +0200
Message-ID: <1304894407-32201-50-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40833 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932441Ab1EHWlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:41:25 -0400
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/sysctl.h |    3 +--
 kernel/sysctl.c        |   26 ++------------------------
 2 files changed, 3 insertions(+), 26 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 11684d9..470e06a 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -985,7 +985,7 @@ extern int proc_do_large_bitmap(struct ctl_table *, int,
 				void __user *, size_t *, loff_t *);
 
 /*
- * Register a set of sysctl names by calling register_sysctl_table
+ * Register a set of sysctl names by calling __register_sysctl_paths
  * with an initialised array of struct ctl_table's.  An entry with 
  * NULL procname terminates the table.  table->de will be
  * set up by the registration and need not be initialised in advance.
@@ -1065,7 +1065,6 @@ void register_sysctl_root(struct ctl_table_root *root);
 struct ctl_table_header *__register_sysctl_paths(
 	struct ctl_table_root *root, struct nsproxy *namespaces,
 	const struct ctl_path *path, struct ctl_table *table);
-struct ctl_table_header *register_sysctl_table(struct ctl_table * table);
 struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						struct ctl_table *table);
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c0bb324..b813724 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1905,7 +1905,7 @@ struct ctl_table_header *__register_sysctl_paths(
 }
 
 /**
- * register_sysctl_table_path - register a sysctl table hierarchy
+ * register_sysctl_paths - register a sysctl table hierarchy
  * @path: The path to the directory the sysctl table is in.
  * @table: the top-level table structure
  *
@@ -1922,24 +1922,8 @@ struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 }
 
 /**
- * register_sysctl_table - register a sysctl table hierarchy
- * @table: the top-level table structure
- *
- * Register a sysctl table hierarchy. @table should be a filled in ctl_table
- * array. A completely 0 filled entry terminates the table.
- *
- * See register_sysctl_paths for more details.
- */
-struct ctl_table_header *register_sysctl_table(struct ctl_table *table)
-{
-	static const struct ctl_path null_path[] = { {} };
-
-	return register_sysctl_paths(null_path, table);
-}
-
-/**
  * unregister_sysctl_table - unregister a sysctl table hierarchy
- * @header: the header returned from register_sysctl_table
+ * @header: the header returned from __register_sysctl_paths
  *
  * Unregisters the sysctl table and all children. proc entries may not
  * actually be removed until they are no longer used by anyone.
@@ -1987,11 +1971,6 @@ void setup_sysctl_set(struct ctl_table_set *p,
 }
 
 #else /* !CONFIG_SYSCTL */
-struct ctl_table_header *register_sysctl_table(struct ctl_table * table)
-{
-	return NULL;
-}
-
 struct ctl_table_header *register_sysctl_paths(const struct ctl_path *path,
 						    struct ctl_table *table)
 {
@@ -2977,6 +2956,5 @@ EXPORT_SYMBOL(proc_dointvec_ms_jiffies);
 EXPORT_SYMBOL(proc_dostring);
 EXPORT_SYMBOL(proc_doulongvec_minmax);
 EXPORT_SYMBOL(proc_doulongvec_ms_jiffies_minmax);
-EXPORT_SYMBOL(register_sysctl_table);
 EXPORT_SYMBOL(register_sysctl_paths);
 EXPORT_SYMBOL(unregister_sysctl_table);
-- 
1.7.5.134.g1c08b

