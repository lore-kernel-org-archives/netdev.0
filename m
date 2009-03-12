From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH] cls_cgroup: remove unneeded cgroup_lock
Date: Thu, 12 Mar 2009 09:47:30 +0800
Message-ID: <49B869B2.1020303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Paul Menage <menage@google.com>, Thomas Graf <tgraf@suug.ch>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Containers <containers@lists.linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:58559 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752992AbZCLBrc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 21:47:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can remove this lock here, since we are in cgroup write handler
and thus the cgrp is guaranteed to be valid, and no lock is needed
when writing a u32 variable.

Signed-off-by: Li Zefan <lizf@cn.fujitsuc.com>
---
 net/sched/cls_cgroup.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 91a3db4..1ab4542 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -62,13 +62,7 @@ static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
 
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
 
-- 
1.5.4.rc3

