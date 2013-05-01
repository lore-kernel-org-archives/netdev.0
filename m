From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH] netlink: kconfig: move mmap i/o into netlink kconfig
Date: Wed,  1 May 2013 13:37:20 +0200
Message-ID: <1367408240-30320-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63878 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756263Ab3EALhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 07:37:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, in menuconfig, Netlink's new mmaped IO is the very first
entry under the ``Networking support'' item and comes even before
``Networking options'':

  [ ]   Netlink: mmaped IO
  Networking options  --->
  ...

Lets move this into ``Networking options'' under netlink's Kconfig,
since this might be more appropriate. Introduced by commit ccdfcc398
(``netlink: mmaped netlink: ring setup'').

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/Kconfig         | 9 ---------
 net/netlink/Kconfig | 9 +++++++++
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index 1a22216..2ddc904 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -23,15 +23,6 @@ menuconfig NET
 
 if NET
 
-config NETLINK_MMAP
-	bool "Netlink: mmaped IO"
-	help
-	  This option enables support for memory mapped netlink IO. This
-	  reduces overhead by avoiding copying data between kernel- and
-	  userspace.
-
-	  If unsure, say N.
-
 config WANT_COMPAT_NETLINK_MESSAGES
 	bool
 	help
diff --git a/net/netlink/Kconfig b/net/netlink/Kconfig
index 5d6e8c0..2c5e95e 100644
--- a/net/netlink/Kconfig
+++ b/net/netlink/Kconfig
@@ -2,6 +2,15 @@
 # Netlink Sockets
 #
 
+config NETLINK_MMAP
+	bool "NETLINK: mmaped IO"
+	---help---
+	  This option enables support for memory mapped netlink IO. This
+	  reduces overhead by avoiding copying data between kernel- and
+	  userspace.
+
+	  If unsure, say N.
+
 config NETLINK_DIAG
 	tristate "NETLINK: socket monitoring interface"
 	default n
-- 
1.7.11.7
