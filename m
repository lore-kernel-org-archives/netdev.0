From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  11/11] i40e: fix error return code in i40e_probe()
Date: Tue, 29 Oct 2013 05:02:31 -0700
Message-ID: <1383048151-15002-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60485 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754936Ab3J2MCo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 08:02:44 -0400
In-Reply-To: <1383048151-15002-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fix to return -ENOMEM in the memory alloc error handling
case instead of 0, as done elsewhere in this function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 41a79df..be15938 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7204,8 +7204,10 @@ static int i40e_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	len = sizeof(struct i40e_vsi *) * pf->hw.func_caps.num_vsis;
 	pf->vsi = kzalloc(len, GFP_KERNEL);
-	if (!pf->vsi)
+	if (!pf->vsi) {
+		err = -ENOMEM;
 		goto err_switch_setup;
+	}
 
 	err = i40e_setup_pf_switch(pf);
 	if (err) {
-- 
1.8.3.1
