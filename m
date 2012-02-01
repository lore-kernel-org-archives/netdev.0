From: Li Zefan <lizf@cn.fujitsu.com>
Subject: [PATCH 6/6] cls_cgroup: remove redundant rcu_read_lock/unlock
Date: Wed, 01 Feb 2012 14:56:42 +0800
Message-ID: <4F28E22A.703@cn.fujitsu.com>
References: <4F28E1D1.900@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Cgroups <cgroups@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60543 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755144Ab2BAGx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Feb 2012 01:53:57 -0500
In-Reply-To: <4F28E1D1.900@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've already used rcu_read_lock/unlock inside task_classid(),
so don't use the lock/unlock pair twice in this hot path.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 net/core/sock.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 213c856..c0bab23 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1160,9 +1160,7 @@ void sock_update_classid(struct sock *sk)
 {
 	u32 classid;
 
-	rcu_read_lock();  /* doing current task, which cannot vanish. */
 	classid = task_cls_classid(current);
-	rcu_read_unlock();
 	if (classid && classid != sk->sk_classid)
 		sk->sk_classid = classid;
 }
-- 
1.7.3.1
