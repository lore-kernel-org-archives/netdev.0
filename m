From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v4 6/8] cgroup: Do not depend on a given order when populating the subsys array
Date: Wed, 12 Sep 2012 16:12:06 +0200
Message-ID: <1347459128-32236-7-git-send-email-wagi@monom.org>
References: <1347459128-32236-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>, Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:33132 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758853Ab2ILOMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 10:12:15 -0400
In-Reply-To: <1347459128-32236-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

The *_subsys_id will be used as index to access the subsys. Therefore
we need to care we populate the subsystem at the correct position by
using designated initialization.

With this change we are able to interleave builtin and modules in the subsys
array.

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
 kernel/cgroup.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 769600c..343ab4e 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -92,7 +92,7 @@ static DEFINE_MUTEX(cgroup_root_mutex);
  * registered after that. The mutable section of this array is protected by
  * cgroup_mutex.
  */
-#define SUBSYS(_x) &_x ## _subsys,
+#define SUBSYS(_x) [_x ## _subsys_id] = &_x ## _subsys,
 #define IS_SUBSYS_ENABLED(option) IS_BUILTIN(option)
 static struct cgroup_subsys *subsys[CGROUP_SUBSYS_COUNT] = {
 #include <linux/cgroup_subsys.h>
-- 
1.7.12.315.g682ce8b
