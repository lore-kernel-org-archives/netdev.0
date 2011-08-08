From: frank.blaschka@de.ibm.com
Subject: [patch 04/13] [PATCH] iucv: kernel option for z/VM IUCV and HiperSockets
Date: Mon, 08 Aug 2011 13:33:50 +0200
Message-ID: <20110808113515.706509254@de.ibm.com>
References: <20110808113346.516293249@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.uk.ibm.com ([194.196.100.167]:33052 "EHLO
	mtagate7.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153Ab1HHLfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 07:35:31 -0400
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
 net/iucv/Kconfig |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

--- a/net/iucv/Kconfig
+++ b/net/iucv/Kconfig
@@ -1,15 +1,17 @@
 config IUCV
-	tristate "IUCV support (S390 - z/VM only)"
 	depends on S390
+	def_tristate y if S390
+	prompt "IUCV support (S390 - z/VM only)"
 	help
 	  Select this option if you want to use inter-user communication
 	  under VM or VIF. If you run on z/VM, say "Y" to enable a fast
 	  communication link between VM guests.
 
 config AFIUCV
-	tristate "AF_IUCV support (S390 - z/VM only)"
-	depends on IUCV
+	depends on S390
+	def_tristate m if QETH_L3 || IUCV
+	prompt "AF_IUCV Socket support (S390 - z/VM and HiperSockets transport)"
 	help
-	  Select this option if you want to use inter-user communication under
-	  VM or VIF sockets. If you run on z/VM, say "Y" to enable a fast
-	  communication link between VM guests.
+	  Select this option if you want to use AF_IUCV socket applications
+	  based on z/VM inter-user communication vehicle or based on
+	  HiperSockets.

