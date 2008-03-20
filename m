From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [RFC PATCH] kernel: add byteorder macros with alignment fixups
Date: Thu, 20 Mar 2008 10:34:14 -0700
Message-ID: <1206034454.17059.4.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.176]:51162 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755217AbYCTReT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 13:34:19 -0400
Received: by el-out-1112.google.com with SMTP id v27so788532ele.17
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 10:34:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A common pattern in the kernel (especially networking) is:

le32_to_cpu(get_unaligned((__le32 *)x));

Repeat for various combinations of le/be and 64/32/16 bit.  Add
a variant that operates on possibly unaligned pointers to
byteorder/generic.h

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 include/linux/byteorder/generic.h |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/include/linux/byteorder/generic.h b/include/linux/byteorder/generic.h
index d377155..9b1a7a4 100644
--- a/include/linux/byteorder/generic.h
+++ b/include/linux/byteorder/generic.h
@@ -73,6 +73,10 @@
  *	cpu_to_[bl]eXXp(__uXX x)
  *	[bl]eXX_to_cpup(__uXX x)
  *
+ * The same, but takes a possibly unaligned pointer to the value to convert
+ *	cpu_to_[bl]eXXp_un(__uXX x)
+ *	[bl]eXX_to_cpup_un(__uXX x)
+ *
  * The same, but change in situ
  *	cpu_to_[bl]eXXs(__uXX x)
  *	[bl]eXX_to_cpus(__uXX x)
@@ -84,6 +88,8 @@
 
 
 #if defined(__KERNEL__)
+#include <asm/unaligned.h>
+
 /*
  * inside the kernel, we can use nicknames;
  * outside of it, we must avoid POSIX namespace pollution...
@@ -126,6 +132,16 @@
 #define be16_to_cpus __be16_to_cpus
 
 /*
+ * Operates on possibly unaligned pointers
+ */
+#define le64_to_cpup_un(x) __le64_to_cpu(get_unaligned((__le64 *)(x)))
+#define le32_to_cpup_un(x) __le32_to_cpu(get_unaligned((__le32 *)(x)))
+#define le16_to_cpup_un(x) __le16_to_cpu(get_unaligned((__le16 *)(x)))
+#define be64_to_cpup_un(x) __be64_to_cpu(get_unaligned((__be64 *)(x)))
+#define be32_to_cpup_un(x) __be32_to_cpu(get_unaligned((__be32 *)(x)))
+#define be16_to_cpup_un(x) __be16_to_cpu(get_unaligned((__be16 *)(x)))
+
+/*
  * They have to be macros in order to do the constant folding
  * correctly - if the argument passed into a inline function
  * it is no longer constant according to gcc..
-- 
1.5.4.4.684.g0e08



