From: Daniel Wagner <wagi@monom.org>
Subject: [PATCH v2 1/5] cgroup: Only update sk_cgrp_prioidx on change
Date: Wed, 11 Jul 2012 11:35:37 +0200
Message-ID: <1341999341-1808-2-git-send-email-wagi@monom.org>
References: <1341999341-1808-1-git-send-email-wagi@monom.org>
Cc: netdev@vger.kernel.org, Daniel Wagner <daniel.wagner@bmw-carit.de>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: cgroups@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hotel311.server4you.de ([85.25.146.15]:58341 "EHLO
	hotel311.server4you.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753940Ab2GKJfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 05:35:43 -0400
In-Reply-To: <1341999341-1808-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Wagner <daniel.wagner@bmw-carit.de>

Do not make the cache line dirty when nothing has changed.
sock_update_classid() does exactly the same thing.

Signed-off-by: Daniel Wagner <daniel.wagner@bmw-carit.de>
Acked-by: Neil Horman <nhorman@tuxdriver.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
---
 net/core/sock.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index 929bdcc..bbab10d 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1182,10 +1182,14 @@ EXPORT_SYMBOL(sock_update_classid);
 
 void sock_update_netprioidx(struct sock *sk)
 {
+	u32 prioidx;
+
 	if (in_interrupt())
 		return;
 
-	sk->sk_cgrp_prioidx = task_netprioidx(current);
+	prioidx = task_netprioidx(current);
+	if (prioidx != sk->sk_cgrp_prioidx)
+		sk->sk_cgrp_prioidx = prioidx;
 }
 EXPORT_SYMBOL_GPL(sock_update_netprioidx);
 #endif
-- 
1.7.11.1.165.g299666c
