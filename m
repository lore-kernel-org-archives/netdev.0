From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Update get_net_ns_by_pid
Date: Thu, 27 Sep 2007 21:48:20 -0600
Message-ID: <m1k5qbfo1n.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Containers <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:49395 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753812AbXI1Dsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 23:48:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


In the -mm tree the rules for access an nsproxy have changed,
and in get_net_ns_by_pid we access the nsproxy, so update
it to follow the new rules.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 739fbad..1caba10 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -746,10 +746,10 @@ static struct net *get_net_ns_by_pid(pid_t pid)
 	rcu_read_lock();
 	tsk = find_task_by_pid(pid);
 	if (tsk) {
-		task_lock(tsk);
-		if (tsk->nsproxy)
-			net = get_net(tsk->nsproxy->net_ns);
-		task_unlock(tsk);
+		struct nsproxy *nsproxy;
+		nsproxy = task_nsproxy(tsk);
+		if (nsproxy)
+			net = get_net(nsproxy->net_ns);
 	}
 	rcu_read_unlock();
 	return net;
