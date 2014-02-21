From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next v2 5/6] net: ns: add ieee802154_6lowpan namespace
Date: Fri, 21 Feb 2014 19:59:01 +0100
Message-ID: <1393009142-1694-6-git-send-email-alex.aring@gmail.com>
References: <1393009142-1694-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, davem@davemloft.net,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	martin.townsend@xsilon.com, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:42563 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229AbaBUS70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 13:59:26 -0500
Received: by mail-ee0-f47.google.com with SMTP id d49so1799668eek.34
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 10:59:25 -0800 (PST)
In-Reply-To: <1393009142-1694-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds necessary ieee802154 6lowpan namespace to provide the
inet_frag information. This is a initial support for handling 6lowpan
fragmentation with the inet_frag api.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Tested-by: Martin Townsend <martin.townsend@xsilon.com>
---
 include/net/net_namespace.h            |  4 ++++
 include/net/netns/ieee802154_6lowpan.h | 13 +++++++++++++
 2 files changed, 17 insertions(+)
 create mode 100644 include/net/netns/ieee802154_6lowpan.h

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 991dcd9..79387f7 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -15,6 +15,7 @@
 #include <net/netns/packet.h>
 #include <net/netns/ipv4.h>
 #include <net/netns/ipv6.h>
+#include <net/netns/ieee802154_6lowpan.h>
 #include <net/netns/sctp.h>
 #include <net/netns/dccp.h>
 #include <net/netns/netfilter.h>
@@ -90,6 +91,9 @@ struct net {
 #if IS_ENABLED(CONFIG_IPV6)
 	struct netns_ipv6	ipv6;
 #endif
+#if IS_ENABLED(CONFIG_IEEE802154_6LOWPAN)
+	struct netns_ieee802154_lowpan	ieee802154_lowpan;
+#endif
 #if defined(CONFIG_IP_SCTP) || defined(CONFIG_IP_SCTP_MODULE)
 	struct netns_sctp	sctp;
 #endif
diff --git a/include/net/netns/ieee802154_6lowpan.h b/include/net/netns/ieee802154_6lowpan.h
new file mode 100644
index 0000000..88110b7
--- /dev/null
+++ b/include/net/netns/ieee802154_6lowpan.h
@@ -0,0 +1,13 @@
+/*
+ * ieee802154 6lowpan in net namespaces
+ */
+
+#include <net/inet_frag.h>
+
+#ifndef __NETNS_IEEE802154_6LOWPAN_H__
+#define __NETNS_IEEE802154_6LOWPAN_H__
+
+struct netns_ieee802154_lowpan {
+};
+
+#endif
-- 
1.9.0
