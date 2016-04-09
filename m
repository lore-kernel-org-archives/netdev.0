From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net-next 3/6] sctp: export some functions for sctp_diag in inet_diag
Date: Sat,  9 Apr 2016 12:53:11 +0800
Message-ID: <5408d667c2a83b8917a501b92810c82f9a66f584.1460177331.git.lucien.xin@gmail.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
 <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
 <a3703f4379eeb3a385d3cc000dd621f77540608e.1460177331.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34178 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbcDIExe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 00:53:34 -0400
In-Reply-To: <a3703f4379eeb3a385d3cc000dd621f77540608e.1460177331.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1460177331.git.lucien.xin@gmail.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet_diag_msg_common_fill is used to fill the diag msg common info,
we need to use it in sctp_diag as well, so export it.

We also add inet_diag_get_handler() to access inet_diag_table in sctp
diag.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/inet_diag.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index bd591eb..5a0bfe0 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -66,7 +66,13 @@ static void inet_diag_unlock_handler(const struct inet_diag_handler *handler)
 	mutex_unlock(&inet_diag_table_mutex);
 }
 
-static void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
+const struct inet_diag_handler *inet_diag_get_handler(int proto)
+{
+	return inet_diag_table[proto];
+}
+EXPORT_SYMBOL_GPL(inet_diag_get_handler);
+
+void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
 {
 	r->idiag_family = sk->sk_family;
 
@@ -89,6 +95,7 @@ static void inet_diag_msg_common_fill(struct inet_diag_msg *r, struct sock *sk)
 	r->id.idiag_dst[0] = sk->sk_daddr;
 	}
 }
+EXPORT_SYMBOL_GPL(inet_diag_msg_common_fill);
 
 static size_t inet_sk_attr_size(void)
 {
-- 
2.1.0
