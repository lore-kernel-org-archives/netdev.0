From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] openvswitch: fix compilation when vxlan is a module
Date: Thu, 23 Jul 2015 11:29:07 +0200
Message-ID: <1437643747-22976-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, pshelar@nicira.com, dev@openvswitch.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Thomas Graf <tgraf@suug.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:48916 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295AbbGWJ3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2015 05:29:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With CONFIG_VXLAN=m and CONFIG_OPENVSWITCH=y, there was the following
compilation error:
  LD      init/built-in.o
  net/built-in.o: In function `vxlan_tnl_create':
  .../net/openvswitch/vport-netdev.c:322: undefined reference to `vxlan_dev_create'
  make: *** [vmlinux] Error 1

CC: Thomas Graf <tgraf@suug.ch>
Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device")
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/openvswitch/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/Kconfig b/net/openvswitch/Kconfig
index 1119f46b80b4..6ed1d2da9fcd 100644
--- a/net/openvswitch/Kconfig
+++ b/net/openvswitch/Kconfig
@@ -5,6 +5,7 @@
 config OPENVSWITCH
 	tristate "Open vSwitch"
 	depends on INET
+	depends on VXLAN
 	select LIBCRC32C
 	select MPLS
 	select NET_MPLS_GSO
-- 
2.4.2
