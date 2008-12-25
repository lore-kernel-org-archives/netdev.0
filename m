From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/8] sfc: Generate unique names for per-NIC workqueues
Date: Thu, 25 Dec 2008 03:37:47 +0000
Message-ID: <1230176267.3401.38.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:3903 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751481AbYLYDh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 22:37:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This time, we store the name in struct efx_nic.

Ben.

 drivers/net/sfc/efx.c        |    5 ++++-
 drivers/net/sfc/net_driver.h |    2 ++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 42934ba..46c2a8b 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1929,7 +1929,10 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	efx->interrupt_mode = max(efx->type->max_interrupt_mode,
 				  interrupt_mode);
 
-	efx->workqueue = create_singlethread_workqueue("sfc_work");
+	/* Would be good to use the net_dev name, but we're too early */
+	snprintf(efx->workqueue_name, sizeof(efx->workqueue_name), "sfc%s",
+		 pci_name(pci_dev));
+	efx->workqueue = create_singlethread_workqueue(efx->workqueue_name);
 	if (!efx->workqueue)
 		return -ENOMEM;
 
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 03feaee..b0c7975 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -700,6 +700,7 @@ union efx_multicast_hash {
  * @legacy_irq: IRQ number
  * @workqueue: Workqueue for port reconfigures and the HW monitor.
  *	Work items do not hold and must not acquire RTNL.
+ * @workqueue_name: Name of workqueue
  * @reset_work: Scheduled reset workitem
  * @monitor_work: Hardware monitor workitem
  * @membase_phys: Memory BAR value as physical address
@@ -781,6 +782,7 @@ struct efx_nic {
 	const struct efx_nic_type *type;
 	int legacy_irq;
 	struct workqueue_struct *workqueue;
+	char workqueue_name[16];
 	struct work_struct reset_work;
 	struct delayed_work monitor_work;
 	resource_size_t membase_phys;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
