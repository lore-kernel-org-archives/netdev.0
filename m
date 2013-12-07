From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e: clear test state bit after all ethtool tests
Date: Fri,  6 Dec 2013 18:17:20 -0800
Message-ID: <1386382643-29055-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:44976 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758290Ab3LGCRb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 21:17:31 -0500
In-Reply-To: <1386382643-29055-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Fix a bug where the TESTING state was still set when
exiting the ethtool diagnostics.

Change-Id: Ic47950d2e86a67167d1d282256d477cecd86d820
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 7fb669b..44d4a7f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -805,9 +805,10 @@ static void i40e_diag_test(struct net_device *netdev,
 		data[I40E_ETH_TEST_EEPROM] = 0;
 		data[I40E_ETH_TEST_INTR] = 0;
 		data[I40E_ETH_TEST_LOOPBACK] = 0;
-
-		clear_bit(__I40E_TESTING, &pf->state);
 	}
+	clear_bit(__I40E_TESTING, &pf->state);
+
+	netdev_info(netdev, "testing finished\n");
 }
 
 static void i40e_get_wol(struct net_device *netdev,
-- 
1.8.3.1
