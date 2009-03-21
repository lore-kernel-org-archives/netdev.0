From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 77/77] netdev: expose net_device_ops compat as config option
Date: Fri, 20 Mar 2009 22:36:44 -0700
Message-ID: <20090321053718.453648503@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36734 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760858AbZCUFs1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:27 -0400
Content-Disposition: inline; filename=net-compat-config.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that most network device drivers in (all but one in x86_64 allmodconfig)
support net_device_ops. Expose it as a configuration parameter. Still
need to address even older 32 bit drivers, and other arch before
compatiablity can be scheduled for removal in some future release.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/Kconfig |    9 +++++++++
 net/Kconfig         |    3 ---
 2 files changed, 9 insertions(+), 3 deletions(-)

--- a/drivers/net/Kconfig	2009-03-20 12:36:10.802902100 -0700
+++ b/drivers/net/Kconfig	2009-03-20 12:43:55.464652333 -0700
@@ -26,6 +26,15 @@ menuconfig NETDEVICES
 # that for each of the symbols.
 if NETDEVICES
 
+config COMPAT_NET_DEV_OPS
+       default y
+       bool "Enable older network device API compatiablity"
+       ---help---
+          This option enables kernel compatiability with older network devices
+          that do not use net_device_ops interface.
+
+	  If unsure, say Y.
+
 config IFB
 	tristate "Intermediate Functional Block support"
 	depends on NET_CLS_ACT
--- a/net/Kconfig	2009-03-20 12:35:21.319088970 -0700
+++ b/net/Kconfig	2009-03-20 12:43:03.535841778 -0700
@@ -24,9 +24,6 @@ if NET
 
 menu "Networking options"
 
-config COMPAT_NET_DEV_OPS
-       def_bool y
-
 source "net/packet/Kconfig"
 source "net/unix/Kconfig"
 source "net/xfrm/Kconfig"

-- 

