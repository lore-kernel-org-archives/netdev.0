From: Samir Bellabes <sam@synack.fr>
Subject: [RFC v2 10/10] snet: introduce snet_utils
Date: Tue,  2 Mar 2010 21:23:14 +0100
Message-ID: <1267561394-13626-11-git-send-email-sam@synack.fr>
References: <1267561394-13626-1-git-send-email-sam@synack.fr>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1267561394-13626-1-git-send-email-sam@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch provides helper functions for other subsystems

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/snet_utils.c |   38 ++++++++++++++++++++++++++++++++++++++
 security/snet/snet_utils.h |   10 ++++++++++
 2 files changed, 48 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/snet_utils.c
 create mode 100644 security/snet/snet_utils.h

diff --git a/security/snet/snet_utils.c b/security/snet/snet_utils.c
new file mode 100644
index 0000000..e9178d7
--- /dev/null
+++ b/security/snet/snet_utils.c
@@ -0,0 +1,38 @@
+#include <linux/types.h>
+#include <linux/snet.h>
+
+const char *snet_verdict_name(const enum snet_verdict cmd)
+{
+	static const char *const verdict_name[] = {
+		[SNET_VERDICT_GRANT]	= "Grant",
+		[SNET_VERDICT_DENY]	= "Deny",
+		[SNET_VERDICT_PENDING]	= "Pending",
+		[SNET_VERDICT_NONE]	= "None",
+	};
+
+	if (cmd >= SNET_NR_VERDICT_TYPES)
+		return "INVALID";
+	else
+		return verdict_name[cmd];
+}
+
+const char *snet_syscall_name(const enum snet_syscall sys)
+{
+	static const char *const syscall_name[] = {
+		[SNET_SOCKET_CREATE]		= "Create",
+		[SNET_SOCKET_BIND]		= "Bind",
+		[SNET_SOCKET_CONNECT]		= "Connect",
+		[SNET_SOCKET_LISTEN]		= "Listen",
+		[SNET_SOCKET_ACCEPT]		= "Accept",
+		[SNET_SOCKET_POST_ACCEPT]	= "Post Accept",
+		[SNET_SOCKET_SENDMSG]		= "Sendmsg",
+		[SNET_SOCKET_RECVMSG]		= "Recvmsg",
+		[SNET_SOCKET_SOCK_RCV_SKB]	= "Sock Rcv Skb",
+		[SNET_SOCKET_CLOSE]		= "Close",
+	};
+
+	if (sys >= SNET_NR_SOCKET_TYPES)
+		return "INVALID";
+	else
+		return syscall_name[sys];
+}
diff --git a/security/snet/snet_utils.h b/security/snet/snet_utils.h
new file mode 100644
index 0000000..4dad18b
--- /dev/null
+++ b/security/snet/snet_utils.h
@@ -0,0 +1,10 @@
+#ifndef _SNET_UTILS_H
+#define _SNET_UTILS_H
+
+#include <linux/skbuff.h>
+
+int snet_data_fill(struct sk_buff *skb_rsp, struct snet_info *info);
+const char *snet_verdict_name(const enum snet_verdict cmd);
+const char *snet_syscall_name(const enum snet_syscall sys);
+
+#endif	/* _SNET_UTILS_H */
-- 
1.6.3.3

