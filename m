From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 5/5] sock_diag: notify when filter change
Date: Wed, 24 Apr 2013 17:52:36 +0200
Message-ID: <1366818756-4234-6-git-send-email-nicolas.dichtel@6wind.com>
References: <51779426.7020800@6wind.com>
 <1366818756-4234-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:54889 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932074Ab3DXPxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 11:53:17 -0400
In-Reply-To: <1366818756-4234-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Filter is advertised in packet diag messages, hence we may update the status
when a filter is updated.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/filter.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index dad2a17..021048a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -40,6 +40,7 @@
 #include <linux/ratelimit.h>
 #include <linux/seccomp.h>
 #include <linux/if_vlan.h>
+#include <linux/sock_diag.h>
 
 /* No hurry in this branch
  *
@@ -755,6 +756,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 
 	if (old_fp)
 		sk_filter_uncharge(sk, old_fp);
+	sock_diag_notify(sk);
 	return 0;
 }
 EXPORT_SYMBOL_GPL(sk_attach_filter);
@@ -773,6 +775,7 @@ int sk_detach_filter(struct sock *sk)
 		RCU_INIT_POINTER(sk->sk_filter, NULL);
 		sk_filter_uncharge(sk, filter);
 		ret = 0;
+		sock_diag_notify(sk);
 	}
 	return ret;
 }
-- 
1.8.2.1
