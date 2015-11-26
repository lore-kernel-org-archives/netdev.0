From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 3/7] net: ipmr: adjust mroute.h style and drop extern
Date: Thu, 26 Nov 2015 15:23:46 +0100
Message-ID: <1448547830-21716-4-git-send-email-razor@blackwall.org>
References: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:34889 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232AbbKZOYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:24:05 -0500
Received: by wmuu63 with SMTP id u63so23502258wmu.0
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 06:24:04 -0800 (PST)
In-Reply-To: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Remove extra spaces and tabs, adjust function definitions, remove an
unnecessary ifdef (already used below, just move code) and drop extern
from the functions.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/mroute.h | 47 +++++++++++++++++++++--------------------------
 1 file changed, 21 insertions(+), 26 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index fa66ebc1fed6..7c567a2679ce 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -9,38 +9,28 @@
 #ifdef CONFIG_IP_MROUTE
 static inline int ip_mroute_opt(int opt)
 {
-	return (opt >= MRT_BASE) && (opt <= MRT_MAX);
+	return opt >= MRT_BASE && opt <= MRT_MAX;
 }
-#else
-static inline int ip_mroute_opt(int opt)
-{
-	return 0;
-}
-#endif
 
-#ifdef CONFIG_IP_MROUTE
-extern int ip_mroute_setsockopt(struct sock *, int, char __user *, unsigned int);
-extern int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
-extern int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
-extern int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
-extern int ip_mr_init(void);
+int ip_mroute_setsockopt(struct sock *, int, char __user *, unsigned int);
+int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
+int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
+int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
+int ip_mr_init(void);
 #else
-static inline
-int ip_mroute_setsockopt(struct sock *sock,
-			 int optname, char __user *optval, unsigned int optlen)
+static inline int ip_mroute_setsockopt(struct sock *sock, int optname,
+				       char __user *optval, unsigned int optlen)
 {
 	return -ENOPROTOOPT;
 }
 
-static inline
-int ip_mroute_getsockopt(struct sock *sock,
-			 int optname, char __user *optval, int __user *optlen)
+static inline int ip_mroute_getsockopt(struct sock *sock, int optname,
+				       char __user *optval, int __user *optlen)
 {
 	return -ENOPROTOOPT;
 }
 
-static inline
-int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
+static inline int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg)
 {
 	return -ENOIOCTLCMD;
 }
@@ -49,6 +39,11 @@ static inline int ip_mr_init(void)
 {
 	return 0;
 }
+
+static inline int ip_mroute_opt(int opt)
+{
+	return 0;
+}
 #endif
 
 struct vif_device {
@@ -96,16 +91,16 @@ struct mfc_cache {
 	struct rcu_head	rcu;
 };
 
-#define MFC_LINES		64
+#define MFC_LINES 64
 
 #ifdef __BIG_ENDIAN
 #define MFC_HASH(a,b)	(((((__force u32)(__be32)a)>>24)^(((__force u32)(__be32)b)>>26))&(MFC_LINES-1))
 #else
 #define MFC_HASH(a,b)	((((__force u32)(__be32)a)^(((__force u32)(__be32)b)>>2))&(MFC_LINES-1))
-#endif		
+#endif
 
 struct rtmsg;
-extern int ipmr_get_route(struct net *net, struct sk_buff *skb,
-			  __be32 saddr, __be32 daddr,
-			  struct rtmsg *rtm, int nowait);
+int ipmr_get_route(struct net *net, struct sk_buff *skb,
+		   __be32 saddr, __be32 daddr,
+		   struct rtmsg *rtm, int nowait);
 #endif
-- 
2.4.3
