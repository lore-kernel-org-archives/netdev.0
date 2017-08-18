From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next 1/2] liquidio: move macro definition to a proper
 place
Date: Fri, 18 Aug 2017 11:35:17 -0700
Message-ID: <20170818183517.GA4513@felix-thinkpad.cavium.com>
References: <20170818183432.GA4487@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        veerasenareddy.burru@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0044.outbound.protection.outlook.com ([104.47.38.44]:51808
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750987AbdHRSfH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 14:35:07 -0400
Content-Disposition: inline
In-Reply-To: <20170818183432.GA4487@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro LIO_CMD_WAIT_TM is not specific to the PF driver; it can be used
by the VF driver too, so move its definition from a PF-specific header file
to one that's common to PF and VF.

Signed-off-by: Veerasenareddy Burru <veerasenareddy.burru@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h | 2 --
 drivers/net/ethernet/cavium/liquidio/liquidio_common.h  | 2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
index dee6046..2aba524 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn23xx_pf_device.h
@@ -24,8 +24,6 @@
 
 #include "cn23xx_pf_regs.h"
 
-#define LIO_CMD_WAIT_TM 100
-
 /* Register address and configuration for a CN23XX devices.
  * If device specific changes need to be made then add a struct to include
  * device specific fields as shown in the commented section
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 18d2955..a2274e6 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -238,6 +238,8 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 #define   OCTNET_CMD_VLAN_FILTER_ENABLE 0x1
 #define   OCTNET_CMD_VLAN_FILTER_DISABLE 0x0
 
+#define   LIO_CMD_WAIT_TM 100
+
 /* RX(packets coming from wire) Checksum verification flags */
 /* TCP/UDP csum */
 #define   CNNIC_L4SUM_VERIFIED             0x1
-- 
2.9.0
