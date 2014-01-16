From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 2/6] ixgbevf: set the disable state when ixgbevf_qv_disable is called
Date: Thu, 16 Jan 2014 02:30:06 -0800
Message-ID: <1389868210-24035-3-git-send-email-aaron.f.brown@intel.com>
References: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:34053 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752013AbaAPKae (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 05:30:34 -0500
In-Reply-To: <1389868210-24035-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The ixgbevf_qv_disable function used by CONFIG_NET_RX_BUSY_POLL is broken,
because it does not properly set the IXGBEVF_QV_STATE_DISABLED bit, indicating
that the q_vector should be disabled (and preventing future locks from
obtaining the vector). This patch corrects the issue by setting the disable
state.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index bb76e96..d7cec1d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -260,6 +260,7 @@ static inline bool ixgbevf_qv_disable(struct ixgbevf_q_vector *q_vector)
 	spin_lock_bh(&q_vector->lock);
 	if (q_vector->state & IXGBEVF_QV_OWNED)
 		rc = false;
+	q_vector->state |= IXGBEVF_QV_STATE_DISABLED;
 	spin_unlock_bh(&q_vector->lock);
 	return rc;
 }
-- 
1.8.5.GIT
