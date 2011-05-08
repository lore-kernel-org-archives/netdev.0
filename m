From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [v2 055/115] sysctl: call sysctl_init before the first sysctl registration
Date: Mon,  9 May 2011 00:39:07 +0200
Message-ID: <1304894407-32201-56-git-send-email-lucian.grijincu@gmail.com>
References: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304894407-32201-1-git-send-email-lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the next patch key_init() will be changed to register a sysctl
table. In preparation, we call sysctl_init() before it.

Also, rename net/sysctl_net.c's sysctl_init so the two don't clash.

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/sysctl.h |    2 ++
 init/main.c            |    1 +
 kernel/sysctl.c        |    4 +---
 net/sysctl_net.c       |    4 ++--
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 470e06a..095df3a 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -943,6 +943,8 @@ struct ctl_table_set {
 	int (*is_seen)(struct ctl_table_set *);
 };
 
+extern __init int sysctl_init(void);
+
 extern void setup_sysctl_set(struct ctl_table_set *p,
 	struct ctl_table_set *parent,
 	int (*is_seen)(struct ctl_table_set *));
diff --git a/init/main.c b/init/main.c
index 4a9479e..d52a89a 100644
--- a/init/main.c
+++ b/init/main.c
@@ -599,6 +599,7 @@ asmlinkage void __init start_kernel(void)
 	fork_init(totalram_pages);
 	proc_caches_init();
 	buffer_init();
+	sysctl_init();
 	key_init();
 	security_init();
 	dbg_late_init();
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index b813724..6167daa 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1716,7 +1716,7 @@ static void sysctl_set_parent(struct ctl_table *parent, struct ctl_table *table)
 	}
 }
 
-static __init int sysctl_init(void)
+__init int sysctl_init(void)
 {
 	sysctl_set_parent(NULL, root_table);
 #ifdef CONFIG_SYSCTL_SYSCALL_CHECK
@@ -1725,8 +1725,6 @@ static __init int sysctl_init(void)
 	return 0;
 }
 
-core_initcall(sysctl_init);
-
 static struct ctl_table *is_branch_in(struct ctl_table *branch,
 				      struct ctl_table *table)
 {
diff --git a/net/sysctl_net.c b/net/sysctl_net.c
index ca84212..1197d9c 100644
--- a/net/sysctl_net.c
+++ b/net/sysctl_net.c
@@ -89,7 +89,7 @@ static struct pernet_operations sysctl_pernet_ops = {
 	.exit = sysctl_net_exit,
 };
 
-static __init int sysctl_init(void)
+static __init int net_sysctl_init(void)
 {
 	int ret;
 	ret = register_pernet_subsys(&sysctl_pernet_ops);
@@ -101,7 +101,7 @@ static __init int sysctl_init(void)
 out:
 	return ret;
 }
-subsys_initcall(sysctl_init);
+subsys_initcall(net_sysctl_init);
 
 struct ctl_table_header *register_net_sysctl_table(struct net *net,
 	const struct ctl_path *path, struct ctl_table *table)
-- 
1.7.5.134.g1c08b
