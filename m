From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 1/3] cls_cgroup: fix an oops when removing a cgroup
Date: Mon, 29 Dec 2008 11:57:19 +0800
Message-ID: <49584A9F.40202@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57361 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751508AbYL2D61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Dec 2008 22:58:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When removing a cgroup, an oops was triggered immediately. The cause
is wrong kfree() in cgrp_destroy().

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/sched/cls_cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 0d68b19..31d95b1 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -46,7 +46,7 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
 
 static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
 {
-	kfree(ss);
+	kfree(net_cls_state(cgrp));
 }
 
 static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
-- 
1.5.4.rc3

