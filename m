From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 08/14] dccp: constify dccp_create_openreq_child() sock argument
Date: Tue, 29 Sep 2015 07:42:46 -0700
Message-ID: <1443537772-15305-9-git-send-email-edumazet@google.com>
References: <1443537772-15305-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35229 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751685AbbI2On4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 10:43:56 -0400
Received: by pacfv12 with SMTP id fv12so8449538pac.2
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 07:43:56 -0700 (PDT)
In-Reply-To: <1443537772-15305-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

socket no longer needs to be read/write

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/dccp.h      | 2 +-
 net/dccp/minisocks.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 8ed1df2771bd..2409619b7043 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -270,7 +270,7 @@ int dccp_reqsk_init(struct request_sock *rq, struct dccp_sock const *dp,
 
 int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
 
-struct sock *dccp_create_openreq_child(struct sock *sk,
+struct sock *dccp_create_openreq_child(const struct sock *sk,
 				       const struct request_sock *req,
 				       const struct sk_buff *skb);
 
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 9bfd0dc1e6cb..d10aace43672 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -72,7 +72,7 @@ void dccp_time_wait(struct sock *sk, int state, int timeo)
 	dccp_done(sk);
 }
 
-struct sock *dccp_create_openreq_child(struct sock *sk,
+struct sock *dccp_create_openreq_child(const struct sock *sk,
 				       const struct request_sock *req,
 				       const struct sk_buff *skb)
 {
-- 
2.6.0.rc2.230.g3dd15c0
