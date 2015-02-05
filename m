From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 14/29] net: vrf: Introduce vrf header file
Date: Wed,  4 Feb 2015 18:34:15 -0700
Message-ID: <1423100070-31848-15-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:49215 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965486AbbBEBgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:06 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so6775050iec.0
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:05 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defines for min and max vrf id and helpers for examining

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/net/vrf.h | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)
 create mode 100644 include/net/vrf.h

diff --git a/include/net/vrf.h b/include/net/vrf.h
new file mode 100644
index 000000000000..67bc2e465661
--- /dev/null
+++ b/include/net/vrf.h
@@ -0,0 +1,36 @@
+#ifndef _VRF_H_
+#define _VRF_H_
+
+#define VRF_BITS	12
+#define VRF_MIN		1
+#define VRF_MAX		((1 << VRF_BITS) - 1)
+#define VRF_MASK	VRF_MAX
+
+#define VRF_DEFAULT	1
+#define VRF_ANY		0xffff
+
+static inline
+int vrf_eq(__u32 vrf1, __u32 vrf2)
+{
+	return vrf1 == vrf2;
+}
+
+static inline
+int vrf_eq_or_any(__u32 vrf1, __u32 vrf2)
+{
+	return vrf1 == vrf2 || vrf1 == VRF_ANY || vrf2 == VRF_ANY;
+}
+
+static inline int vrf_is_valid(__u32 vrf)
+{
+	if ((vrf < VRF_MIN || vrf > VRF_MAX) && vrf != VRF_ANY)
+		return 0;
+
+	return 1;
+}
+
+static inline int vrf_is_any(__u32 vrf)
+{
+	return vrf == VRF_ANY;
+}
+#endif
-- 
1.9.3 (Apple Git-50)
