From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 3/8] inet: add ireq_state field to inet_request_sock
Date: Thu, 12 Mar 2015 16:44:05 -0700
Message-ID: <1426203850-11034-4-git-send-email-edumazet@google.com>
References: <1426203850-11034-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f74.google.com ([209.85.218.74]:34769 "EHLO
	mail-oi0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753415AbbCLXoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 19:44:46 -0400
Received: by oifu20 with SMTP id u20so5530363oif.1
        for <netdev@vger.kernel.org>; Thu, 12 Mar 2015 16:44:46 -0700 (PDT)
In-Reply-To: <1426203850-11034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to identify request sock when they'll be visible in
global ehash table.

ireq_state is an alias to req.__req_common.skc_state.

Its value is set to TCP_NEW_SYN_RECV

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/inet_sock.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 30f7170abbf3..b31f01de5cd6 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -27,6 +27,7 @@
 #include <net/sock.h>
 #include <net/request_sock.h>
 #include <net/netns/hash.h>
+#include <net/tcp_states.h>
 
 /** struct ip_options - IP Options
  *
@@ -79,6 +80,7 @@ struct inet_request_sock {
 #define ir_iif			req.__req_common.skc_bound_dev_if
 #define ir_cookie		req.__req_common.skc_cookie
 #define ireq_net		req.__req_common.skc_net
+#define ireq_state		req.__req_common.skc_state
 
 	kmemcheck_bitfield_begin(flags);
 	u16			snd_wscale : 4,
@@ -250,6 +252,7 @@ static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops
 		kmemcheck_annotate_bitfield(ireq, flags);
 		ireq->opt = NULL;
 		atomic64_set(&ireq->ir_cookie, 0);
+		ireq->ireq_state = TCP_NEW_SYN_RECV;
 	}
 
 	return req;
-- 
2.2.0.rc0.207.ga3a616c
