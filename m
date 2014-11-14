From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next] openvswitch: Fix build failure.
Date: Thu, 13 Nov 2014 22:21:30 -0800
Message-ID: <1415946090-1504-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog107.obsmtp.com ([74.125.149.197]:42067 "HELO
	na3sys009aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752299AbaKNGVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 01:21:38 -0500
Received: by mail-pd0-f181.google.com with SMTP id y10so16135736pdj.40
        for <netdev@vger.kernel.org>; Thu, 13 Nov 2014 22:21:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dependency on INET to fix following build error. I have also
fixed MPLS dependency.

ERROR: "ip_route_output_flow" [net/openvswitch/openvswitch.ko]
undefined!
make[1]: *** [__modpost] Error 1

Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/Kconfig |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 454ce12..b7d818c 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -4,7 +4,9 @@
 
 config OPENVSWITCH
 	tristate "Open vSwitch"
+	depends on INET
 	select LIBCRC32C
+	select NET_MPLS_GSO
 	---help---
 	  Open vSwitch is a multilayer Ethernet switch targeted at virtualized
 	  environments.  In addition to supporting a variety of features
@@ -30,8 +32,6 @@ config OPENVSWITCH
 
 config OPENVSWITCH_GRE
 	tristate "Open vSwitch GRE tunneling support"
-	select NET_MPLS_GSO
-	depends on INET
 	depends on OPENVSWITCH
 	depends on NET_IPGRE_DEMUX
 	default OPENVSWITCH
@@ -45,7 +45,6 @@ config OPENVSWITCH_GRE
 
 config OPENVSWITCH_VXLAN
 	tristate "Open vSwitch VXLAN tunneling support"
-	depends on INET
 	depends on OPENVSWITCH
 	depends on VXLAN
 	default OPENVSWITCH
@@ -58,7 +57,6 @@ config OPENVSWITCH_VXLAN
 
 config OPENVSWITCH_GENEVE
 	tristate "Open vSwitch Geneve tunneling support"
-	depends on INET
 	depends on OPENVSWITCH
 	depends on GENEVE
 	default OPENVSWITCH
-- 
1.7.1
