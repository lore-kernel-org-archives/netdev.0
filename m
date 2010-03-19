From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next PATCH 2/5] enic: Bug Fix: Fix timeout for hardware Tx and
	Rx queue disable operations
Date: Thu, 18 Mar 2010 19:19:49 -0700
Message-ID: <20100319021949.10527.32170.stgit@savbu-pc100.cisco.com>
References: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-4.cisco.com ([171.68.10.86]:7166 "EHLO
	sj-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951Ab0CSCTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 22:19:49 -0400
In-Reply-To: <20100319021901.10527.9869.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

The timeout for hardware Tx and Rx queue disable operations is increased to
work-around an erratum for "unnamed" chipset where a DMA completion may take 
upto 10ms. We have to wait atleast this long for hardware to signal that Tx 
and Rx queues are quiesced.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/vnic_rq.c |    4 ++--
 drivers/net/enic/vnic_wq.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/enic/vnic_rq.c b/drivers/net/enic/vnic_rq.c
index 7558397..7bcd903 100644
--- a/drivers/net/enic/vnic_rq.c
+++ b/drivers/net/enic/vnic_rq.c
@@ -167,10 +167,10 @@ int vnic_rq_disable(struct vnic_rq *rq)
 	iowrite32(0, &rq->ctrl->enable);
 
 	/* Wait for HW to ACK disable request */
-	for (wait = 0; wait < 100; wait++) {
+	for (wait = 0; wait < 1000; wait++) {
 		if (!(ioread32(&rq->ctrl->running)))
 			return 0;
-		udelay(1);
+		udelay(10);
 	}
 
 	printk(KERN_ERR "Failed to disable RQ[%d]\n", rq->index);
diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/enic/vnic_wq.c
index d2e00e5..44fc323 100644
--- a/drivers/net/enic/vnic_wq.c
+++ b/drivers/net/enic/vnic_wq.c
@@ -160,10 +160,10 @@ int vnic_wq_disable(struct vnic_wq *wq)
 	iowrite32(0, &wq->ctrl->enable);
 
 	/* Wait for HW to ACK disable request */
-	for (wait = 0; wait < 100; wait++) {
+	for (wait = 0; wait < 1000; wait++) {
 		if (!(ioread32(&wq->ctrl->running)))
 			return 0;
-		udelay(1);
+		udelay(10);
 	}
 
 	printk(KERN_ERR "Failed to disable WQ[%d]\n", wq->index);

