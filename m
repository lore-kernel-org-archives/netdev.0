From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] mlxsw: switchib:  add MLXSW_PCI dependency
Date: Fri, 18 Nov 2016 17:01:14 +0100
Message-ID: <20161118160127.473555-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Ivan Vecera <ivecera@redhat.com>,
        Elad Raz <eladr@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.75]:56273 "EHLO
        mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751799AbcKRQBj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 11:01:39 -0500
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

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/mellanox/mlxsw/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/Kconfig b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
index bac2e5e826e2..49237a24605e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlxsw/Kconfig
@@ -31,7 +31,7 @@ config MLXSW_PCI
 
 config MLXSW_SWITCHIB
 	tristate "Mellanox Technologies SwitchIB and SwitchIB-2 support"
-	depends on MLXSW_CORE && NET_SWITCHDEV
+	depends on MLXSW_CORE && MLXSW_PCI && NET_SWITCHDEV
 	default m
 	---help---
 	  This driver supports Mellanox Technologies SwitchIB and SwitchIB-2
-- 
2.9.0
