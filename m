From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/13] i40e: don't use OR to check a value
Date: Thu,  5 Jun 2014 03:12:49 -0700
Message-ID: <1401963181-11110-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401963181-11110-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Dave Jones <davej@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:19645 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328AbaFEKNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2014 06:13:05 -0400
In-Reply-To: <1401963181-11110-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

A couple of FD checks ended up using bitwise OR to check
a value, which ends up always being evaluated to true.

This should fix the issue.  Thanks to DaveJ for noticing
and reporting the issue!

CC: Dave Jones <davej@redhat.com>
Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 5a22187..1fe28ca 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -458,13 +458,13 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring,
 		 */
 		if (fcnt_prog >= (fcnt_avail - I40E_FDIR_BUFFER_FULL_MARGIN)) {
 			/* Turn off ATR first */
-			if (pf->flags | I40E_FLAG_FD_ATR_ENABLED) {
+			if (pf->flags & I40E_FLAG_FD_ATR_ENABLED) {
 				pf->flags &= ~I40E_FLAG_FD_ATR_ENABLED;
 				dev_warn(&pdev->dev, "FD filter space full, ATR for further flows will be turned off\n");
 				pf->auto_disable_flags |=
 						       I40E_FLAG_FD_ATR_ENABLED;
 				pf->flags |= I40E_FLAG_FDIR_REQUIRES_REINIT;
-			} else if (pf->flags | I40E_FLAG_FD_SB_ENABLED) {
+			} else if (pf->flags & I40E_FLAG_FD_SB_ENABLED) {
 				pf->flags &= ~I40E_FLAG_FD_SB_ENABLED;
 				dev_warn(&pdev->dev, "FD filter space full, new ntuple rules will not be added\n");
 				pf->auto_disable_flags |=
-- 
1.9.3
