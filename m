From: Jan Engelhardt <jengelh@linux01.gwdg.de>
Subject: [PATCH 17/30] Use menuconfig objects - IPVS
Date: Tue, 10 Apr 2007 23:25:59 +0200 (MEST)
Message-ID: <Pine.LNX.4.61.0704102323370.32056@yvahk01.tjqt.qr>
References: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Neil Horman <nhorman@redhat.com>
To: Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>, Julian Anastasov <ja@ssi.bg>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753912AbXDJVaB@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.61.0704102046520.32056@yvahk01.tjqt.qr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Use menuconfigs instead of menus, so the whole menu can be disabled at        
once instead of going through all options.

Signed-off-by: Jan Engelhardt <jengelh@gmx.de>

Index: linux-2.6.21-rc5/net/ipv4/ipvs/Kconfig
===================================================================
--- linux-2.6.21-rc5.orig/net/ipv4/ipvs/Kconfig
+++ linux-2.6.21-rc5/net/ipv4/ipvs/Kconfig
@@ -1,10 +1,7 @@
 #
 # IP Virtual Server configuration
 #
-menu	"IP: Virtual Server Configuration"
-	depends on NETFILTER
-
-config	IP_VS
+menuconfig IP_VS
 	tristate "IP virtual server support (EXPERIMENTAL)"
 	depends on NETFILTER
 	---help---
@@ -25,9 +22,10 @@ config	IP_VS
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.
 
+if IP_VS
+
 config	IP_VS_DEBUG
 	bool "IP virtual server debugging"
-	depends on IP_VS
 	---help---
 	  Say Y here if you want to get additional messages useful in
 	  debugging the IP virtual server code. You can change the debug
@@ -35,7 +33,6 @@ config	IP_VS_DEBUG
 
 config	IP_VS_TAB_BITS
 	int "IPVS connection table size (the Nth power of 2)"
-	depends on IP_VS 
 	default "12" 
 	---help---
 	  The IPVS connection hash table uses the chaining scheme to handle
@@ -61,42 +58,35 @@ config	IP_VS_TAB_BITS
 	  needed for your box.
 
 comment "IPVS transport protocol load balancing support"
-        depends on IP_VS
 
 config	IP_VS_PROTO_TCP
 	bool "TCP load balancing support"
-	depends on IP_VS
 	---help---
 	  This option enables support for load balancing TCP transport
 	  protocol. Say Y if unsure.
 
 config	IP_VS_PROTO_UDP
 	bool "UDP load balancing support"
-	depends on IP_VS
 	---help---
 	  This option enables support for load balancing UDP transport
 	  protocol. Say Y if unsure.
 
 config	IP_VS_PROTO_ESP
 	bool "ESP load balancing support"
-	depends on IP_VS
 	---help---
 	  This option enables support for load balancing ESP (Encapsulation
 	  Security Payload) transport protocol. Say Y if unsure.
 
 config	IP_VS_PROTO_AH
 	bool "AH load balancing support"
-	depends on IP_VS
 	---help---
 	  This option enables support for load balancing AH (Authentication
 	  Header) transport protocol. Say Y if unsure.
 
 comment "IPVS scheduler"
-        depends on IP_VS
 
 config	IP_VS_RR
 	tristate "round-robin scheduling"
-	depends on IP_VS
 	---help---
 	  The robin-robin scheduling algorithm simply directs network
 	  connections to different real servers in a round-robin manner.
@@ -106,7 +96,6 @@ config	IP_VS_RR
  
 config	IP_VS_WRR
         tristate "weighted round-robin scheduling" 
-	depends on IP_VS
 	---help---
 	  The weighted robin-robin scheduling algorithm directs network
 	  connections to different real servers based on server weights
@@ -120,7 +109,6 @@ config	IP_VS_WRR
 
 config	IP_VS_LC
         tristate "least-connection scheduling"
-        depends on IP_VS
 	---help---
 	  The least-connection scheduling algorithm directs network
 	  connections to the server with the least number of active 
@@ -131,7 +119,6 @@ config	IP_VS_LC
 
 config	IP_VS_WLC
         tristate "weighted least-connection scheduling"
-        depends on IP_VS
 	---help---
 	  The weighted least-connection scheduling algorithm directs network
 	  connections to the server with the least active connections
@@ -142,7 +129,6 @@ config	IP_VS_WLC
 
 config	IP_VS_LBLC
 	tristate "locality-based least-connection scheduling"
-        depends on IP_VS
 	---help---
 	  The locality-based least-connection scheduling algorithm is for
 	  destination IP load balancing. It is usually used in cache cluster.
@@ -157,7 +143,6 @@ config	IP_VS_LBLC
 
 config  IP_VS_LBLCR
 	tristate "locality-based least-connection with replication scheduling"
-        depends on IP_VS
 	---help---
 	  The locality-based least-connection with replication scheduling
 	  algorithm is also for destination IP load balancing. It is 
@@ -176,7 +161,6 @@ config  IP_VS_LBLCR
 
 config	IP_VS_DH
 	tristate "destination hashing scheduling"
-        depends on IP_VS
 	---help---
 	  The destination hashing scheduling algorithm assigns network
 	  connections to the servers through looking up a statically assigned
@@ -187,7 +171,6 @@ config	IP_VS_DH
 
 config	IP_VS_SH
 	tristate "source hashing scheduling"
-        depends on IP_VS
 	---help---
 	  The source hashing scheduling algorithm assigns network
 	  connections to the servers through looking up a statically assigned
@@ -198,7 +181,6 @@ config	IP_VS_SH
 
 config	IP_VS_SED
 	tristate "shortest expected delay scheduling"
-        depends on IP_VS
 	---help---
 	  The shortest expected delay scheduling algorithm assigns network
 	  connections to the server with the shortest expected delay. The 
@@ -212,7 +194,6 @@ config	IP_VS_SED
 
 config	IP_VS_NQ
 	tristate "never queue scheduling"
-        depends on IP_VS
 	---help---
 	  The never queue scheduling algorithm adopts a two-speed model.
 	  When there is an idle server available, the job will be sent to
@@ -225,11 +206,10 @@ config	IP_VS_NQ
 	  module, choose M here. If unsure, say N.
 
 comment 'IPVS application helper'
-	depends on IP_VS
 
 config	IP_VS_FTP
   	tristate "FTP protocol helper"
-        depends on IP_VS && IP_VS_PROTO_TCP
+        depends on IP_VS_PROTO_TCP
 	---help---
 	  FTP is a protocol that transfers IP address and/or port number in
 	  the payload. In the virtual server via Network Address Translation,
@@ -241,4 +221,4 @@ config	IP_VS_FTP
 	  If you want to compile it in kernel, say Y. To compile it as a
 	  module, choose M here. If unsure, say N.
 
-endmenu
+endif # IP_VS
#<EOF>
