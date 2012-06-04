From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sock_diag: add SK_MEMINFO_BACKLOG
Date: Mon, 04 Jun 2012 15:50:35 +0200
Message-ID: <1338817835.2760.1815.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:58470 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752641Ab2FDNuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 09:50:40 -0400
Received: by eaak11 with SMTP id k11so1172886eaa.19
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 06:50:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Adding socket backlog len in INET_DIAG_SKMEMINFO is really useful to
diagnose various TCP problems.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/sock_diag.h |    1 +
 net/core/sock_diag.c      |    1 +
 2 files changed, 2 insertions(+)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index db4bae7..6793fac 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -18,6 +18,7 @@ enum {
 	SK_MEMINFO_FWD_ALLOC,
 	SK_MEMINFO_WMEM_QUEUED,
 	SK_MEMINFO_OPTMEM,
+	SK_MEMINFO_BACKLOG,
 
 	SK_MEMINFO_VARS,
 };
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index 5fd1467..0d934ce 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -46,6 +46,7 @@ int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attrtype)
 	mem[SK_MEMINFO_FWD_ALLOC] = sk->sk_forward_alloc;
 	mem[SK_MEMINFO_WMEM_QUEUED] = sk->sk_wmem_queued;
 	mem[SK_MEMINFO_OPTMEM] = atomic_read(&sk->sk_omem_alloc);
+	mem[SK_MEMINFO_BACKLOG] = sk->sk_backlog.len;
 
 	return 0;
 
