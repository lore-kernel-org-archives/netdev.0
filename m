From: Shyam Saini <mayhs11saini@gmail.com>
Subject: [PATCH] sfc: Replace memset with eth_zero_addr
Date: Mon, 16 Jan 2017 09:26:21 +0530
Message-ID: <1484538981-24591-1-git-send-email-mayhs11saini@gmail.com>
Cc: bkenward@solarflare.com, netdev@vger.kernel.org,
        linux-net-drivers@solarflare.com,
        Shyam Saini <mayhs11saini@gmail.com>
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36180 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751171AbdAPD4l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Jan 2017 22:56:41 -0500
Received: by mail-pg0-f65.google.com with SMTP id 75so4233562pgf.3
        for <netdev@vger.kernel.org>; Sun, 15 Jan 2017 19:56:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use eth_zero_addr to assign zero address to the given address array
instead of memset when the second argument in memset is address
of zero which makes the code clearer and also add header
file linux/etherdevice.h

Signed-off-by: Shyam Saini <mayhs11saini@gmail.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index a949b9d..228806c 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -6,6 +6,7 @@
  * under the terms of the GNU General Public License version 2 as published
  * by the Free Software Foundation, incorporated herein by reference.
  */
+#include <linux/etherdevice.h>
 #include <linux/pci.h>
 #include <linux/module.h>
 #include "net_driver.h"
@@ -554,7 +555,7 @@ int efx_ef10_sriov_set_vf_mac(struct efx_nic *efx, int vf_i, u8 *mac)
 	return 0;
 
 fail:
-	memset(vf->mac, 0, ETH_ALEN);
+	eth_zero_addr(vf->mac);
 	return rc;
 }
 
-- 
2.7.4
