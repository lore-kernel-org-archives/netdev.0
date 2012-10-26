From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v3 1/5] rtnl: add a new type of msg to advertise protocol configuration
Date: Fri, 26 Oct 2012 10:28:49 +0200
Message-ID: <1351240133-4427-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20121026.021830.1470799532580844849.davem@davemloft.net>
 <1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38311 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932139Ab2JZITt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Oct 2012 04:19:49 -0400
In-Reply-To: <1351240133-4427-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new type is added to allow userland to monitor protocol configuration, like
IPv4 or IPv6.
For example, monitoring the state of the forwarding status of an interface of
the system.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/netconf.h   | 22 ++++++++++++++++++++++
 include/uapi/linux/rtnetlink.h |  5 +++++
 2 files changed, 27 insertions(+)
 create mode 100644 include/uapi/linux/netconf.h

diff --git a/include/uapi/linux/netconf.h b/include/uapi/linux/netconf.h
new file mode 100644
index 0000000..d051372
--- /dev/null
+++ b/include/uapi/linux/netconf.h
@@ -0,0 +1,22 @@
+#ifndef _UAPI_LINUX_NETCONF_H_
+#define _UAPI_LINUX_NETCONF_H_
+
+#include <linux/types.h>
+#include <linux/netlink.h>
+
+struct netconfmsg {
+	__u8	ncm_family;
+};
+
+enum {
+	NETCONFA_UNSPEC,
+	NETCONFA_IFINDEX,
+	NETCONFA_FORWARDING,
+	__NETCONFA_MAX
+};
+#define NETCONFA_MAX	(__NETCONFA_MAX - 1)
+
+#define NETCONFA_IFINDEX_ALL		-1
+#define NETCONFA_IFINDEX_DEFAULT	-2
+
+#endif /* _UAPI_LINUX_NETCONF_H_ */
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index fcd768b..0043b41 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -120,6 +120,11 @@ enum {
 	RTM_SETDCB,
 #define RTM_SETDCB RTM_SETDCB
 
+	RTM_NEWNETCONF = 80,
+#define RTM_NEWNETCONF RTM_NEWNETCONF
+	RTM_GETNETCONF = 82,
+#define RTM_GETNETCONF RTM_GETNETCONF
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
-- 
1.7.12
