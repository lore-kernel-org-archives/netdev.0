From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 2/7] Add missing macros which was removed from kernel header.
Date: Tue,  5 Dec 2006 19:15:28 +0900
Message-ID: <1165313728822-git-send-email-nakam@linux-ipv6.org>
Cc: netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:38921 "EHLO
	neptune.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S937435AbWLEKP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 05:15:57 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

{IFA,IFLA,NDA,NDTA}_{RTA,PAYLOAD} macro is removed from kernel
header since linux-2.6.19 because it is not used by kernel code.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/libnetlink.h |   35 +++++++++++++++++++++++++++++++++++
 1 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index 63cc3c8..9de3a0b 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -4,6 +4,9 @@ #define __LIBNETLINK_H__ 1
 #include <asm/types.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
+#include <linux/if_link.h>
+#include <linux/if_addr.h>
+#include <linux/neighbour.h>
 
 struct rtnl_handle
 {
@@ -53,5 +56,37 @@ extern int rtnl_from_file(FILE *, rtnl_f
 #define NLMSG_TAIL(nmsg) \
 	((struct rtattr *) (((void *) (nmsg)) + NLMSG_ALIGN((nmsg)->nlmsg_len)))
 
+#ifndef IFA_RTA
+#define IFA_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifaddrmsg))))
+#endif
+#ifndef IFA_PAYLOAD
+#define IFA_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ifaddrmsg))
+#endif
+
+#ifndef IFLA_RTA
+#define IFLA_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ifinfomsg))))
+#endif
+#ifndef IFLA_PAYLOAD
+#define IFLA_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ifinfomsg))
+#endif
+
+#ifndef NDA_RTA
+#define NDA_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ndmsg))))
+#endif
+#ifndef NDA_PAYLOAD
+#define NDA_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct ndmsg))
+#endif
+
+#ifndef NDTA_RTA
+#define NDTA_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct ndtmsg))))
+#endif
+#ifndef NDTA_PAYLOAD
+#define NDTA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndtmsg))
+#endif
+
 #endif /* __LIBNETLINK_H__ */
 
-- 
1.4.2

