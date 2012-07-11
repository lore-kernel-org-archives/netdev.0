From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v2 4/5] cgroup: Make builtin vs. module build ifdefs consistent
Date: Wed, 11 Jul 2012 11:35:40 +0200
Message-ID: <1341999341-1808-5-git-send-email-wagi@monom.org>
References: <1341999341-1808-1-git-send-email-wagi@monom.org>
Cc: netdev@vger.kernel.org, Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	"David S. Miller" <davem@davemloft.net>
To: cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:58355 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756705Ab2GKJfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 05:35:46 -0400
In-Reply-To: <1341999341-1808-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

The header file is using IS_MODULE and IS_BUILTIN macros. So let's
use them in the source file too.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: "David S. Miller" <davem@davemloft.net>
---
 net/sched/cls_cgroup.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 7743ea8..4bfb8f7 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -77,7 +77,7 @@ struct cgroup_subsys net_cls_subsys = {
 	.name		= "net_cls",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
-#ifdef CONFIG_NET_CLS_CGROUP
+#if IS_BUILTIN(CONFIG_NET_CLS_CGROUP)
 	.subsys_id	= net_cls_subsys_id,
 #endif
 	.base_cftypes	= ss_files,
@@ -283,7 +283,7 @@ static int __init init_cgroup_cls(void)
 	if (ret)
 		goto out;
 
-#ifndef CONFIG_NET_CLS_CGROUP
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
 	/* We can't use rcu_assign_pointer because this is an int. */
 	smp_wmb();
 	net_cls_subsys_id = net_cls_subsys.subsys_id;
@@ -301,7 +301,7 @@ static void __exit exit_cgroup_cls(void)
 {
 	unregister_tcf_proto_ops(&cls_cgroup_ops);
 
-#ifndef CONFIG_NET_CLS_CGROUP
+#if IS_MODULE(CONFIG_NET_CLS_CGROUP)
 	net_cls_subsys_id = -1;
 	synchronize_rcu();
 #endif
-- 
1.7.11.1.165.g299666c
