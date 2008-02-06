From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 14/14] replace __inline__ by inline in include/linux (net related)
Date: Wed, 06 Feb 2008 10:14:19 +0100
Message-ID: <20080206092300.701741592@mai.toulouse-stg.fr.ibm.com>
References: <20080206091405.581849582@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:44494 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760600AbYBFJ2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2008 04:28:32 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m169SUPO398490
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 09:28:30 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m169SUKt2351308
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:28:30 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m169SU1U016391
	for <netdev@vger.kernel.org>; Wed, 6 Feb 2008 10:28:30 +0100
Content-Disposition: inline; filename=remove-__inline__-in-include-linux.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace __inline__ by inline in include/linux (net related)

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 include/linux/atm.h        |    4 ++--
 include/linux/atmsap.h     |    2 +-
 include/linux/hdlc.h       |   13 +++++++------
 include/linux/inetdevice.h |   14 ++++++--------
 include/linux/netlink.h    |    5 +++--
 include/linux/rtnetlink.h  |    2 +-
 6 files changed, 20 insertions(+), 20 deletions(-)

Index: net-2.6/include/linux/atm.h
===================================================================
--- net-2.6.orig/include/linux/atm.h
+++ net-2.6/include/linux/atm.h
@@ -217,13 +217,13 @@ struct sockaddr_atmsvc {
 };
 
 
-static __inline__ int atmsvc_addr_in_use(struct sockaddr_atmsvc addr)
+static inline int atmsvc_addr_in_use(struct sockaddr_atmsvc addr)
 {
 	return *addr.sas_addr.prv || *addr.sas_addr.pub;
 }
 
 
-static __inline__ int atmpvc_addr_in_use(struct sockaddr_atmpvc addr)
+static inline int atmpvc_addr_in_use(struct sockaddr_atmpvc addr)
 {
 	return addr.sap_addr.itf || addr.sap_addr.vpi || addr.sap_addr.vci;
 }
Index: net-2.6/include/linux/atmsap.h
===================================================================
--- net-2.6.orig/include/linux/atmsap.h
+++ net-2.6/include/linux/atmsap.h
@@ -154,7 +154,7 @@ struct atm_sap {
 };
 
 
-static __inline__ int blli_in_use(struct atm_blli blli)
+static inline int blli_in_use(struct atm_blli blli)
 {
 	return blli.l2_proto || blli.l3_proto;
 }
Index: net-2.6/include/linux/hdlc.h
===================================================================
--- net-2.6.orig/include/linux/hdlc.h
+++ net-2.6/include/linux/hdlc.h
@@ -84,18 +84,19 @@ void unregister_hdlc_protocol(struct hdl
 struct net_device *alloc_hdlcdev(void *priv);
 
 
-static __inline__ struct hdlc_device_desc* dev_to_desc(struct net_device *dev)
+static inline struct hdlc_device_desc
+*dev_to_desc(struct net_device *dev)
 {
 	return netdev_priv(dev);
 }
 
-static __inline__ hdlc_device* dev_to_hdlc(struct net_device *dev)
+static inline hdlc_device *dev_to_hdlc(struct net_device *dev)
 {
 	return netdev_priv(dev) + sizeof(struct hdlc_device_desc);
 }
 
 
-static __inline__ void debug_frame(const struct sk_buff *skb)
+static inline void debug_frame(const struct sk_buff *skb)
 {
 	int i;
 
@@ -120,14 +121,14 @@ int attach_hdlc_protocol(struct net_devi
 /* May be used by hardware driver to gain control over HDLC device */
 void detach_hdlc_protocol(struct net_device *dev);
 
-static __inline__ struct net_device_stats *hdlc_stats(struct net_device *dev)
+static inline struct net_device_stats *hdlc_stats(struct net_device *dev)
 {
 	return &dev_to_desc(dev)->stats;
 }
 
 
-static __inline__ __be16 hdlc_type_trans(struct sk_buff *skb,
-					 struct net_device *dev)
+static inline __be16 hdlc_type_trans(struct sk_buff *skb,
+				     struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 
Index: net-2.6/include/linux/inetdevice.h
===================================================================
--- net-2.6.orig/include/linux/inetdevice.h
+++ net-2.6/include/linux/inetdevice.h
@@ -136,7 +136,7 @@ extern __be32		inet_select_addr(const st
 extern __be32		inet_confirm_addr(struct in_device *in_dev, __be32 dst, __be32 local, int scope);
 extern struct in_ifaddr *inet_ifa_byprefix(struct in_device *in_dev, __be32 prefix, __be32 mask);
 
-static __inline__ int inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
+static inline int inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
 {
 	return !((addr^ifa->ifa_address)&ifa->ifa_mask);
 }
@@ -145,7 +145,7 @@ static __inline__ int inet_ifa_match(__b
  *	Check if a mask is acceptable.
  */
  
-static __inline__ int bad_mask(__be32 mask, __be32 addr)
+static inline int bad_mask(__be32 mask, __be32 addr)
 {
 	__u32 hmask;
 	if (addr & (mask = ~mask))
@@ -173,8 +173,7 @@ static inline struct in_device *__in_dev
 	return in_dev;
 }
 
-static __inline__ struct in_device *
-in_dev_get(const struct net_device *dev)
+static inline struct in_device *in_dev_get(const struct net_device *dev)
 {
 	struct in_device *in_dev;
 
@@ -186,8 +185,7 @@ in_dev_get(const struct net_device *dev)
 	return in_dev;
 }
 
-static __inline__ struct in_device *
-__in_dev_get_rtnl(const struct net_device *dev)
+static inline struct in_device *__in_dev_get_rtnl(const struct net_device *dev)
 {
 	return (struct in_device*)dev->ip_ptr;
 }
@@ -205,14 +203,14 @@ static inline void in_dev_put(struct in_
 
 #endif /* __KERNEL__ */
 
-static __inline__ __be32 inet_make_mask(int logmask)
+static inline __be32 inet_make_mask(int logmask)
 {
 	if (logmask)
 		return htonl(~((1<<(32-logmask))-1));
 	return 0;
 }
 
-static __inline__ int inet_mask_len(__be32 mask)
+static inline int inet_mask_len(__be32 mask)
 {
 	__u32 hmask = ntohl(mask);
 	if (!hmask)
Index: net-2.6/include/linux/netlink.h
===================================================================
--- net-2.6.orig/include/linux/netlink.h
+++ net-2.6/include/linux/netlink.h
@@ -229,8 +229,9 @@ struct netlink_notify
 	int protocol;
 };
 
-static __inline__ struct nlmsghdr *
-__nlmsg_put(struct sk_buff *skb, u32 pid, u32 seq, int type, int len, int flags)
+static inline struct nlmsghdr *__nlmsg_put(struct sk_buff *skb, u32 pid,
+					   u32 seq, int type, int len,
+					   int flags)
 {
 	struct nlmsghdr *nlh;
 	int size = NLMSG_LENGTH(len);
Index: net-2.6/include/linux/rtnetlink.h
===================================================================
--- net-2.6.orig/include/linux/rtnetlink.h
+++ net-2.6/include/linux/rtnetlink.h
@@ -602,7 +602,7 @@ struct tcamsg
 
 #include <linux/mutex.h>
 
-static __inline__ int rtattr_strcmp(const struct rtattr *rta, const char *str)
+static inline int rtattr_strcmp(const struct rtattr *rta, const char *str)
 {
 	int len = strlen(str) + 1;
 	return len > rta->rta_len || memcmp(RTA_DATA(rta), str, len);

-- 
