From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 10/27] afnetns: add ifa_find_afnetns_rcu
Date: Mon, 13 Mar 2017 00:01:34 +0100
Message-ID: <20170312230151.5185-11-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57396 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935616AbdCLXCN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:13 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 09FCE2077B
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:01 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 3FAE52423E
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:00 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/linux/inetdevice.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index eb1b662f62626f..01cbcfe93383b7 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -180,6 +180,17 @@ static __inline__ bool inet_ifa_match(__be32 addr, struct in_ifaddr *ifa)
 	return !((addr^ifa->ifa_address)&ifa->ifa_mask);
 }
 
+static inline struct afnetns *ifa_find_afnetns_rcu(struct net *net, __be32 addr)
+{
+#if IS_ENABLED(CONFIG_AFNETNS)
+	struct in_ifaddr *ifa = ifa_find_rcu(net, addr);
+
+	return ifa ? ifa->afnetns : net->afnet_ns;
+#else
+	return NULL;
+#endif
+}
+
 /*
  *	Check if a mask is acceptable.
  */
-- 
2.9.3
