From: Stephen Hemminger <shemminger@osdl.org>
Subject: iperf 1.7.0 thread bug.
Date: Tue, 05 Oct 2004 11:41:18 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1097001678.22947.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-zFU1N+103e8NII/wdZk7"
Cc: iperf-users@dast.nlanr.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dast@nlanr.net
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-zFU1N+103e8NII/wdZk7
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The iperf 1.7.0 hangs on AMD64, after several false starts the problem
turned out to be that the Thread wrapper was incorrectly assumuing that
pthread wasn't present (in Speaker.cpp), so some data sizes get messed
up. Bedlam ensuses.

This fixes it.


--=-zFU1N+103e8NII/wdZk7
Content-Description: 
Content-Disposition: attachment; filename=iperf-1.7.0.patch
Content-Type: text/x-patch; charset=us-ascii
Content-Transfer-Encoding: 7bit

--- lib/Thread.hpp.orig	2004-10-05 11:33:14.638098735 -0700
+++ lib/Thread.hpp	2004-10-05 11:34:30.160583668 -0700
@@ -56,7 +56,9 @@
 #ifndef THREAD_H
 #define THREAD_H
 
-
+#ifdef HAVE_CONFIG_H
+    #include "config.h"
+#endif
 
 #if   defined( HAVE_POSIX_THREAD )
 

--=-zFU1N+103e8NII/wdZk7--
