From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/16] i40e: Fix comment for ethtool diagnostic link test
Date: Wed, 19 Aug 2015 17:57:59 -0700
Message-ID: <1440032286-30054-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:10447 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751821AbbHTA6K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 20:58:10 -0400
In-Reply-To: <1440032286-30054-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The existing comment is incorrect.  Add new comment to point out that the
PF reset does not affect link but if the reset is changed to a different
type that does affect link then the link test would need to be moved to
before the reset.

Change-ID: I28d786f46e9465860babdee61c1dba51016464df
Reported-by: Jeremiah Kyle <jeremiah.kyle@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 74c16a1..62824f5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1626,11 +1626,13 @@ static void i40e_diag_test(struct net_device *netdev,
 			/* indicate we're in test mode */
 			dev_close(netdev);
 		else
+			/* This reset does not affect link - if it is
+			 * changed to a type of reset that does affect
+			 * link then the following link test would have
+			 * to be moved to before the reset
+			 */
 			i40e_do_reset(pf, BIT(__I40E_PF_RESET_REQUESTED));
 
-		/* Link test performed before hardware reset
-		 * so autoneg doesn't interfere with test result
-		 */
 		if (i40e_link_test(netdev, &data[I40E_ETH_TEST_LINK]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
-- 
2.4.3
