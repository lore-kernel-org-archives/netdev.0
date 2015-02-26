From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 13/13] i40e: check pointers before use
Date: Thu, 26 Feb 2015 07:03:49 -0800
Message-ID: <1424963029-4612-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40565 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753995AbbBZPD7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:03:59 -0500
In-Reply-To: <1424963029-4612-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Make sure we don't try to dereference NULL pointers when returning values
from the AdminQ calls.

Change-ID: Ia6694f2f415d50acf0aba063c863568742799aff
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 2a705a1..6aea65d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -2847,7 +2847,7 @@ i40e_status i40e_aq_add_udp_tunnel(struct i40e_hw *hw,
 
 	status = i40e_asq_send_command(hw, &desc, NULL, 0, cmd_details);
 
-	if (!status)
+	if (!status && filter_index)
 		*filter_index = resp->index;
 
 	return status;
-- 
1.9.3
