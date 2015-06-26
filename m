From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 01/10] igb: disable IPv6 extension header processing
Date: Fri, 26 Jun 2015 03:20:31 -0700
Message-ID: <1435314040-3228-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:58214 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751689AbbFZKUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Jun 2015 06:20:44 -0400
In-Reply-To: <1435314040-3228-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Disable IPv6 extension header processing as per hardware errata.

Also fix copyright date.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/e1000_82575.c   | 12 ++++++++----
 drivers/net/ethernet/intel/igb/e1000_defines.h |  3 ++-
 2 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_82575.c b/drivers/net/ethernet/intel/igb/e1000_82575.c
index 0f69ef8..b0182dd 100644
--- a/drivers/net/ethernet/intel/igb/e1000_82575.c
+++ b/drivers/net/ethernet/intel/igb/e1000_82575.c
@@ -1,5 +1,5 @@
 /* Intel(R) Gigabit Ethernet Linux driver
- * Copyright(c) 2007-2014 Intel Corporation.
+ * Copyright(c) 2007-2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -1900,8 +1900,8 @@ static void igb_clear_hw_cntrs_82575(struct e1000_hw *hw)
  *  igb_rx_fifo_flush_82575 - Clean rx fifo after RX enable
  *  @hw: pointer to the HW structure
  *
- *  After rx enable if managability is enabled then there is likely some
- *  bad data at the start of the fifo and possibly in the DMA fifo.  This
+ *  After rx enable if manageability is enabled then there is likely some
+ *  bad data at the start of the fifo and possibly in the DMA fifo. This
  *  function clears the fifos and flushes any packets that came in as rx was
  *  being enabled.
  **/
@@ -1910,6 +1910,11 @@ void igb_rx_fifo_flush_82575(struct e1000_hw *hw)
 	u32 rctl, rlpml, rxdctl[4], rfctl, temp_rctl, rx_enabled;
 	int i, ms_wait;
 
+	/* disable IPv6 options as per hardware errata */
+	rfctl = rd32(E1000_RFCTL);
+	rfctl |= E1000_RFCTL_IPV6_EX_DIS;
+	wr32(E1000_RFCTL, rfctl);
+
 	if (hw->mac.type != e1000_82575 ||
 	    !(rd32(E1000_MANC) & E1000_MANC_RCV_TCO_EN))
 		return;
@@ -1937,7 +1942,6 @@ void igb_rx_fifo_flush_82575(struct e1000_hw *hw)
 	 * incoming packets are rejected.  Set enable and wait 2ms so that
 	 * any packet that was coming in as RCTL.EN was set is flushed
 	 */
-	rfctl = rd32(E1000_RFCTL);
 	wr32(E1000_RFCTL, rfctl & ~E1000_RFCTL_LEF);
 
 	rlpml = rd32(E1000_RLPML);
diff --git a/drivers/net/ethernet/intel/igb/e1000_defines.h b/drivers/net/ethernet/intel/igb/e1000_defines.h
index 217f813..f8684aa 100644
--- a/drivers/net/ethernet/intel/igb/e1000_defines.h
+++ b/drivers/net/ethernet/intel/igb/e1000_defines.h
@@ -344,7 +344,8 @@
 #define E1000_RXCSUM_PCSD      0x00002000   /* packet checksum disabled */
 
 /* Header split receive */
-#define E1000_RFCTL_LEF        0x00040000
+#define E1000_RFCTL_IPV6_EX_DIS         0x00010000
+#define E1000_RFCTL_LEF                 0x00040000
 
 /* Collision related configuration parameters */
 #define E1000_COLLISION_THRESHOLD       15
-- 
2.4.3
