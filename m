From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] [V2] net: diag: add missing declarations
Date: Thu,  9 Jun 2016 18:05:09 +0100
Message-ID: <1465491909-27878-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-70-136-246.dsl.in-addr.zen.co.uk ([82.70.136.246]:42942 "EHLO
	rainbowdash.ducie.codethink.co.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932365AbcFIRFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 13:05:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions inet_diag_msg_common_fill and inet_diag_msg_attrs_fill
seem to have been missed from the include/linux/inet_diag.h header
file. Add them to fix the following warnings:

net/ipv4/inet_diag.c:69:6: warning: symbol 'inet_diag_msg_common_fill' was not declared. Should it be static?
net/ipv4/inet_diag.c:108:5: warning: symbol 'inet_diag_msg_attrs_fill' was not declared. Should it be static?

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
V2: remove duplicates from net/sctp/sctp_diag.c
---
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/inet_diag.h | 6 ++++++
 net/sctp/sctp_diag.c      | 6 ------
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/inet_diag.h b/include/linux/inet_diag.h
index 7c27fa1..feb04ea 100644
--- a/include/linux/inet_diag.h
+++ b/include/linux/inet_diag.h
@@ -52,6 +52,12 @@ struct sock *inet_diag_find_one_icsk(struct net *net,
 
 int inet_diag_bc_sk(const struct nlattr *_bc, struct sock *sk);
 
+void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk);
+
+int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
+			     struct inet_diag_msg *r, int ext,
+			     struct user_namespace *user_ns);
+
 extern int  inet_diag_register(const struct inet_diag_handler *handler);
 extern void inet_diag_unregister(const struct inet_diag_handler *handler);
 #endif /* _INET_DIAG_H_ */
diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index 1ce724b..f69edcf 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -3,12 +3,6 @@
 #include <linux/sock_diag.h>
 #include <net/sctp/sctp.h>
 
-extern void inet_diag_msg_common_fill(struct inet_diag_msg *r,
-				      struct sock *sk);
-extern int inet_diag_msg_attrs_fill(struct sock *sk, struct sk_buff *skb,
-				    struct inet_diag_msg *r, int ext,
-				    struct user_namespace *user_ns);
-
 static void sctp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 			       void *info);
 
-- 
2.8.1
