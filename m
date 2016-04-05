From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 12/15] fm10k: prevent possibly uninitialized variable
Date: Tue,  5 Apr 2016 13:02:24 -0700
Message-ID: <1459886547-146445-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18249 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759908AbcDEUCd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 16:02:33 -0400
In-Reply-To: <1459886547-146445-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

If 'attr_flag < (1 << (2 * FM10K_TEST_MSG_NESTED))' is ever false, err
will be used uninitialized.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index c67121c..2e4ea88 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -937,7 +937,7 @@ static int fm10k_mbx_test(struct fm10k_intfc *interface, u64 *data)
 	struct fm10k_mbx_info *mbx = &hw->mbx;
 	u32 attr_flag, test_msg[6];
 	unsigned long timeout;
-	int err;
+	int err = -EINVAL;
 
 	/* For now this is a VF only feature */
 	if (hw->mac.type != fm10k_mac_vf)
-- 
2.5.5
