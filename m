From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] e1000e: Correct link check logic for 82571 serdes
Date: Sat, 14 Jul 2012 01:34:05 -0700
Message-ID: <1342254845-28991-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, stable@vger.kernel.org,
	dnelson@redhat.com, bruce.w.allan@intel.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40510 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757866Ab2GNIeJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Jul 2012 04:34:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@intel.com>

SYNCH bit and IV bit of RXCW register are sticky. Before examining these bits,
RXCW should be read twice to filter out one-time false events and have correct
values for these bits. Incorrect values of these bits in link check logic can
cause weird link stability issues if auto-negotiation fails.

CC: stable <stable@vger.kernel.org> [2.6.38+]
Reported-by: Dean Nelson <dnelson@redhat.com>
Signed-off-by: Tushar Dave <tushar.n.dave@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.c b/drivers/net/ethernet/intel/e1000e/82571.c
index 36db4df..1f063dc 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.c
+++ b/drivers/net/ethernet/intel/e1000e/82571.c
@@ -1572,6 +1572,9 @@ static s32 e1000_check_for_serdes_link_82571(struct e1000_hw *hw)
 	ctrl = er32(CTRL);
 	status = er32(STATUS);
 	rxcw = er32(RXCW);
+	/* SYNCH bit and IV bit are sticky */
+	udelay(10);
+	rxcw = er32(RXCW);
 
 	if ((rxcw & E1000_RXCW_SYNCH) && !(rxcw & E1000_RXCW_IV)) {
 
-- 
1.7.10.4
