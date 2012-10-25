From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v1 3/5] cgroup: net_cls: Remove rcu_read_lock/unlock
Date: Thu, 25 Oct 2012 16:16:57 +0200
Message-ID: <1351174619-5096-4-git-send-email-wagi@monom.org>
References: <1351174619-5096-1-git-send-email-wagi@monom.org>
Cc: Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Glauber Costa <glommer@parallels.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Tejun Heo <tj@kernel.org>
To: netdev@vger.kernel.org, cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:52639 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759687Ab2JYORG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 10:17:06 -0400
In-Reply-To: <1351174619-5096-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

As Eric pointed out:
"Hey task_cls_classid() has its own rcu protection since commit
3fb5a991916091a908d (cls_cgroup: Fix rcu lockdep warning)

So we can safely revert Paul commit (1144182a8757f2a1)
(We no longer need rcu_read_lock/unlock here)"

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: netdev@vger.kernel.org
Cc: cgroups@vger.kernel.org
---
 net/core/sock.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index c49412c..9fedbbf 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1221,9 +1221,7 @@ void sock_update_classid(struct sock *sk)
 {
 	u32 classid;
 
-	rcu_read_lock();  /* doing current task, which cannot vanish. */
 	classid = task_cls_classid(current);
-	rcu_read_unlock();
 	if (classid != sk->sk_classid)
 		sk->sk_classid = classid;
 }
-- 
1.8.0.rc0
