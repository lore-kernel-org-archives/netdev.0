From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v3 8/8] cgroup: Define CGROUP_SUBSYS_COUNT according the configuration
Date: Tue, 11 Sep 2012 18:26:14 +0200
Message-ID: <1347380774-9546-9-git-send-email-wagi@monom.org>
References: <1347380774-9546-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:60256 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758050Ab2IKQ01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 12:26:27 -0400
In-Reply-To: <1347380774-9546-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Since we know exactly how many subsystems exists at compile time we are
able to define CGROUP_SUBSYS_COUNT correctly. CGROUP_SUBSYS_COUNT will
be at max 12 (all controllers enabled). Depending on the architecture
we safe either 32 - 12 pointers (80 bytes) or 64 - 12 pointers (416
bytes) per cgroup.

With this change we can also remove the temporary placeholder to avoid
compilation errors.

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
 include/linux/cgroup.h | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 798c532..5bb73a5 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -48,16 +48,10 @@ extern const struct file_operations proc_cgroup_operations;
 #define IS_SUBSYS_ENABLED(option) IS_ENABLED(option)
 enum cgroup_subsys_id {
 #include <linux/cgroup_subsys.h>
-	__CGROUP_TEMPORARY_PLACEHOLDER
+	CGROUP_SUBSYS_COUNT,
 };
 #undef IS_SUBSYS_ENABLED
 #undef SUBSYS
-/*
- * This define indicates the maximum number of subsystems that can be loaded
- * at once. We limit to this many since cgroupfs_root has subsys_bits to keep
- * track of all of them.
- */
-#define CGROUP_SUBSYS_COUNT (BITS_PER_BYTE*sizeof(unsigned long))
 
 /* Per-subsystem/per-cgroup state maintained by the system. */
 struct cgroup_subsys_state {
-- 
1.7.12.315.g682ce8b
