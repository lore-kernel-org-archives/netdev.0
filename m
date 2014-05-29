From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: Clear recovery pending, if reset failed
Date: Thu, 29 May 2014 08:10:12 -0700
Message-ID: <1401376216-12531-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42446 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932809AbaE2PKi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 11:10:38 -0400
In-Reply-To: <1401376216-12531-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

If pf_reset failed, it becomes necessary to clear recovery pending bit, instead
of falling through the setup process.

Change-ID: Ic1611e6a32741fe3a2782ec7be173cb65e7492ed
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Jim Young <jamesx.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 239a2ea..cef3db4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5367,8 +5367,10 @@ static void i40e_reset_and_rebuild(struct i40e_pf *pf, bool reinit)
 	 * because the reset will make them disappear.
 	 */
 	ret = i40e_pf_reset(hw);
-	if (ret)
+	if (ret) {
 		dev_info(&pf->pdev->dev, "PF reset failed, %d\n", ret);
+		goto end_core_reset;
+	}
 	pf->pfr_count++;
 
 	if (test_bit(__I40E_DOWN, &pf->state))
-- 
1.9.3
