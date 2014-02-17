From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [net-next v2 2/3] UAPI: add MPLS label stack definition
Date: Mon, 17 Feb 2014 17:56:12 +0100
Message-ID: <1392656174-14791-3-git-send-email-sw@simonwunderlich.de>
References: <1392656174-14791-1-git-send-email-sw@simonwunderlich.de>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de,
	Simon Wunderlich <sw@simonwunderlich.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55598 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbaBQQ4T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 11:56:19 -0500
In-Reply-To: <1392656174-14791-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Labels for the Multiprotocol Label Switching are defined in RFC 3032
which was superseded by RFC 5462. Add the definition to UAPI and a stub
header for include/linux.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
---
Changes to first version:

 * add stub mpls header in include/linux/mpls.h for users inside the
   kernel
---
 include/linux/mpls.h      |    6 ++++++
 include/uapi/linux/mpls.h |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 40 insertions(+)
 create mode 100644 include/linux/mpls.h
 create mode 100644 include/uapi/linux/mpls.h

diff --git a/include/linux/mpls.h b/include/linux/mpls.h
new file mode 100644
index 0000000..9999145
--- /dev/null
+++ b/include/linux/mpls.h
@@ -0,0 +1,6 @@
+#ifndef _LINUX_MPLS_H
+#define _LINUX_MPLS_H
+
+#include <uapi/linux/mpls.h>
+
+#endif  /* _LINUX_MPLS_H */
diff --git a/include/uapi/linux/mpls.h b/include/uapi/linux/mpls.h
new file mode 100644
index 0000000..15c8260
--- /dev/null
+++ b/include/uapi/linux/mpls.h
@@ -0,0 +1,34 @@
+#ifndef _UAPI_MPLS_H
+#define _UAPI_MPLS_H
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+
+/* Reference: RFC 5462, RFC 3032
+ *
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                Label                  | TC  |S|       TTL     |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ *	Label:  Label Value, 20 bits
+ *	TC:     Traffic Class field, 3 bits
+ *	S:      Bottom of Stack, 1 bit
+ *	TTL:    Time to Live, 8 bits
+ */
+
+struct mpls_label_stack {
+	__be32 entry;
+};
+
+#define MPLS_LS_LABEL_MASK      0xFFFFF000
+#define MPLS_LS_LABEL_SHIFT     12
+#define MPLS_LS_TC_MASK         0x00000E00
+#define MPLS_LS_TC_SHIFT        9
+#define MPLS_LS_S_MASK          0x00000100
+#define MPLS_LS_S_SHIFT         8
+#define MPLS_LS_TTL_MASK        0x000000FF
+#define MPLS_LS_TTL_SHIFT       0
+
+#endif /* _UAPI_MPLS_H */
-- 
1.7.10.4
