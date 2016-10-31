From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: set SK_MEM_QUANTUM to 4096
Date: Mon, 31 Oct 2016 11:58:40 -0700
Message-ID: <1477940320.7065.312.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36720 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945669AbcJaS6m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 14:58:42 -0400
Received: by mail-pf0-f195.google.com with SMTP id n85so9406205pfi.3
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 11:58:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Systems with large pages (64KB pages for example) do not always have
huge quantity of memory.

A big SK_MEM_QUANTUM value leads to fewer interactions with the
global counters (like tcp_memory_allocated) but might trigger
memory pressure much faster, thus suboptimal TCP performance
since windows are lowered to ridiculous values.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/sock.h |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index f13ac87a8015cb18c5d3fe5fdcf2d6a0592428f4..d3409bb514e7f08b9cf183b7405d876bec18d732 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1281,7 +1281,10 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind);
 void __sk_mem_reduce_allocated(struct sock *sk, int amount);
 void __sk_mem_reclaim(struct sock *sk, int amount);
 
-#define SK_MEM_QUANTUM ((int)PAGE_SIZE)
+/* We used to have PAGE_SIZE here, but systems with 64KB pages
+ * do not necessarily have 16x time more memory than 4KB ones.
+ */
+#define SK_MEM_QUANTUM 4096
 #define SK_MEM_QUANTUM_SHIFT ilog2(SK_MEM_QUANTUM)
 #define SK_MEM_SEND	0
 #define SK_MEM_RECV	1
