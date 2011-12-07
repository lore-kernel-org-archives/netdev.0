From: Michael Wang <wangyun@linux.vnet.ibm.com>
Subject: [PATCH v2] e1000e: Assign true and false to bool type variable instead
 of 1 and 0
Date: Wed, 07 Dec 2011 10:33:21 +0800
Message-ID: <4EDED071.40900@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michael Wang <wangyun@linux.vnet.ibm.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"wangyunlinux@gmail.com" <wangyunlinux@gmail.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([122.248.162.6]:52949 "EHLO
	e28smtp06.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754868Ab1LGCd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 21:33:29 -0500
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wangyun@linux.vnet.ibm.com>;
	Wed, 7 Dec 2011 08:03:26 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pB72XOeJ3436744
	for <netdev@vger.kernel.org>; Wed, 7 Dec 2011 08:03:24 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pB72XNUF027254
	for <netdev@vger.kernel.org>; Wed, 7 Dec 2011 08:03:23 +0530
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Wang <wangyun@linux.vnet.ibm.com>

Use true and false instead of 1 and 0 when assign value to a bool type
variable.

This patch is try to keep the style of driver, and according to David's
suggestion on patch "e1000e: Avoid wrong check on TX hang":

http://marc.info/?l=linux-netdev&m=132296931201839&w=2

v2: add more description

Signed-off-by: Michael Wang <wangyun@linux.vnet.ibm.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   34
++++++++++++++--------------
 1 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
b/drivers/net/ethernet/intel/e1000e/netdev.c
index a855db1..2e5e423 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -875,7 +875,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter
*adapter,
 	u32 length, staterr;
 	unsigned int i;
 	int cleaned_count = 0;
-	bool cleaned = 0;
+	bool cleaned = false;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;

 	i = rx_ring->next_to_clean;
@@ -904,7 +904,7 @@ static bool e1000_clean_rx_irq(struct e1000_adapter
*adapter,

 		next_buffer = &rx_ring->buffer_info[i];

-		cleaned = 1;
+		cleaned = true;
 		cleaned_count++;
 		dma_unmap_single(&pdev->dev,
 				 buffer_info->dma,
@@ -1150,7 +1150,7 @@ static bool e1000_clean_tx_irq(struct
e1000_adapter *adapter)
 		 * Detect a transmit hang in hardware, this serializes the
 		 * check with the clearing of time_stamp and movement of i
 		 */
-		adapter->detect_tx_hung = 0;
+		adapter->detect_tx_hung = false;
 		if (tx_ring->buffer_info[i].time_stamp &&
 		    time_after(jiffies, tx_ring->buffer_info[i].time_stamp
 			       + (adapter->tx_timeout_factor * HZ)) &&
@@ -1185,7 +1185,7 @@ static bool e1000_clean_rx_irq_ps(struct
e1000_adapter *adapter,
 	unsigned int i, j;
 	u32 length, staterr;
 	int cleaned_count = 0;
-	bool cleaned = 0;
+	bool cleaned = false;
 	unsigned int total_rx_bytes = 0, total_rx_packets = 0;

 	i = rx_ring->next_to_clean;
@@ -1211,7 +1211,7 @@ static bool e1000_clean_rx_irq_ps(struct
e1000_adapter *adapter,

 		next_buffer = &rx_ring->buffer_info[i];

-		cleaned = 1;
+		cleaned = true;
 		cleaned_count++;
 		dma_unmap_single(&pdev->dev, buffer_info->dma,
 				 adapter->rx_ps_bsize0, DMA_FROM_DEVICE);
@@ -1628,7 +1628,7 @@ static irqreturn_t e1000_intr_msi(int irq, void *data)
 	 */

 	if (icr & E1000_ICR_LSC) {
-		hw->mac.get_link_status = 1;
+		hw->mac.get_link_status = true;
 		/*
 		 * ICH8 workaround-- Call gig speed drop workaround on cable
 		 * disconnect (LSC) before accessing any PHY registers
@@ -1694,7 +1694,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	 */

 	if (icr & E1000_ICR_LSC) {
-		hw->mac.get_link_status = 1;
+		hw->mac.get_link_status = true;
 		/*
 		 * ICH8 workaround-- Call gig speed drop workaround on cable
 		 * disconnect (LSC) before accessing any PHY registers
@@ -1751,7 +1751,7 @@ static irqreturn_t e1000_msix_other(int irq, void
*data)
 	if (icr & E1000_ICR_OTHER) {
 		if (!(icr & E1000_ICR_LSC))
 			goto no_link_interrupt;
-		hw->mac.get_link_status = 1;
+		hw->mac.get_link_status = true;
 		/* guard against interrupt when we're going down */
 		if (!test_bit(__E1000_DOWN, &adapter->state))
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
@@ -3327,7 +3327,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		fc->pause_time = 0xFFFF;
 	else
 		fc->pause_time = E1000_FC_PAUSE_TIME;
-	fc->send_xon = 1;
+	fc->send_xon = true;
 	fc->current_mode = fc->requested_mode;

 	switch (hw->mac.type) {
@@ -4183,7 +4183,7 @@ static void e1000_print_link_info(struct
e1000_adapter *adapter)
 static bool e1000e_has_link(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	bool link_active = 0;
+	bool link_active = false;
 	s32 ret_val = 0;

 	/*
@@ -4198,7 +4198,7 @@ static bool e1000e_has_link(struct e1000_adapter
*adapter)
 			ret_val = hw->mac.ops.check_for_link(hw);
 			link_active = !hw->mac.get_link_status;
 		} else {
-			link_active = 1;
+			link_active = true;
 		}
 		break;
 	case e1000_media_type_fiber:
@@ -4297,7 +4297,7 @@ static void e1000_watchdog_task(struct work_struct
*work)

 	if (link) {
 		if (!netif_carrier_ok(netdev)) {
-			bool txb2b = 1;
+			bool txb2b = true;

 			/* Cancel scheduled suspend requests. */
 			pm_runtime_resume(netdev->dev.parent);
@@ -4333,11 +4333,11 @@ static void e1000_watchdog_task(struct
work_struct *work)
 			adapter->tx_timeout_factor = 1;
 			switch (adapter->link_speed) {
 			case SPEED_10:
-				txb2b = 0;
+				txb2b = false;
 				adapter->tx_timeout_factor = 16;
 				break;
 			case SPEED_100:
-				txb2b = 0;
+				txb2b = false;
 				adapter->tx_timeout_factor = 10;
 				break;
 			}
@@ -4473,7 +4473,7 @@ link_up:
 	e1000e_flush_descriptors(adapter);

 	/* Force detection of hung controller every watchdog period */
-	adapter->detect_tx_hung = 1;
+	adapter->detect_tx_hung = true;

 	/*
 	 * With 82571 controllers, LAA may be overwritten due to controller
@@ -6134,8 +6134,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->print_hang_task, e1000_print_hw_hang);

 	/* Initialize link parameters. User can change them with ethtool */
-	adapter->hw.mac.autoneg = 1;
-	adapter->fc_autoneg = 1;
+	adapter->hw.mac.autoneg = true;
+	adapter->fc_autoneg = true;
 	adapter->hw.fc.requested_mode = e1000_fc_default;
 	adapter->hw.fc.current_mode = e1000_fc_default;
 	adapter->hw.phy.autoneg_advertised = 0x2f;
-- 
1.7.4.1
