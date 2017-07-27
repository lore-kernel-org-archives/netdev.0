From: Sathya Perla <sathya.perla@broadcom.com>
Subject: [PATCH net-next] bnxt_re: add MAY_USE_DEVLINK dependency
Date: Thu, 27 Jul 2017 06:29:51 -0400
Message-ID: <20170727102951.26964-1-sathya.perla@broadcom.com>
Cc: selvin.xavier@broadcom.com, devesh.sharma@broadcom.com,
        arnd@arndb.de, michael.chan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp02.broadcom.com ([192.19.232.149]:43102 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750997AbdG0K36 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 06:29:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnxt_en depends on MAY_USE_DEVLINK; this is used to force bnxt_en
to be =m when DEVLINK is =m.

Now, bnxt_re selects bnxt_en. Unless bnxt_re also explicitly calls
out dependency on MAY_USE_DEVLINK, Kconfig does not force bnxt_re
to be =m when DEVLINK is =m, causing the following error:

drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.o: In function
`bnxt_dl_register':
bnxt_vfr.c:(.text+0x1440): undefined reference to `devlink_alloc'
bnxt_vfr.c:(.text+0x14c0): undefined reference to `devlink_register'
bnxt_vfr.c:(.text+0x14e0): undefined reference to `devlink_free'
drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.o: In function
`bnxt_dl_unregister':
bnxt_vfr.c:(.text+0x1534): undefined reference to `devlink_unregister'
bnxt_vfr.c:(.text+0x153c): undefined reference to `devlink_free'

Fix this by adding MAY_USE_DEVLINK dependency in bnxt_re.

Fixes: 4ab0c6a8ffd7 ("bnxt_en: add support to enable VF-representors")
Suggested-by: Arnd Bergmann <arnd@arndb.de>
Signed-off-by: Sathya Perla <sathya.perla@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/hw/bnxt_re/Kconfig b/drivers/infiniband/hw/bnxt_re/Kconfig
index 19982a4..18f5ed0 100644
--- a/drivers/infiniband/hw/bnxt_re/Kconfig
+++ b/drivers/infiniband/hw/bnxt_re/Kconfig
@@ -1,6 +1,7 @@
 config INFINIBAND_BNXT_RE
     tristate "Broadcom Netxtreme HCA support"
     depends on ETHERNET && NETDEVICES && PCI && INET && DCB
+    depends on MAY_USE_DEVLINK
     select NET_VENDOR_BROADCOM
     select BNXT
     ---help---
-- 
1.8.3.1
