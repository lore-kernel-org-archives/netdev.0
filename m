From: Andrey Mazo <mazo@telum.ru>
Subject: [PATCH 4/4] bridge-utils: Pretty print configure help
Date: Mon, 24 Feb 2014 14:56:46 +0400
Message-ID: <1393239406-8504-5-git-send-email-mazo@telum.ru>
References: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Cc: Andrey Mazo <mazo@telum.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.telum.ru ([62.141.76.179]:50889 "EHLO mail.telum.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595AbaBXLCe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 06:02:34 -0500
In-Reply-To: <1393239406-8504-1-git-send-email-mazo@telum.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use special AS_HELP_STRING() macro to correctly format configure --help
output.

Before the change:
"""
Optional Packages:
  --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
  --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
  --with-linux-headers     Location of the linux headers to use
"""

After the change:
"""
Optional Packages:
  --with-PACKAGE[=ARG]    use PACKAGE [ARG=yes]
  --without-PACKAGE       do not use PACKAGE (same as --with-PACKAGE=no)
  --with-linux-headers    location of the linux headers to use
"""

Signed-off-by: Andrey Mazo <mazo@telum.ru>
---
 configure.ac | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 096f017..6b24e9e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -2,8 +2,11 @@ dnl Process this file with autoconf to produce a configure script.
 AC_INIT([bridge-utils],[1.5])
 AC_CONFIG_HEADERS(libbridge/config.h)
 
-AC_ARG_WITH( linux-headers, [  --with-linux-headers     Location of the linux headers to use], 
-    KERNEL_HEADERS=$withval, KERNEL_HEADERS="/usr/src/linux/include")
+AC_ARG_WITH([linux-headers],
+    [AS_HELP_STRING([--with-linux-headers], [location of the linux headers to use])],
+    [KERNEL_HEADERS=$withval],
+    [KERNEL_HEADERS="/usr/src/linux/include"]
+)
 
 dnl Checks for programs.
 AC_PROG_CC
-- 
1.8.4.5
