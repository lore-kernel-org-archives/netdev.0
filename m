From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 5/7] enic: Clean up: remove enic_dev_stats_clear
Date: Tue, 10 Aug 2010 21:55:15 -0700
Message-ID: <20100811045515.3877.68840.stgit@savbu-pc100.cisco.com>
References: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:13281 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752018Ab0HKEzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 00:55:16 -0400
In-Reply-To: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

Remove function enic_dev_stats_clear and its reference in enic device
init code. Firmware clears device stats on device open. So, no need for
the driver to do it again.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
---
 drivers/net/enic/enic_main.c |   15 ---------------
 1 files changed, 0 insertions(+), 15 deletions(-)


diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 07aa033..d08f362 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -2167,17 +2167,6 @@ void enic_dev_deinit(struct enic *enic)
 	enic_clear_intr_mode(enic);
 }
 
-static int enic_dev_stats_clear(struct enic *enic)
-{
-	int err;
-
-	spin_lock(&enic->devcmd_lock);
-	err = vnic_dev_stats_clear(enic->vdev);
-	spin_unlock(&enic->devcmd_lock);
-
-	return err;
-}
-
 int enic_dev_init(struct enic *enic)
 {
 	struct device *dev = enic_get_dev(enic);
@@ -2220,10 +2209,6 @@ int enic_dev_init(struct enic *enic)
 
 	enic_init_vnic_resources(enic);
 
-	/* Clear LIF stats
-	 */
-	enic_dev_stats_clear(enic);
-
 	err = enic_set_rq_alloc_buf(enic);
 	if (err) {
 		dev_err(dev, "Failed to set RQ buffer allocator, aborting\n");

