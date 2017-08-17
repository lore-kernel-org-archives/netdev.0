From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: remove support for deprecated f/w cmd
 OCTNET_CMD_RESET_PF
Date: Wed, 16 Aug 2017 18:30:13 -0700
Message-ID: <20170817013013.GA3149@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0076.outbound.protection.outlook.com ([104.47.33.76]:50771
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751798AbdHQBaK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 21:30:10 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Farrington <ricardo.farrington@cavium.com>

Signed-off-by: Rick Farrington <ricardo.farrington@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c        | 9 ---------
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h | 1 -
 2 files changed, 10 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 0eea6a2..db85f8f 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1409,15 +1409,6 @@ static void liquidio_destroy_nic_device(struct octeon_device *oct, int ifidx)
 	if (atomic_read(&lio->ifstate) & LIO_IFSTATE_RUNNING)
 		liquidio_stop(netdev);
 
-	if (fw_type_is_none()) {
-		struct octnic_ctrl_pkt nctrl;
-
-		memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
-		nctrl.ncmd.s.cmd = OCTNET_CMD_RESET_PF;
-		nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
-		octnet_send_nic_ctrl_pkt(oct, &nctrl);
-	}
-
 	if (oct->props[lio->ifidx].napi_enabled == 1) {
 		list_for_each_entry_safe(napi, n, &netdev->napi_list, dev_list)
 			napi_disable(napi);
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 18d2955..906e30a 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -189,7 +189,6 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 #define   OCTNET_CMD_Q                0
 
 /* NIC Command types */
-#define   OCTNET_CMD_RESET_PF         0x0
 #define   OCTNET_CMD_CHANGE_MTU       0x1
 #define   OCTNET_CMD_CHANGE_MACADDR   0x2
 #define   OCTNET_CMD_CHANGE_DEVFLAGS  0x3
