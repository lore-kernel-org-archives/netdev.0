From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net-next] mlxsw: spectrum: Add bridge dependency for spectrum
Date: Wed, 31 May 2017 21:33:42 +0300
Message-ID: <20170531183342.19349-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <jiri@mellanox.com>,
        <nikolay@cumulusnetworks.com>, <mlxsw@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Arnd Bergmann <arnd@arndb.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0056.outbound.protection.outlook.com ([104.47.0.56]:27072
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750999AbdEaSeL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 May 2017 14:34:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When BRIDGE is a loadable module, MLXSW_SPECTRUM mustn't be built-in:

drivers/built-in.o: In function `mlxsw_sp_bridge_device_create':
drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c:145: undefined reference to `br_vlan_enabled'
drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c:158: undefined reference to `br_multicast_enabled'
drivers/built-in.o: In function `mlxsw_sp_dev_rif_type':
drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:2972: undefined reference to `br_vlan_enabled'
drivers/built-in.o: In function `mlxsw_sp_inetaddr_vlan_event':
drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:3310: undefined reference to `br_vlan_enabled'

Add Kconfig dependency to enforce usable configurations.

Fixes: c57529e1d5d8 ("mlxsw: spectrum: Replace vPorts with Port-VLAN")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Tested-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index b9f80c2..695adff 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -74,6 +74,7 @@ config MLXSW_SPECTRUM
 	tristate "Mellanox Technologies Spectrum support"
 	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV && VLAN_8021Q
 	depends on PSAMPLE || PSAMPLE=n
+	depends on BRIDGE || BRIDGE=n
 	select PARMAN
 	select MLXFW
 	default m
-- 
2.9.4
