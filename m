From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40e/i40evf: fix extension header csum logic
Date: Thu, 24 Jul 2014 06:13:19 -0700
Message-ID: <1406207604-31653-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:36503 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759172AbaGXNOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2014 09:14:06 -0400
In-Reply-To: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

The hardware design requires that the driver avoid indicating
checksum offload success on some ipv6 frames with extension
headers.

The code needs to just check for the IPV6EXADD bit and if
it is set punt the checksum to the stack.  I don't know why
the code was checking TCP on inner protocol, as that code
doesn't make any sense to me but seems wrong, so remove it.

Change-ID: I10d3aacdbb1819fb60b4b0eb80e6cc67ef2c9599
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-By: Jim Young <jamesx.m.young@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c   | 2 --
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c | 2 --
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 989866a..d26d683 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1237,8 +1237,6 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 
 	/* likely incorrect csum if alternate IP extension headers found */
 	if (ipv6 &&
-	    decoded.inner_prot == I40E_RX_PTYPE_INNER_PROT_TCP &&
-	    rx_error & (1 << I40E_RX_DESC_ERROR_L4E_SHIFT) &&
 	    rx_status & (1 << I40E_RX_DESC_STATUS_IPV6EXADD_SHIFT))
 		/* don't increment checksum err here, non-fatal err */
 		return;
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index b342f21..79bf96c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -773,8 +773,6 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 
 	/* likely incorrect csum if alternate IP extension headers found */
 	if (ipv6 &&
-	    decoded.inner_prot == I40E_RX_PTYPE_INNER_PROT_TCP &&
-	    rx_error & (1 << I40E_RX_DESC_ERROR_L4E_SHIFT) &&
 	    rx_status & (1 << I40E_RX_DESC_STATUS_IPV6EXADD_SHIFT))
 		/* don't increment checksum err here, non-fatal err */
 		return;
-- 
1.9.3
