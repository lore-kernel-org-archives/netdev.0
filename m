From: akpm@linux-foundation.org
Subject: [patch 05/11] ehca: ret is unsigned, ibmebus_request_irq() negative return ignored in hca_create_eq()
Date: Wed, 14 May 2008 16:20:12 -0700
Message-ID: <200805142320.m4ENKCQl026623@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	12o3l@tiscali.nl, fenkes@de.ibm.com, hnguyen@de.ibm.com,
	paulus@samba.org, stefan.roscher@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:49443 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754588AbYENXU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 19:20:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roel Kluin <12o3l@tiscali.nl>


Cc: Joachim Fenkes <fenkes@de.ibm.com>
Cc: Hoang-Nam Nguyen <hnguyen@de.ibm.com>
Cc: Heiko J Schick <schickhj.ibm.com>
Cc: Stefan Roscher <stefan.roscher@de.ibm.com>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/infiniband/hw/ehca/ehca_eq.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff -puN drivers/infiniband/hw/ehca/ehca_eq.c~ehca-ret-is-unsigned-ibmebus_request_irq-negative-return-ignored-in-hca_create_eq drivers/infiniband/hw/ehca/ehca_eq.c
--- a/drivers/infiniband/hw/ehca/ehca_eq.c~ehca-ret-is-unsigned-ibmebus_request_irq-negative-return-ignored-in-hca_create_eq
+++ a/drivers/infiniband/hw/ehca/ehca_eq.c
@@ -60,6 +60,7 @@ int ehca_create_eq(struct ehca_shca *shc
 	u32 i;
 	void *vpage;
 	struct ib_device *ib_dev = &shca->ib_device;
+	int ret2;
 
 	spin_lock_init(&eq->spinlock);
 	spin_lock_init(&eq->irq_spinlock);
@@ -122,18 +123,18 @@ int ehca_create_eq(struct ehca_shca *shc
 
 	/* register interrupt handlers and initialize work queues */
 	if (type == EHCA_EQ) {
-		ret = ibmebus_request_irq(eq->ist, ehca_interrupt_eq,
+		ret2 = ibmebus_request_irq(eq->ist, ehca_interrupt_eq,
 					  IRQF_DISABLED, "ehca_eq",
 					  (void *)shca);
-		if (ret < 0)
+		if (ret2 < 0)
 			ehca_err(ib_dev, "Can't map interrupt handler.");
 
 		tasklet_init(&eq->interrupt_task, ehca_tasklet_eq, (long)shca);
 	} else if (type == EHCA_NEQ) {
-		ret = ibmebus_request_irq(eq->ist, ehca_interrupt_neq,
+		ret2 = ibmebus_request_irq(eq->ist, ehca_interrupt_neq,
 					  IRQF_DISABLED, "ehca_neq",
 					  (void *)shca);
-		if (ret < 0)
+		if (ret2 < 0)
 			ehca_err(ib_dev, "Can't map interrupt handler.");
 
 		tasklet_init(&eq->interrupt_task, ehca_tasklet_neq, (long)shca);
_
