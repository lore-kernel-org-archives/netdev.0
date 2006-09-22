From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: [PATCH] netdev config: revert part of previous patch
Date: Fri, 22 Sep 2006 12:56:25 -0700
Message-ID: <20060922125625.36a5c56b.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, akpm <akpm@osdl.org>, blaisorblade@yahoo.it,
	sam@ravnborg.org, jengelh@linux01.gwdg.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:32471 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S964848AbWIVTzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 15:55:21 -0400
Received: from midway.site ([71.117.233.155]) by xenotime.net for <netdev@vger.kernel.org>; Fri, 22 Sep 2006 12:55:14 -0700
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Net devices should depend on NETDEVICES, so revert part of
Paolo's previous patch.

See http://marc.theaimsgroup.com/?l=linux-kernel&m=115566326218740&w=2
for history.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/Kconfig |    5 +++++
 1 files changed, 5 insertions(+)

--- linux-2618-all.orig/drivers/net/Kconfig
+++ linux-2618-all/drivers/net/Kconfig
@@ -24,6 +24,9 @@ config NETDEVICES
 
 	  If unsure, say Y.
 
+# All the following symbols are dependent on NETDEVICES - do not repeat
+# that for each of the symbols.
+if NETDEVICES
 
 config IFB
 	tristate "Intermediate Functional Block support"
@@ -2799,6 +2802,8 @@ config NETCONSOLE
 	If you want to log kernel messages over the network, enable this.
 	See <file:Documentation/networking/netconsole.txt> for details.
 
+endif #NETDEVICES
+
 config NETPOLL
 	def_bool NETCONSOLE
 


---
