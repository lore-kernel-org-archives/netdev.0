From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 2/4] ipv4: Use IS_ERR_OR_NULL().
Date: Wed, 23 Jan 2013 01:32:49 +0900
Message-ID: <50FEBF31.1000707@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:51855 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754468Ab3AVQcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 11:32:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv4/af_inet.c |    2 +-
 net/ipv4/tcp.c     |    2 +-
 net/ipv4/udp.c     |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 4fdf967..4b70539 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1333,7 +1333,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 		segs = ops->callbacks.gso_segment(skb, features);
 	rcu_read_unlock();
 
-	if (!segs || IS_ERR(segs))
+	if (IS_ERR_OR_NULL(segs))
 		goto out;
 
 	skb = segs;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2aa69c8..5227194 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3243,7 +3243,7 @@ __tcp_alloc_md5sig_pool(struct sock *sk)
 		struct crypto_hash *hash;
 
 		hash = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
-		if (!hash || IS_ERR(hash))
+		if (IS_ERR_OR_NULL(hash))
 			goto out_free;
 
 		per_cpu_ptr(pool, cpu)->md5_desc.tfm = hash;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 79c8dbe..cf6158f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -971,7 +971,7 @@ back_from_confirm:
 				  sizeof(struct udphdr), &ipc, &rt,
 				  msg->msg_flags);
 		err = PTR_ERR(skb);
-		if (skb && !IS_ERR(skb))
+		if (!IS_ERR_OR_NULL(skb))
 			err = udp_send_skb(skb, fl4);
 		goto out;
 	}
-- 
1.7.9.5
