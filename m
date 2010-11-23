From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] ethtool: Work around old <linux/types.h> without
 big-endian types
Date: Tue, 23 Nov 2010 17:15:17 +0000
Message-ID: <1290532517.6770.1603.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Gabor Z. Papp" <gzp@papp.hu>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:36978 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab0KWRP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 12:15:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an autoconf test for whether __be16 and __be32 are defined.
If not, define them in ethtool-util.h.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
__be16 and __be32 were not included in the userland version of
<linux/types.h> before Linux 2.6.10.

Ben.

 configure.ac   |    7 +++++++
 ethtool-util.h |    6 ++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index f2401a4..2e31e3a 100644
--- a/configure.ac
+++ b/configure.ac
@@ -17,6 +17,13 @@ dnl Checks for header files.
 AC_CHECK_HEADERS(sys/ioctl.h)
 
 dnl Checks for typedefs, structures, and compiler characteristics.
+AC_MSG_CHECKING([whether <linux/types.h> defines big-endian types])
+AC_TRY_COMPILE([#include <linux/types.h>],
+	       [__be16 foo;__be32 bar;],
+	       [AC_MSG_RESULT(yes)
+		AC_DEFINE([HAVE_BE_TYPES], [1],
+			  [Define to 1 if <linux/types.h> defines big-endian types])],
+	       [AC_MSG_RESULT(no)])
 
 dnl Checks for library functions.
 AC_HEADER_STDC
diff --git a/ethtool-util.h b/ethtool-util.h
index 4ef3a9f..f053028 100644
--- a/ethtool-util.h
+++ b/ethtool-util.h
@@ -6,6 +6,12 @@
 #include <sys/types.h>
 #include <endian.h>
 
+/* ethtool.h expects these to be defined by <linux/types.h> */
+#ifndef HAVE_BE_TYPES
+typedef __uint16_t __be16;
+typedef __uint32_t __be32;
+#endif
+
 #include "ethtool-copy.h"
 
 typedef unsigned long long u64;
-- 
1.5.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

