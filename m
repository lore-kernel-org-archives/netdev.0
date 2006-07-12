From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Subject: [PATCH 1/1] net: fix __sk_stream_mem_reclaim
Date: Thu, 13 Jul 2006 11:23:28 +1200
Message-ID: <5640c7e00607121623i34133297n6894878afd74f27e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-f131.google.com ([64.233.182.131]:55263 "EHLO
	nf-out-f131.google.com") by vger.kernel.org with ESMTP
	id S1751427AbWGLXXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 19:23:31 -0400
Received: by nf-out-f131.google.com with SMTP id k65so4545nfa
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2006 16:23:30 -0700 (PDT)
To: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

__sk_stream_mem_reclaim is only called by sk_stream_mem_reclaim.

As such the check on sk->sk_forward_alloc is not needed and can be removed.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/core/stream.c b/net/core/stream.c
index e948969..d1d7dec 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -196,15 +196,13 @@ EXPORT_SYMBOL(sk_stream_error);

 void __sk_stream_mem_reclaim(struct sock *sk)
 {
-	if (sk->sk_forward_alloc >= SK_STREAM_MEM_QUANTUM) {
-		atomic_sub(sk->sk_forward_alloc / SK_STREAM_MEM_QUANTUM,
-			   sk->sk_prot->memory_allocated);
-		sk->sk_forward_alloc &= SK_STREAM_MEM_QUANTUM - 1;
-		if (*sk->sk_prot->memory_pressure &&
-		    (atomic_read(sk->sk_prot->memory_allocated) <
-		     sk->sk_prot->sysctl_mem[0]))
-			*sk->sk_prot->memory_pressure = 0;
-	}
+	atomic_sub(sk->sk_forward_alloc / SK_STREAM_MEM_QUANTUM,
+		   sk->sk_prot->memory_allocated);
+	sk->sk_forward_alloc &= SK_STREAM_MEM_QUANTUM - 1;
+	if (*sk->sk_prot->memory_pressure &&
+	    (atomic_read(sk->sk_prot->memory_allocated) <
+	     sk->sk_prot->sysctl_mem[0]))
+		*sk->sk_prot->memory_pressure = 0;
 }

 EXPORT_SYMBOL(__sk_stream_mem_reclaim);
