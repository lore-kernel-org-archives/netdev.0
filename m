From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 4/7] cgroups: Mark some subsystems bindable
Date: Fri, 22 Oct 2010 16:11:08 +0800
Message-ID: <4CC1471C.9070403@cn.fujitsu.com>
References: <4CC146A4.9090505@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Paul Menage <menage@google.com>,
	Stephane Eranian <eranian@google.com>,
	LKML <linux-kernel@vger.kernel.org>,
	containers@lists.linux-foundation.org,
	David Miller <davem@davemloft.net>, serge@hallyn.com,
	netdev <netdev@vger.kernel.org>
To: "akpm >> Andrew Morton" <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4CC146A4.9090505@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For those subsystems (debug, cpuacct, net_cls and devices),
setting the can_bind flag is sufficient.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cgroup.c          |    1 +
 kernel/sched.c           |    1 +
 net/sched/cls_cgroup.c   |    1 +
 security/device_cgroup.c |    1 +
 4 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 9ce3fdb..6364bb5 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -5124,5 +5124,6 @@ struct cgroup_subsys debug_subsys = {
 	.destroy = debug_destroy,
 	.populate = debug_populate,
 	.subsys_id = debug_subsys_id,
+	.can_bind = 1,
 };
 #endif /* CONFIG_CGROUP_DEBUG */
diff --git a/kernel/sched.c b/kernel/sched.c
index 51944e8..cae104f 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -9329,6 +9329,7 @@ struct cgroup_subsys cpuacct_subsys = {
 	.destroy = cpuacct_destroy,
 	.populate = cpuacct_populate,
 	.subsys_id = cpuacct_subsys_id,
+	.can_bind = 1,
 };
 #endif	/* CONFIG_CGROUP_CPUACCT */
 
diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 37dff78..020ddfe 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -38,6 +38,7 @@ struct cgroup_subsys net_cls_subsys = {
 #define net_cls_subsys_id net_cls_subsys.subsys_id
 #endif
 	.module		= THIS_MODULE,
+	.can_bind	= 1,
 };
 
 
diff --git a/security/device_cgroup.c b/security/device_cgroup.c
index 8d9c48f..b8136fc 100644
--- a/security/device_cgroup.c
+++ b/security/device_cgroup.c
@@ -473,6 +473,7 @@ struct cgroup_subsys devices_subsys = {
 	.destroy = devcgroup_destroy,
 	.populate = devcgroup_populate,
 	.subsys_id = devices_subsys_id,
+	.can_bind = 1,
 };
 
 int devcgroup_inode_permission(struct inode *inode, int mask)
-- 
1.7.0.1
