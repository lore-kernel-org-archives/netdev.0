From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] net: diag: add missing declarations
Date: Thu,  9 Jun 2016 12:17:28 +0100
Message-ID: <1465471048-13493-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: linux-kernel@lists.codethink.co.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The functions inet_diag_msg_common_fill and inet_diag_msg_attrs_fill
seem to have been missed from the include/linux/inet_diag.h header
file. Add them to fix the following warnings:

net/ipv4/inet_diag.c:69:6: warning: symbol 'inet_diag_msg_common_fill' was not declared. Should it be static?
net/ipv4/inet_diag.c:108:5: warning: symbol 'inet_diag_msg_attrs_fill' was not declared. Should it be static?

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/inet_diag.h | 6 ++++++
 1 file changed, 6 insertions(+)

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
-- 
2.8.1
