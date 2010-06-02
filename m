From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc: Store port number in net_device::dev_id
Date: Wed, 02 Jun 2010 21:39:56 +0100
Message-ID: <1275511200.2115.23.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:4089 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758661Ab0FBUkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 16:40:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This exposes the port number to userland through sysfs.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Following on from the earlier discussion of dev_id, here's the necessary
change for sfc.  This depends on commit dd8f61d "sfc: Get port number
from CS_PORT_NUM, not PCI function number".  Please consider including
both of these in net-2.6.

Ben.

 drivers/net/sfc/net_driver.h |    4 +---
 drivers/net/sfc/siena.c      |    2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 6b2e440..a8783b4 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -649,7 +649,6 @@ union efx_multicast_hash {
  * struct efx_nic - an Efx NIC
  * @name: Device name (net device name or bus id before net device registered)
  * @pci_dev: The PCI device
- * @port_num: Index of this host port within the controller
  * @type: Controller type attributes
  * @legacy_irq: IRQ number
  * @workqueue: Workqueue for port reconfigures and the HW monitor.
@@ -733,7 +732,6 @@ union efx_multicast_hash {
 struct efx_nic {
 	char name[IFNAMSIZ];
 	struct pci_dev *pci_dev;
-	unsigned port_num;
 	const struct efx_nic_type *type;
 	int legacy_irq;
 	struct workqueue_struct *workqueue;
@@ -836,7 +834,7 @@ static inline const char *efx_dev_name(struct efx_nic *efx)
 
 static inline unsigned int efx_port_num(struct efx_nic *efx)
 {
-	return efx->port_num;
+	return efx->net_dev->dev_id;
 }
 
 /**
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 7ecd255..f2b1e61 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -222,7 +222,7 @@ static int siena_probe_nic(struct efx_nic *efx)
 	}
 
 	efx_reado(efx, &reg, FR_AZ_CS_DEBUG);
-	efx->port_num = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
+	efx->net_dev->dev_id = EFX_OWORD_FIELD(reg, FRF_CZ_CS_PORT_NUM) - 1;
 
 	efx_mcdi_init(efx);
 
-- 
1.6.2.5

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

