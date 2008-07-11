From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next? 1/1] netlabel: return msg overflow error from netlbl_cipsov4_list faster
Date: Fri, 11 Jul 2008 14:45:49 +0400
Message-ID: <1215773149-27728-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, paul.moore@hp.com,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:46357 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752752AbYGKKpR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 06:45:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, we are trying to place the information from the kernel to
1, 2, 3 and 4 pages sequentially. These pages are allocated via slab.
Though, from the slab point of view steps 3 and 4 are equivalent on
most architectures. So, lets skip 3 pages attempt.

By the way, should we switch from .doit to .dumpit interface here?
The amount of data seems quite big for me.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/netlabel/netlabel_cipso_v4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netlabel/netlabel_cipso_v4.c b/net/netlabel/netlabel_cipso_v4.c
--- a/net/netlabel/netlabel_cipso_v4.c
+++ b/net/netlabel/netlabel_cipso_v4.c
@@ -591,7 +591,7 @@ list_retry:
 	if (nlsze_mult < 4) {
 		rcu_read_unlock();
 		kfree_skb(ans_skb);
-		nlsze_mult++;
+		nlsze_mult *= 2;
 		goto list_start;
 	}
 list_failure_lock:
-- 
1.5.3.rc5

