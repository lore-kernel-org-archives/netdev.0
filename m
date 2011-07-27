From: frank.blaschka@de.ibm.com
Subject: [patch 02/11] [PATCH] iucv: kernel option for z/VM IUCV and HiperSockets
Date: Wed, 27 Jul 2011 18:12:44 +0200
Message-ID: <20110727161338.558890438@de.ibm.com>
References: <20110727161242.018577444@de.ibm.com>
Cc: Ursula Braun <ursula.braun@de.ibm.com>
To: netdev@vger.kernel.org, linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:60985 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726Ab1G0QNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2011 12:13:54 -0400
Content-Disposition: inline; filename=net1117-af_iucv-kernel-option-for-z-VM-IUCV-and-HiperSockets.patch
 transports
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

When adding HiperSockets transport to AF_IUCV Sockets, af_iucv either
depends on IUCV or QETH_L3 (or both). This patch introduces the
necessary changes for kernel configuration.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 net/iucv/Kconfig |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

--- a/net/iucv/Kconfig
+++ b/net/iucv/Kconfig
@@ -1,15 +1,15 @@
 config IUCV
-	tristate "IUCV support (S390 - z/VM only)"
-	depends on S390
+	def_tristate y if S390
+	prompt "IUCV support (S390 - z/VM only)"
 	help
 	  Select this option if you want to use inter-user communication
 	  under VM or VIF. If you run on z/VM, say "Y" to enable a fast
 	  communication link between VM guests.
 
 config AFIUCV
-	tristate "AF_IUCV support (S390 - z/VM only)"
-	depends on IUCV
+	def_tristate m if QETH_L3 || IUCV
+	prompt "AF_IUCV Socket support (S390 - z/VM and HiperSockets transport)"
 	help
-	  Select this option if you want to use inter-user communication under
-	  VM or VIF sockets. If you run on z/VM, say "Y" to enable a fast
-	  communication link between VM guests.
+	  Select this option if you want to use AF_IUCV socket applications
+	  based on z/VM inter-user communication vehicle or based on
+	  HiperSockets.

