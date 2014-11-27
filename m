From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next] ipvlan: ipvlan depends on INET and IPV6
Date: Wed, 26 Nov 2014 21:13:45 -0800
Message-ID: <1417065225-784-1-git-send-email-maheshb@google.com>
Cc: David Miller <davem@davemloft.net>,
	Jim Davis <jim.epost@gmail.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:42795 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476AbaK0FNt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 00:13:49 -0500
Received: by mail-ob0-f202.google.com with SMTP id va2so470583obc.1
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 21:13:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver uses ip_out_local() and ip6_route_output() which are
defined only if CONFIG_INET and CONFIG_IPV6 are enabled respectively.

Reported-by: Jim Davis <jim.epost@gmail.com>
Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/Kconfig         | 2 ++
 drivers/net/ipvlan/ipvlan.h | 3 ++-
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index b6d64f546574..d6607ee9c855 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -148,6 +148,8 @@ config MACVTAP
 
 config IPVLAN
     tristate "IP-VLAN support"
+    depends on INET
+    depends on IPV6
     ---help---
       This allows one to create virtual devices off of a main interface
       and packets will be delivered based on the dest L3 (IPv6/IPv4 addr)
diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index ab3e7614ed71..c44d29eca6c0 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -23,8 +23,9 @@
 #include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/inetdevice.h>
+#include <net/ip.h>
+#include <net/ip6_route.h>
 #include <net/rtnetlink.h>
-#include <net/gre.h>
 #include <net/route.h>
 #include <net/addrconf.h>
 
-- 
2.2.0.rc0.207.ga3a616c
