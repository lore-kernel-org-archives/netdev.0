From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/3] net: constify sock_diag_check_cookie()
Date: Tue, 10 Mar 2015 07:15:52 -0700
Message-ID: <1425996954-24693-2-git-send-email-edumazet@google.com>
References: <1425996954-24693-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:33243 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752312AbbCJOQQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 10:16:16 -0400
Received: by iecrp18 with SMTP id rp18so594744iec.0
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 07:16:16 -0700 (PDT)
In-Reply-To: <1425996954-24693-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_diag_check_cookie() second parameter is constant

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/sock_diag.h | 2 +-
 net/core/sock_diag.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 46cca4c06848..b5ad7d35a636 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -19,7 +19,7 @@ void sock_diag_unregister(const struct sock_diag_handler *h);
 void sock_diag_register_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
 void sock_diag_unregister_inet_compat(int (*fn)(struct sk_buff *skb, struct nlmsghdr *nlh));
 
-int sock_diag_check_cookie(void *sk, __u32 *cookie);
+int sock_diag_check_cookie(void *sk, const __u32 *cookie);
 void sock_diag_save_cookie(void *sk, __u32 *cookie);
 
 int sock_diag_put_meminfo(struct sock *sk, struct sk_buff *skb, int attr);
diff --git a/net/core/sock_diag.c b/net/core/sock_diag.c
index ad704c757bb4..96e70ee05a8d 100644
--- a/net/core/sock_diag.c
+++ b/net/core/sock_diag.c
@@ -13,7 +13,7 @@ static const struct sock_diag_handler *sock_diag_handlers[AF_MAX];
 static int (*inet_rcv_compat)(struct sk_buff *skb, struct nlmsghdr *nlh);
 static DEFINE_MUTEX(sock_diag_table_mutex);
 
-int sock_diag_check_cookie(void *sk, __u32 *cookie)
+int sock_diag_check_cookie(void *sk, const __u32 *cookie)
 {
 	if ((cookie[0] != INET_DIAG_NOCOOKIE ||
 	     cookie[1] != INET_DIAG_NOCOOKIE) &&
-- 
2.2.0.rc0.207.ga3a616c
