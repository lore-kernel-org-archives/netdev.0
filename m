From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 08/16] sfc: Use resource_size_t for PCI bus address
Date: Fri, 16 May 2008 21:17:06 +0100
Message-ID: <20080516201706.GA28241@solarflare.com>
References: <20080516201005.GS28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:53538 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758676AbYEPUR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 16:17:57 -0400
Content-Disposition: inline
In-Reply-To: <20080516201005.GS28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should make the driver work on 32-bit systems with 64-bit PCI support.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   11 ++++++-----
 drivers/net/sfc/net_driver.h |    2 +-
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 86d4029..f6131e5 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -778,15 +778,16 @@ static int efx_init_io(struct efx_nic *efx)
 	efx->membase = ioremap_nocache(efx->membase_phys,
 				       efx->type->mem_map_size);
 	if (!efx->membase) {
-		EFX_ERR(efx, "could not map memory BAR %d at %lx+%x\n",
-			efx->type->mem_bar, efx->membase_phys,
+		EFX_ERR(efx, "could not map memory BAR %d at %llx+%x\n",
+			efx->type->mem_bar,
+			(unsigned long long)efx->membase_phys,
 			efx->type->mem_map_size);
 		rc = -ENOMEM;
 		goto fail4;
 	}
-	EFX_LOG(efx, "memory BAR %u at %lx+%x (virtual %p)\n",
-		efx->type->mem_bar, efx->membase_phys, efx->type->mem_map_size,
-		efx->membase);
+	EFX_LOG(efx, "memory BAR %u at %llx+%x (virtual %p)\n",
+		efx->type->mem_bar, (unsigned long long)efx->membase_phys,
+		efx->type->mem_map_size, efx->membase);
 
 	return 0;
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 18b21ef..a84f975 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -686,7 +686,7 @@ struct efx_nic {
 	struct workqueue_struct *workqueue;
 	struct work_struct reset_work;
 	struct delayed_work monitor_work;
-	unsigned long membase_phys;
+	resource_size_t membase_phys;
 	void __iomem *membase;
 	spinlock_t biu_lock;
 	enum efx_int_mode interrupt_mode;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
