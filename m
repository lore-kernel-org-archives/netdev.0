From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 1/7] sock_diag: Arrange sock_diag.h such that it is exportable
 to userspace
Date: Fri, 30 Dec 2011 14:52:21 +0400
Message-ID: <4EFD97E5.6080701@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:38969 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751459Ab1L3Kwb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Dec 2011 05:52:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Properly toss existing components around the ifdef __KERNEL__
and include the header into the header-y target.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 include/linux/Kbuild      |    1 +
 include/linux/sock_diag.h |   10 +++++++---
 2 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 0b091b3..8e484d6 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -195,6 +195,7 @@ header-y += igmp.h
 header-y += in.h
 header-y += in6.h
 header-y += in_route.h
+header-y += sock_diag.h
 header-y += inet_diag.h
 header-y += inotify.h
 header-y += input.h
diff --git a/include/linux/sock_diag.h b/include/linux/sock_diag.h
index 379d5dc..66bc18e 100644
--- a/include/linux/sock_diag.h
+++ b/include/linux/sock_diag.h
@@ -1,16 +1,19 @@
 #ifndef __SOCK_DIAG_H__
 #define __SOCK_DIAG_H__
 
-#define SOCK_DIAG_BY_FAMILY 20
+#include <linux/types.h>
 
-struct sk_buff;
-struct nlmsghdr;
+#define SOCK_DIAG_BY_FAMILY 20
 
 struct sock_diag_req {
 	__u8	sdiag_family;
 	__u8	sdiag_protocol;
 };
 
+#ifdef __KERNEL__
+struct sk_buff;
+struct nlmsghdr;
+
 struct sock_diag_handler {
 	__u8 family;
 	int (*dump)(struct sk_buff *skb, struct nlmsghdr *nlh);
@@ -26,4 +29,5 @@ int sock_diag_check_cookie(void *sk, __u32 *cookie);
 void sock_diag_save_cookie(void *sk, __u32 *cookie);
 
 extern struct sock *sock_diag_nlsk;
+#endif /* KERNEL */
 #endif
-- 
1.5.5.6
