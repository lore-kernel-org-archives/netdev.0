From: akpm@linux-foundation.org
Subject: [patch 1/2] cls_cgroup: remove unneeded cgroup_lock
Date: Tue, 12 May 2009 13:47:33 -0700
Message-ID: <200905122106.n4CL6ndX009858@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	lizf@cn.fujitsu.com, lizf@cn.fujitsuc.com, menage@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51201 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753004AbZELVK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 17:10:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Zefan <lizf@cn.fujitsu.com>

We can remove this lock here, since we are in cgroup write handler and
thus the cgrp is guaranteed to be valid, and no lock is needed when
writing a u32 variable.

Signed-off-by: Li Zefan <lizf@cn.fujitsuc.com>
Acked-by: Paul Menage <menage@google.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sched/cls_cgroup.c |    6 ------
 1 file changed, 6 deletions(-)

diff -puN net/sched/cls_cgroup.c~cls_cgroup-remove-unneeded-cgroup_lock net/sched/cls_cgroup.c
--- a/net/sched/cls_cgroup.c~cls_cgroup-remove-unneeded-cgroup_lock
+++ a/net/sched/cls_cgroup.c
@@ -62,13 +62,7 @@ static u64 read_classid(struct cgroup *c
 
 static int write_classid(struct cgroup *cgrp, struct cftype *cft, u64 value)
 {
-	if (!cgroup_lock_live_group(cgrp))
-		return -ENODEV;
-
 	cgrp_cls_state(cgrp)->classid = (u32) value;
-
-	cgroup_unlock();
-
 	return 0;
 }
 
_
