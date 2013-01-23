From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next] net: add RCU annotation to sk_dst_cache field
Date: Wed, 23 Jan 2013 12:43:49 +0800
Message-ID: <1358916229-19004-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5931 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955Ab3AWEn7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 23:43:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

sock->sk_dst_cache is protected by RCU.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/net/sock.h b/include/net/sock.h
index 5a34e2f..c4b64c6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -337,7 +337,7 @@ struct sock {
 #endif
 	unsigned long 		sk_flags;
 	struct dst_entry	*sk_rx_dst;
-	struct dst_entry	*sk_dst_cache;
+	struct dst_entry __rcu	*sk_dst_cache;
 	spinlock_t		sk_dst_lock;
 	atomic_t		sk_wmem_alloc;
 	atomic_t		sk_omem_alloc;
