From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v3 5/8] cgroup: Wrap subsystem selection macro
Date: Tue, 11 Sep 2012 18:26:11 +0200
Message-ID: <1347380774-9546-6-git-send-email-wagi@monom.org>
References: <1347380774-9546-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:60263 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757817Ab2IKQ00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 12:26:26 -0400
In-Reply-To: <1347380774-9546-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Before we are able to define all subsystem ids at compile time we need
a more fine grained control what gets defined when we include
cgroup_subsys.h. For example we define the enums for the subsystems or
to declare for struct cgroup_subsys (builtin subsystem) by including
cgroup_subsys.h and defining SUBSYS accordingly.

Currently, the decision if a subsys is used is defined inside the
header by testing if CONFIG_*=y is true. By moving this test outside
of cgroup_subsys.h we are able to control it on the include level.

This is done by introducing IS_SUBSYS_ENABLED which then is defined
according the task, e.g. is CONFIG_*=y or CONFIG_*=m.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: Gao feng <gaofeng@cn.fujitsu.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 include/linux/cgroup.h        |  4 ++++
 include/linux/cgroup_subsys.h | 24 ++++++++++++------------
 kernel/cgroup.c               |  1 +
 3 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 2140f91..412dcbe 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -45,10 +45,12 @@ extern const struct file_operations proc_cgroup_operations;
 
 /* Define the enumeration of all builtin cgroup subsystems */
 #define SUBSYS(_x) _x ## _subsys_id,
+#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 enum cgroup_subsys_id {
 #include <linux/cgroup_subsys.h>
 	__CGROUP_TEMPORARY_PLACEHOLDER
 };
+#undef IS_SUBSYS_ENABLED
 #undef SUBSYS
 /*
  * This define indicates the maximum number of subsystems that can be loaded
@@ -521,7 +523,9 @@ struct cgroup_subsys {
 };
 
 #define SUBSYS(_x) extern struct cgroup_subsys _x ## _subsys;
+#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 #include <linux/cgroup_subsys.h>
+#undef IS_SUBSYS_ENABLED
 #undef SUBSYS
 
 static inline struct cgroup_subsys_state *cgroup_subsys_state(
diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index dfae957..f204a7a 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -7,73 +7,73 @@
 
 /* */
 
-#ifdef CONFIG_CPUSETS
+#if IS_SUBSYS_ENABLED(CONFIG_CPUSETS)
 SUBSYS(cpuset)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_DEBUG
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEBUG)
 SUBSYS(debug)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_SCHED
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_SCHED)
 SUBSYS(cpu_cgroup)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_CPUACCT
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_CPUACCT)
 SUBSYS(cpuacct)
 #endif
 
 /* */
 
-#ifdef CONFIG_MEMCG
+#if IS_SUBSYS_ENABLED(CONFIG_MEMCG)
 SUBSYS(mem_cgroup)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_DEVICE
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_DEVICE)
 SUBSYS(devices)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_FREEZER
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_FREEZER)
 SUBSYS(freezer)
 #endif
 
 /* */
 
-#ifdef CONFIG_NET_CLS_CGROUP
+#if IS_SUBSYS_ENABLED(CONFIG_NET_CLS_CGROUP)
 SUBSYS(net_cls)
 #endif
 
 /* */
 
-#ifdef CONFIG_BLK_CGROUP
+#if IS_SUBSYS_ENABLED(CONFIG_BLK_CGROUP)
 SUBSYS(blkio)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_PERF
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_PERF)
 SUBSYS(perf)
 #endif
 
 /* */
 
-#ifdef CONFIG_NETPRIO_CGROUP
+#if IS_SUBSYS_ENABLED(CONFIG_NETPRIO_CGROUP)
 SUBSYS(net_prio)
 #endif
 
 /* */
 
-#ifdef CONFIG_CGROUP_HUGETLB
+#if IS_SUBSYS_ENABLED(CONFIG_CGROUP_HUGETLB)
 SUBSYS(hugetlb)
 #endif
 
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 40f881b..1fec640 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -93,6 +93,7 @@ static DEFINE_MUTEX(cgroup_root_mutex);
  * cgroup_mutex.
  */
 #define SUBSYS(_x) &_x ## _subsys,
+#define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 static struct cgroup_subsys *subsys[CGROUP_SUBSYS_COUNT] = {
 #include <linux/cgroup_subsys.h>
 };
-- 
1.7.12.315.g682ce8b
