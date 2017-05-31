From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next] nfp: add MAY_USE_DEVLINK dependency
Date: Wed, 31 May 2017 10:16:50 +0200
Message-ID: <20170531081700.1948289-1-arnd@arndb.de>
Cc: Simon Horman <simon.horman@netronome.com>,
        Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>, oss-drivers@netronome.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:60311 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751412AbdEaIRY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 04:17:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When devlink is configured as a loadable module, a built-in nfp driver
causes a link error:

drivers/net/built-in.o: In function `nfp_devlink_port_register':
(.text+0xb8b05): undefined reference to `devlink_port_type_eth_set'
drivers/net/built-in.o: In function `nfp_devlink_port_register':
(.text+0xb8b16): undefined reference to `devlink_port_split_set'

This adds a special Kconfig dependency on CONFIG_MAY_USE_DEVLINK
to avoid that combination and force nfp to be a module when NET_DEVLINK=m.

Fixes: 1851f93fd2ee ("nfp: add devlink support")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/netronome/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/netronome/Kconfig b/drivers/net/ethernet/netronome/Kconfig
index 967d7ca8c28c..0d5a7b9203a4 100644
--- a/drivers/net/ethernet/netronome/Kconfig
+++ b/drivers/net/ethernet/netronome/Kconfig
@@ -19,6 +19,7 @@ config NFP
 	tristate "Netronome(R) NFP4000/NFP6000 NIC driver"
 	depends on PCI && PCI_MSI
 	depends on VXLAN || VXLAN=n
+	depends on MAY_USE_DEVLINK
 	---help---
 	  This driver supports the Netronome(R) NFP4000/NFP6000 based
 	  cards working as a advanced Ethernet NIC.  It works with both
-- 
2.9.0
