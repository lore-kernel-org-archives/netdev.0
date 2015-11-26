From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 2/7] net: ipmr: remove unused MFC_NOTIFY flag and make the flags enum
Date: Thu, 26 Nov 2015 15:23:45 +0100
Message-ID: <1448547830-21716-3-git-send-email-razor@blackwall.org>
References: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:34877 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750759AbbKZOYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:24:04 -0500
Received: by wmuu63 with SMTP id u63so23501773wmu.0
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 06:24:03 -0800 (PST)
In-Reply-To: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

MFC_NOTIFY was introduced in kernel 2.1.68 but afaik it hasn't been used
and I couldn't find any users currently so just remove it. Only
MFC_STATIC is left, so move it into an enum, add a description and use
BIT().

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/mroute.h | 10 +++++++---
 net/ipv4/ipmr.c        |  2 --
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 79aaa9fc1a15..fa66ebc1fed6 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -64,6 +64,13 @@ struct vif_device {
 
 #define VIFF_STATIC 0x8000
 
+/* mfc_flags:
+ * MFC_STATIC - the entry was added statically (not by a routing daemon)
+ */
+enum {
+	MFC_STATIC = BIT(0),
+};
+
 struct mfc_cache {
 	struct list_head list;
 	__be32 mfc_mcastgrp;			/* Group the entry belongs to 	*/
@@ -89,9 +96,6 @@ struct mfc_cache {
 	struct rcu_head	rcu;
 };
 
-#define MFC_STATIC		1
-#define MFC_NOTIFY		2
-
 #define MFC_LINES		64
 
 #ifdef __BIG_ENDIAN
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a2d248d9c35c..a74e61883b8f 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2199,8 +2199,6 @@ int ipmr_get_route(struct net *net, struct sk_buff *skb,
 	}
 
 	read_lock(&mrt_lock);
-	if (!nowait && (rtm->rtm_flags & RTM_F_NOTIFY))
-		cache->mfc_flags |= MFC_NOTIFY;
 	err = __ipmr_fill_mroute(mrt, skb, cache, rtm);
 	read_unlock(&mrt_lock);
 	rcu_read_unlock();
-- 
2.4.3
