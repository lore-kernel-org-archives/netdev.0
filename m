From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] net_sched: expand control flow of macro SKIP_NONLOCAL
Date: Wed, 11 Dec 2013 15:17:11 +0800
Message-ID: <52A81177.6000100@huawei.com>
References: <1386680134-85452-1-git-send-email-yangyingliang@huawei.com>	<1386680134-85452-7-git-send-email-yangyingliang@huawei.com> <20131210.224900.1427512059771492387.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:16016 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750774Ab3LKHR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 02:17:26 -0500
In-Reply-To: <20131210.224900.1427512059771492387.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>

SKIP_NONLOCAL hides the control flow. The control flow should be
inlined and expanded explicitly in code so that someone who reads
it can tell the control flow can be changed by the statement.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 net/sched/em_meta.c | 157 ++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 122 insertions(+), 35 deletions(-)

diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index e5cef956..382519a 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -271,40 +271,52 @@ META_COLLECTOR(int_rtiif)
  * Socket Attributes
  **************************************************************************/
 
-#define SKIP_NONLOCAL(skb)			\
-	if (unlikely(skb->sk == NULL)) {	\
-		*err = -1;			\
-		return;				\
-	}
+#define skip_nonlocal(skb) \
+	(unlikely(skb->sk == NULL))
 
 META_COLLECTOR(int_sk_family)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_family;
 }
 
 META_COLLECTOR(int_sk_state)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_state;
 }
 
 META_COLLECTOR(int_sk_reuse)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_reuse;
 }
 
 META_COLLECTOR(int_sk_bound_if)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	/* No error if bound_dev_if is 0, legal userspace check */
 	dst->value = skb->sk->sk_bound_dev_if;
 }
 
 META_COLLECTOR(var_sk_bound_if)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 
 	if (skb->sk->sk_bound_dev_if == 0) {
 		dst->value = (unsigned long) "any";
@@ -322,151 +334,226 @@ META_COLLECTOR(var_sk_bound_if)
 
 META_COLLECTOR(int_sk_refcnt)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = atomic_read(&skb->sk->sk_refcnt);
 }
 
 META_COLLECTOR(int_sk_rcvbuf)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_rcvbuf;
 }
 
 META_COLLECTOR(int_sk_shutdown)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_shutdown;
 }
 
 META_COLLECTOR(int_sk_proto)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_protocol;
 }
 
 META_COLLECTOR(int_sk_type)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_type;
 }
 
 META_COLLECTOR(int_sk_rmem_alloc)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = sk_rmem_alloc_get(skb->sk);
 }
 
 META_COLLECTOR(int_sk_wmem_alloc)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = sk_wmem_alloc_get(skb->sk);
 }
 
 META_COLLECTOR(int_sk_omem_alloc)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = atomic_read(&skb->sk->sk_omem_alloc);
 }
 
 META_COLLECTOR(int_sk_rcv_qlen)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_receive_queue.qlen;
 }
 
 META_COLLECTOR(int_sk_snd_qlen)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_write_queue.qlen;
 }
 
 META_COLLECTOR(int_sk_wmem_queued)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_wmem_queued;
 }
 
 META_COLLECTOR(int_sk_fwd_alloc)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_forward_alloc;
 }
 
 META_COLLECTOR(int_sk_sndbuf)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_sndbuf;
 }
 
 META_COLLECTOR(int_sk_alloc)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = (__force int) skb->sk->sk_allocation;
 }
 
 META_COLLECTOR(int_sk_hash)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_hash;
 }
 
 META_COLLECTOR(int_sk_lingertime)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_lingertime / HZ;
 }
 
 META_COLLECTOR(int_sk_err_qlen)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_error_queue.qlen;
 }
 
 META_COLLECTOR(int_sk_ack_bl)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_ack_backlog;
 }
 
 META_COLLECTOR(int_sk_max_ack_bl)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_max_ack_backlog;
 }
 
 META_COLLECTOR(int_sk_prio)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_priority;
 }
 
 META_COLLECTOR(int_sk_rcvlowat)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_rcvlowat;
 }
 
 META_COLLECTOR(int_sk_rcvtimeo)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_rcvtimeo / HZ;
 }
 
 META_COLLECTOR(int_sk_sndtimeo)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_sndtimeo / HZ;
 }
 
 META_COLLECTOR(int_sk_sendmsg_off)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_frag.offset;
 }
 
 META_COLLECTOR(int_sk_write_pend)
 {
-	SKIP_NONLOCAL(skb);
+	if (skip_nonlocal(skb)) {
+		*err = -1;
+		return;
+	}
 	dst->value = skb->sk->sk_write_pending;
 }
 
-- 1.8.0
