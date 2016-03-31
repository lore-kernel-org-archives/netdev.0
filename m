From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 5/6] net: export napi_by_id()
Date: Thu, 31 Mar 2016 13:50:38 +0800
Message-ID: <1459403439-6011-6-git-send-email-jasowang@redhat.com>
References: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50898 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752442AbcCaFvA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2016 01:51:00 -0400
In-Reply-To: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exports napi_by_id() which will be used by vhost_net socket
busy polling.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/net/busy_poll.h | 1 +
 net/core/dev.c          | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index e765e23..dc9c76d 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -74,6 +74,7 @@ static inline bool busy_loop_timeout(unsigned long end_time)
 
 bool sk_busy_loop(struct sock *sk, int nonblock);
 int sk_busy_loop_once(struct sock *sk, struct napi_struct *napi);
+struct napi_struct *napi_by_id(unsigned int napi_id);
 
 /* used in the NIC receive handler to mark the skb */
 static inline void skb_mark_napi_id(struct sk_buff *skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index a2f0c46..b98d210 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4888,7 +4888,7 @@ void napi_complete_done(struct napi_struct *n, int work_done)
 EXPORT_SYMBOL(napi_complete_done);
 
 /* must be called under rcu_read_lock(), as we dont take a reference */
-static struct napi_struct *napi_by_id(unsigned int napi_id)
+struct napi_struct *napi_by_id(unsigned int napi_id)
 {
 	unsigned int hash = napi_id % HASH_SIZE(napi_hash);
 	struct napi_struct *napi;
@@ -4899,6 +4899,7 @@ static struct napi_struct *napi_by_id(unsigned int napi_id)
 
 	return NULL;
 }
+EXPORT_SYMBOL(napi_by_id);
 
 #if defined(CONFIG_NET_RX_BUSY_POLL)
 #define BUSY_POLL_BUDGET 8
-- 
2.5.0
