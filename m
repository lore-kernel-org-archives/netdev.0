From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 07/11] sock_diag: add SK_MEMINFO_DROPS
Date: Fri,  1 Apr 2016 08:52:18 -0700
Message-ID: <1459525942-30399-8-git-send-email-edumazet@google.com>
References: <1459525942-30399-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Willem de Bruijn <willemb@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:33746 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758611AbcDAPwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2016 11:52:43 -0400
Received: by mail-pa0-f41.google.com with SMTP id zm5so94041419pac.0
        for <netdev@vger.kernel.org>; Fri, 01 Apr 2016 08:52:43 -0700 (PDT)
In-Reply-To: <1459525942-30399-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reporting sk_drops to user space was available for UDP
sockets using /proc interface.

Add this to sock_diag, so that we can have the same information
available to ss users, and we'll be able to add sk_drops
indications for TCP sockets as well.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/uapi/linux/sock_diag.h | 1 +
 net/core/sock_diag.c           | 1 +
 2 files changed, 2 insertions(+)

diff --git a/include/uapi/linux/sock_diag.h b/include/uapi/linux/sock_diag.h
index bae2d80034d4..7ff505d8a47b 100644
--- a/include/uapi/linux/sock_diag.h
+++ b/include/uapi/linux/sock_diag.h
@@ -20,6 +20,7 @@ enum {
 	SK_MEMINFO_WMEM_QUEUED,
 	SK_MEMINFO_OPTMEM,
 	SK_MEMINFO_BACKLOG,
+	SK_MEMINFO_DROPS,
 
 	SK_MEMINFO_VARS,
 };
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index a996ce8c8fb2..ca9e35bbe13c 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -67,6 +67,7 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 	mem[SK_MEMINFO_WMEM_QUEUED] = sk->sk_wmem_queued;
 	mem[SK_MEMINFO_OPTMEM] = atomic_read(&sk->sk_omem_alloc);
 	mem[SK_MEMINFO_BACKLOG] = sk->sk_backlog.len;
+	mem[SK_MEMINFO_DROPS] = atomic_read(&sk->sk_drops);
 
 	return nla_put(skb, attrtype, sizeof(mem), &mem);
 }
-- 
2.8.0.rc3.226.g39d4020
