From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/14] i40e: Request PHY media event at reset time
Date: Tue,  5 Apr 2016 20:36:07 -0700
Message-ID: <1459913769-56510-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27555 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760863AbcDFDga (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 23:36:30 -0400
In-Reply-To: <1459913769-56510-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Add the Media Not Available flag to the link event mask.  It seems
that event comes first if you have a DA cable pulled out, but there's no
follow-up event for Link Down; if you're not looking for MEDIA_NA you will
get no event, even though there's now no Link.

Change-ID: cb3340a2849805bb881f64f6f2ae810eef46eba7
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 184f3f9..d2c0106 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6859,6 +6859,7 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	 */
 	ret = i40e_aq_set_phy_int_mask(&pf->hw,
 				       ~(I40E_AQ_EVENT_LINK_UPDOWN |
+					 I40E_AQ_EVENT_MEDIA_NA |
 					 I40E_AQ_EVENT_MODULE_QUAL_FAIL), NULL);
 	if (ret)
 		dev_info(&pf->pdev->dev, "set phy mask fail, err %s aq_err %s\n",
@@ -11070,6 +11071,7 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	err = i40e_aq_set_phy_int_mask(&pf->hw,
 				       ~(I40E_AQ_EVENT_LINK_UPDOWN |
+					 I40E_AQ_EVENT_MEDIA_NA |
 					 I40E_AQ_EVENT_MODULE_QUAL_FAIL), NULL);
 	if (err)
 		dev_info(&pf->pdev->dev, "set phy mask fail, err %s aq_err %s\n",
-- 
2.5.5
