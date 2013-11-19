From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH 1/2] ipv6: add helper function for copy addrs from old sock
Date: Tue, 19 Nov 2013 10:47:26 +0800
Message-ID: <1384829247-8624-2-git-send-email-wangweidong1@huawei.com>
References: <1384829247-8624-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dccp@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>, <dingtianhong@huawei.com>
To: <davem@davemloft.net>, <gerrit@erg.abdn.ac.uk>,
	<kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:54406 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754Ab3KSCsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 21:48:24 -0500
In-Reply-To: <1384829247-8624-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add sk_v6_copy_addrs for copying sk_v6_daddr and sk_v6_rcv_saddr, it
will be used in the coming patch.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sock.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/net/sock.h b/include/net/sock.h
index e3a18ff..9be2b9f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -442,6 +442,12 @@ struct sock {
 #define SK_CAN_REUSE	1
 #define SK_FORCE_REUSE	2
 
+static inline void sk_v6_copy_addrs(struct sock *newsk, struct sock *oldsk)
+{
+	newsk->sk_v6_daddr = oldsk->sk_v6_daddr;
+	newsk->sk_v6_rcv_saddr = oldsk->sk_v6_rcv_saddr;
+}
+
 static inline int sk_peek_offset(struct sock *sk, int flags)
 {
 	if ((flags & MSG_PEEK) && (sk->sk_peek_off >= 0))
-- 
1.7.12
