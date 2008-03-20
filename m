From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [RFC PATCH] kernel: add byteorder macros with alignment fixups
Date: Thu, 20 Mar 2008 12:22:33 -0700
Message-ID: <1206040953.17059.13.camel@brick>
References: <1206034454.17059.4.camel@brick>
	 <20080320182911.GQ10722@ZenIV.linux.org.uk>
	 <1206038244.17059.7.camel@brick>
	 <20080320190953.GR10722@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.182]:44378 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753989AbYCTTWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 15:22:38 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1186057wah.23
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 12:22:38 -0700 (PDT)
In-Reply-To: <20080320190953.GR10722@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create linux/unaligned.h to hold a common pattern in the kernel:

le32_to_cpu(get_unaligned((__le32 *)x));

Repeat for various combinations of le/be and 64/32/16 bit.  Add
a variant that operates on possibly unaligned pointers to
byteorder/generic.h

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Now the indirect include of asm/unaligned is opt-in when places
add the linux/unaligned header.

 include/linux/unaligned.h |   42 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/include/linux/unaligned.h b/include/linux/unaligned.h
new file mode 100644
index 0000000..7d8fddc
--- /dev/null
+++ b/include/linux/unaligned.h
@@ -0,0 +1,42 @@
+#ifndef _LINUX_UNALIGNED_H_
+#define _LINUX_UNALIGNED_H_
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+#include <asm/unaligned.h>
+
+#ifdef __KERNEL__
+
+static inline u64 le64_to_cpu_unaligned(void *p)
+{
+	return __le64_to_cpu(get_unaligned((__le64 *)p));
+}
+
+static inline u32 le32_to_cpu_unaligned(void *p)
+{
+	return __le32_to_cpu(get_unaligned((__le32 *)p));
+}
+
+static inline u16 le16_to_cpu_unaligned(void *p)
+{
+	return __le16_to_cpu(get_unaligned((__le16 *)p));
+}
+
+static inline u64 be64_to_cpu_unaligned(void *p)
+{
+	return __be64_to_cpu(get_unaligned((__be64 *)p));
+}
+
+static inline u32 be32_to_cpu_unaligned(void *p)
+{
+	return __be32_to_cpu(get_unaligned((__be32 *)p));
+}
+
+static inline u16 be16_to_cpu_unaligned(void *p)
+{
+	return __be16_to_cpu(get_unaligned((__be16 *)p));
+}
+
+#endif /* KERNEL */
+
+#endif /* _LINUX_UNALIGNED_H */
-- 
1.5.4.4.684.g0e08



