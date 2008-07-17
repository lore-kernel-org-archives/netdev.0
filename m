From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/16] mib: add netns/mib.h file
Date: Thu, 17 Jul 2008 17:21:55 +0400
Message-ID: <487F4773.5060906@openvz.org>
References: <487F46CD.7090103@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43283 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755969AbYGQNWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 09:22:01 -0400
In-Reply-To: <487F46CD.7090103@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The only structure declared within is the netns_mib, which will
carry all our mibs within. I didn't put the mibs in the existing
netns_xxx structures to make it possible to mark this one as
properly aligned and get in a separate "read-mostly" cache-line.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/net_namespace.h |    2 ++
 include/net/netns/mib.h     |    9 +++++++++
 2 files changed, 11 insertions(+), 0 deletions(-)
 create mode 100644 include/net/netns/mib.h

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index f904430..3855620 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -9,6 +9,7 @@
 #include <linux/list.h>
 
 #include <net/netns/core.h>
+#include <net/netns/mib.h>
 #include <net/netns/unix.h>
 #include <net/netns/packet.h>
 #include <net/netns/ipv4.h>
@@ -52,6 +53,7 @@ struct net {
 	struct sock 		*rtnl;			/* rtnetlink socket */
 
 	struct netns_core	core;
+	struct netns_mib	mib;
 	struct netns_packet	packet;
 	struct netns_unix	unx;
 	struct netns_ipv4	ipv4;
diff --git a/include/net/netns/mib.h b/include/net/netns/mib.h
new file mode 100644
index 0000000..9f4b31e
--- /dev/null
+++ b/include/net/netns/mib.h
@@ -0,0 +1,9 @@
+#ifndef __NETNS_MIB_H__
+#define __NETNS_MIB_H__
+
+#include <net/snmp.h>
+
+struct netns_mib {
+};
+
+#endif
-- 
1.5.5.1

