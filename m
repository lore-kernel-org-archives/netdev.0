From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/14] i40evf: Fix get_rss_aq
Date: Tue,  5 Apr 2016 20:36:04 -0700
Message-ID: <1459913769-56510-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61852 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760846AbcDFDg2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:28 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

We were passing in the seed where we should just be passing false
because we want the VSI table not the pf table.

Change-ID: I9b633ab06eb59468087f0c0af8539857e99f9495
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 6561a33..2d1fe56 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -1341,7 +1341,7 @@ static int i40evf_get_rss_aq(struct i40e_vsi *vsi, const u8 *seed,
 	}
 
 	if (lut) {
-		ret = i40evf_aq_get_rss_lut(hw, vsi->id, seed, lut, lut_size);
+		ret = i40evf_aq_get_rss_lut(hw, vsi->id, false, lut, lut_size);
 		if (ret) {
 			dev_err(&adapter->pdev->dev,
 				"Cannot get RSS lut, err %s aq_err %s\n",
-- 
2.5.5
