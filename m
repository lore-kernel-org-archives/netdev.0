From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 1/3] include: update headers
Date: Tue, 20 Jan 2015 11:36:01 +0100
Message-ID: <1421750163-20348-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53579 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702AbbATKgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 05:36:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/if_link.h       |  1 +
 include/linux/net_namespace.h | 23 +++++++++++++++++++++++
 include/linux/rtnetlink.h     |  5 +++++
 3 files changed, 29 insertions(+)
 create mode 100644 include/linux/net_namespace.h

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 167ec34bab73..58e32ace7d2a 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -146,6 +146,7 @@ enum {
 	IFLA_PHYS_PORT_ID,
 	IFLA_CARRIER_CHANGES,
 	IFLA_PHYS_SWITCH_ID,
+	IFLA_LINK_NETNSID,
 	__IFLA_MAX
 };
 
diff --git a/include/linux/net_namespace.h b/include/linux/net_namespace.h
new file mode 100644
index 000000000000..9a92b7e14a19
--- /dev/null
+++ b/include/linux/net_namespace.h
@@ -0,0 +1,23 @@
+/* Copyright (c) 2015 6WIND S.A.
+ * Author: Nicolas Dichtel <nicolas.dichtel@6wind.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+#ifndef _LINUX_NET_NAMESPACE_H_
+#define _LINUX_NET_NAMESPACE_H_
+
+/* Attributes of RTM_NEWNSID/RTM_GETNSID messages */
+enum {
+	NETNSA_NONE,
+#define NETNSA_NSID_NOT_ASSIGNED -1
+	NETNSA_NSID,
+	NETNSA_PID,
+	NETNSA_FD,
+	__NETNSA_MAX,
+};
+
+#define NETNSA_MAX		(__NETNSA_MAX - 1)
+
+#endif /* _LINUX_NET_NAMESPACE_H_ */
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 9111053f2250..3eb78105399b 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -132,6 +132,11 @@ enum {
 	RTM_GETMDB = 86,
 #define RTM_GETMDB RTM_GETMDB
 
+	RTM_NEWNSID = 88,
+#define RTM_NEWNSID RTM_NEWNSID
+	RTM_GETNSID = 90,
+#define RTM_GETNSID RTM_GETNSID
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
-- 
2.2.2
