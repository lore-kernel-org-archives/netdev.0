From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 15/27] afnetns: add ipv6_get_ifaddr_afnetns_rcu
Date: Mon, 13 Mar 2017 00:01:39 +0100
Message-ID: <20170312230151.5185-16-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:59494 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935647AbdCLXCQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:16 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 9D06920777
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:06 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 872A9240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:05 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/addrconf.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index e3f1920ca57968..644fa68bb4ddef 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -104,6 +104,23 @@ int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
 				 u32 addr_flags, bool sllao, bool tokenized,
 				 __u32 valid_lft, u32 prefered_lft);
 
+static inline
+struct afnetns *ipv6_get_ifaddr_afnetns_rcu(struct net *net,
+					    const struct in6_addr *addr,
+					    struct net_device *dev)
+{
+#if IS_ENABLED(CONFIG_AFNETNS)
+	struct inet6_ifaddr *ifp;
+
+	ifp = ipv6_get_ifaddr(net, addr, dev, 1);
+	if (ifp)
+		return ifp->afnetns;
+	return net->afnet_ns;
+#else
+	return NULL;
+#endif
+}
+
 static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
 {
 	if (dev->addr_len != ETH_ALEN)
-- 
2.9.3
