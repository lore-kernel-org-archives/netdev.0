From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 6/6] igb: fix PHC stopping on max freq
Date: Tue, 26 Mar 2013 03:42:34 -0700
Message-ID: <1364294554-7967-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:47745 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759706Ab3CZKmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Mar 2013 06:42:40 -0400
In-Reply-To: <1364294554-7967-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>

For 82576 MAC type, max_adj is reported as 1000000000 ppb. However, if
this value is passed to igb_ptp_adjfreq_82576, incvalue overflows out of
INCVALUE_82576_MASK, resulting in setting of zero TIMINCA.incvalue, stopping
the PHC (instead of going at twice the nominal speed).

Fix the advertised max_adj value to the largest value hardware can handle.
As there is no min_adj value available (-max_adj is used instead), this will
also prevent stopping the clock intentionally. It's probably not a big deal,
other igb MAC types don't support stopping the clock, either.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Matthew Vick <matthew.vick@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ptp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
index 0987822..0a23750 100644
--- a/drivers/net/ethernet/intel/igb/igb_ptp.c
+++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
@@ -740,7 +740,7 @@ void igb_ptp_init(struct igb_adapter *adapter)
 	case e1000_82576:
 		snprintf(adapter->ptp_caps.name, 16, "%pm", netdev->dev_addr);
 		adapter->ptp_caps.owner = THIS_MODULE;
-		adapter->ptp_caps.max_adj = 1000000000;
+		adapter->ptp_caps.max_adj = 999999881;
 		adapter->ptp_caps.n_ext_ts = 0;
 		adapter->ptp_caps.pps = 0;
 		adapter->ptp_caps.adjfreq = igb_ptp_adjfreq_82576;
-- 
1.7.11.7
