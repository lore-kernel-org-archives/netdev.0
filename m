From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: Don't exit link event early if link speed has changed
Date: Tue, 13 Jan 2015 03:33:30 -0800
Message-ID: <1421148811-9763-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Catherine Sullivan <catherine.sullivan@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39160 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752364AbbAMLdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 06:33:39 -0500
In-Reply-To: <1421148811-9763-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Catherine Sullivan <catherine.sullivan@intel.com>

Previously we were only checking if the link up state had changed,
and if it hadn't exiting the link event routine early. We should
also check if speed has changed, and if it has, stay and finish
processing the link event.

Change-ID: I9c8e0991b3f0279108a7858898c3c5ce0a9856b8
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 7c14973..80430b0 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5503,14 +5503,18 @@ static void i40e_link_event(struct i40e_pf *pf)
 {
 	bool new_link, old_link;
 	struct i40e_vsi *vsi = pf->vsi[pf->lan_vsi];
+	u8 new_link_speed, old_link_speed;
 
 	/* set this to force the get_link_status call to refresh state */
 	pf->hw.phy.get_link_info = true;
 
 	old_link = (pf->hw.phy.link_info_old.link_info & I40E_AQ_LINK_UP);
 	new_link = i40e_get_link_status(&pf->hw);
+	old_link_speed = pf->hw.phy.link_info_old.link_speed;
+	new_link_speed = pf->hw.phy.link_info.link_speed;
 
 	if (new_link == old_link &&
+	    new_link_speed == old_link_speed &&
 	    (test_bit(__I40E_DOWN, &vsi->state) ||
 	     new_link == netif_carrier_ok(vsi->netdev)))
 		return;
-- 
1.9.3
