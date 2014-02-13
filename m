From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 04/15] i40evf: clean up memsets
Date: Thu, 13 Feb 2014 03:48:42 -0800
Message-ID: <1392292133-32120-5-git-send-email-aaron.f.brown@intel.com>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Kevin Scott <kevin.c.scott@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20333 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754200AbaBMLvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:11 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

As politely pointed out by Dave Miller, calls to memset do not need a
void pointer cast. Additionally, it is preferred to use sizeof(*the
actual object) instead of sizeof(type).

Change-ID: Id6a02429b7040111531f3865ea03fbe619167cb3
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Kevin Scott <kevin.c.scott@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_adminq.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_adminq.c b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
index a50e6b3..ed3902b 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_adminq.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_adminq.c
@@ -647,9 +647,8 @@ static u16 i40e_clean_asq(struct i40e_hw *hw)
 			desc_cb = *desc;
 			cb_func(hw, &desc_cb);
 		}
-		memset((void *)desc, 0, sizeof(struct i40e_aq_desc));
-		memset((void *)details, 0,
-		       sizeof(struct i40e_asq_cmd_details));
+		memset(desc, 0, sizeof(*desc));
+		memset(details, 0, sizeof(*details));
 		ntc++;
 		if (ntc == asq->count)
 			ntc = 0;
-- 
1.8.5.GIT
