From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: add support for device reset interrupt
Date: Thu, 07 Jan 2010 19:41:00 -0800
Message-ID: <20100108034058.31805.96712.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:58528 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750887Ab0AHDlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 22:41:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch adds support for the global device reset interrupt.  Without
this change the drivers will report tx hangs on all ports when a global
device reset occurs.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 933c64f..a354375 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -4105,6 +4105,9 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 	u32 icr = rd32(E1000_ICR);
 	/* reading ICR causes bit 31 of EICR to be cleared */
 
+	if (icr & E1000_ICR_DRSTA)
+		schedule_work(&adapter->reset_task);
+
 	if (icr & E1000_ICR_DOUTSYNC) {
 		/* HW is reporting DMA is out of sync */
 		adapter->stats.doosync++;
@@ -4728,6 +4731,9 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 
 	igb_write_itr(q_vector);
 
+	if (icr & E1000_ICR_DRSTA)
+		schedule_work(&adapter->reset_task);
+
 	if (icr & E1000_ICR_DOUTSYNC) {
 		/* HW is reporting DMA is out of sync */
 		adapter->stats.doosync++;
@@ -4767,6 +4773,9 @@ static irqreturn_t igb_intr(int irq, void *data)
 	if (!(icr & E1000_ICR_INT_ASSERTED))
 		return IRQ_NONE;
 
+	if (icr & E1000_ICR_DRSTA)
+		schedule_work(&adapter->reset_task);
+
 	if (icr & E1000_ICR_DOUTSYNC) {
 		/* HW is reporting DMA is out of sync */
 		adapter->stats.doosync++;

