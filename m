From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 1/3] rtnl: add a new type of msg to advertise protocol configuration
Date: Tue, 23 Oct 2012 11:49:47 +0200
Message-ID: <1350985789-24966-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1350985789-24966-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:60964 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932503Ab2JWJmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 05:42:05 -0400
In-Reply-To: <1350985789-24966-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new type is added to allow userland to monitor protocol configuration, like
IPv4 or IPv6.
For example, monitoring the state of the forwarding status of an interface of
the system.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/netconf.h   | 22 ++++++++++++++++++++++
 include/uapi/linux/rtnetlink.h |  3 +++
 2 files changed, 25 insertions(+)
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
index fcd768b..8372514 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -120,6 +120,9 @@ enum {
 	RTM_SETDCB,
 #define RTM_SETDCB RTM_SETDCB
 
+	RTM_NEWNETCONF = 80,
+#define RTM_NEWNETCONF RTM_NEWNETCONF
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
-- 
1.7.12
