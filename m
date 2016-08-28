From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 1/3] net: Add read_sock proto_op
Date: Sun, 28 Aug 2016 14:43:17 -0700
Message-ID: <1472420599-510735-2-git-send-email-tom@herbertland.com>
References: <1472420599-510735-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <davejwatson@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:60561 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932346AbcH1Vnh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 17:43:37 -0400
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
        by m0001303.ppops.net (8.16.0.17/8.16.0.17) with SMTP id u7SLgPer007439
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 14:43:36 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0001303.ppops.net with ESMTP id 2536hb5240-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 14:43:36 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)     by
 mx-out.facebook.com (10.103.99.99) with ESMTP  id
 78ea3bf86d6811e68a6b0002c9dfb610-ccbfdaa0 for <netdev@vger.kernel.org>;        Sun,
 28 Aug 2016 14:43:35 -0700
In-Reply-To: <1472420599-510735-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new function in proto_ops structure. This includes moving the
typedef got sk_read_actor into net.h and removing the definition from
tcp.h.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/net.h | 6 ++++++
 include/net/tcp.h   | 2 --
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index b9f0ff4..cd0c8bd 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -25,6 +25,7 @@
 #include <linux/kmemcheck.h>
 #include <linux/rcupdate.h>
 #include <linux/once.h>
+#include <linux/fs.h>
 
 #include <uapi/linux/net.h>
 
@@ -128,6 +129,9 @@ struct page;
 struct sockaddr;
 struct msghdr;
 struct module;
+struct sk_buff;
+typedef int (*sk_read_actor_t)(read_descriptor_t *, struct sk_buff *,
+			       unsigned int, size_t);
 
 struct proto_ops {
 	int		family;
@@ -186,6 +190,8 @@ struct proto_ops {
 				       struct pipe_inode_info *pipe, size_t len, unsigned int flags);
 	int		(*set_peek_off)(struct sock *sk, int val);
 	int		(*peek_len)(struct socket *sock);
+	int		(*read_sock)(struct sock *sk, read_descriptor_t *desc,
+				     sk_read_actor_t recv_actor);
 };
 
 #define DECLARE_SOCKADDR(type, dst, src)	\
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 25d64f6..d56666a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -603,8 +603,6 @@ static inline int tcp_bound_to_half_wnd(struct tcp_sock *tp, int pktsize)
 void tcp_get_info(struct sock *, struct tcp_info *);
 
 /* Read 'sendfile()'-style from a TCP socket */
-typedef int (*sk_read_actor_t)(read_descriptor_t *, struct sk_buff *,
-				unsigned int, size_t);
 int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 		  sk_read_actor_t recv_actor);
 
-- 
2.8.0.rc2
