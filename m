From: y@vger.kernel.org
Subject: [RFC v4 09/11] snet: introduce snet_utils
Date: Thu,  5 May 2011 15:59:19 +0200
Message-ID: <18884.6271172681$1304604583@news.gmane.org>
References: <1304603961-2517-1-git-send-email-y>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1304603961-2517-1-git-send-email-y>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samir Bellabes <sam@synack.fr>

This patch provides helper functions for other subsystems

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/snet_utils.c |   39 +++++++++++++++++++++++++++++++++++++++
 security/snet/snet_utils.h |    9 +++++++++
 2 files changed, 48 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/snet_utils.c
 create mode 100644 security/snet/snet_utils.h

diff --git a/security/snet/snet_utils.c b/security/snet/snet_utils.c
new file mode 100644
index 0000000..4e80263
--- /dev/null
+++ b/security/snet/snet_utils.c
@@ -0,0 +1,39 @@
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
+		[SNET_VERDICT_INVALID]	= "Invalid",
+	};
+
+	if (cmd >= SNET_NR_VERDICT_TYPES)
+		return "ERROR";
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
+		return "ERROR";
+	else
+		return syscall_name[sys];
+}
diff --git a/security/snet/snet_utils.h b/security/snet/snet_utils.h
new file mode 100644
index 0000000..01e515f
--- /dev/null
+++ b/security/snet/snet_utils.h
@@ -0,0 +1,9 @@
+#ifndef _SNET_UTILS_H
+#define _SNET_UTILS_H
+
+#include <linux/skbuff.h>
+
+const char *snet_verdict_name(const enum snet_verdict cmd);
+const char *snet_syscall_name(const enum snet_syscall sys);
+
+#endif	/* _SNET_UTILS_H */
-- 
1.7.4.1

