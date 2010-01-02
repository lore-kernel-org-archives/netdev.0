From: Samir Bellabes <sam@synack.fr>
Subject: [RFC 9/9] snet: introduce snet_utils.c and snet_utils.h
Date: Sat,  2 Jan 2010 14:04:16 +0100
Message-ID: <1262437456-24476-10-git-send-email-sam@synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
Cc: Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1262437456-24476-1-git-send-email-sam@synack.fr>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch provides helper functions for other subsystems

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/include/snet_utils.h |    9 ++++++++
 security/snet/snet_utils.c         |   40 ++++++++++++++++++++++++++++++++++++
 2 files changed, 49 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/include/snet_utils.h
 create mode 100644 security/snet/snet_utils.c

diff --git a/security/snet/include/snet_utils.h b/security/snet/include/snet_utils.h
new file mode 100644
index 0000000..131222a
--- /dev/null
+++ b/security/snet/include/snet_utils.h
@@ -0,0 +1,9 @@
+#ifndef _SNET_UTILS_H
+#define _SNET_UTILS_H
+
+#include <linux/types.h>
+
+const char *snet_verdict_name(const enum snet_verdict cmd);
+const char *snet_syscall_name(const enum snet_syscall sys);
+
+#endif	/* _SNET_UTILS_H */
diff --git a/security/snet/snet_utils.c b/security/snet/snet_utils.c
new file mode 100644
index 0000000..6bfdcf6
--- /dev/null
+++ b/security/snet/snet_utils.c
@@ -0,0 +1,40 @@
+#include <linux/types.h>
+#include "snet_verdict.h"
+#include "snet_hooks.h"
+#include "snet_utils.h"
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
-- 
1.6.3.3

