From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [net-next 2/3] UAPI: add MPLS label stack definition
Date: Wed, 12 Feb 2014 11:53:05 +0100
Message-ID: <1392202386-8826-3-git-send-email-sw@simonwunderlich.de>
References: <1392202386-8826-1-git-send-email-sw@simonwunderlich.de>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mathias.kretschmer-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org,
	Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1392202386-8826-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Labels for the Multiprotocol Label Switching are defined in RFC 3032
which was superseded by RFC 5462. Add the definition to UAPI.

Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Signed-off-by: Mathias Kretschmer <mathias.kretschmer-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org>
---
 include/uapi/linux/mpls.h |   34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)
 create mode 100644 include/uapi/linux/mpls.h

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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
