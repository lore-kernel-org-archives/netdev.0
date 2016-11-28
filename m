From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net-next v2] mlxsw: switchib: add MLXSW_PCI dependency
Date: Mon, 28 Nov 2016 15:26:04 +0100
Message-ID: <20161128142622.2758614-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Jiri Pirko <jiri@mellanox.com>,
        Ido Schimmel <idosch@mellanox.com>,
        Vadim Pasternak <vadimp@mellanox.com>,
        Ivan Vecera <cera@cera.cz>, Elad Raz <eladr@mellanox.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.133]:53267 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932626AbcK1O0e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 09:26:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The newly added switchib driver fails to link if MLXSW_PCI=m:

drivers/net/ethernet/mellanox/mlxsw/mlxsw_switchib.o: In function^Cmlxsw_sib_module_exit':
switchib.c:(.exit.text+0x8): undefined reference to `mlxsw_pci_driver_unregister'
switchib.c:(.exit.text+0x10): undefined reference to `mlxsw_pci_driver_unregister'
drivers/net/ethernet/mellanox/mlxsw/mlxsw_switchib.o: In function `mlxsw_sib_module_init':
switchib.c:(.init.text+0x28): undefined reference to `mlxsw_pci_driver_register'
switchib.c:(.init.text+0x38): undefined reference to `mlxsw_pci_driver_register'
switchib.c:(.init.text+0x48): undefined reference to `mlxsw_pci_driver_unregister'

The other two such sub-drivers have a dependency, so add the same one
here. In theory we could allow this driver if MLXSW_PCI is disabled,
but it's probably not worth it.

Fixes: d1ba52638456 ("mlxsw: switchib: Introduce SwitchIB and SwitchIB silicon driver")
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
v2: add Fixes tag

 drivers/net/ethernet/mellanox/mlxsw/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index 95ae4c0d3a18..16f44b9aa076 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -50,7 +50,7 @@ config MLXSW_I2C
 
 config MLXSW_SWITCHIB
 	tristate "Mellanox Technologies SwitchIB and SwitchIB-2 support"
-	depends on MLXSW_CORE && NET_SWITCHDEV
+	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV
 	default m
 	---help---
 	  This driver supports Mellanox Technologies SwitchIB and SwitchIB-2
-- 
2.9.0
