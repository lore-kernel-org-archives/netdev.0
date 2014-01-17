From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 1/3] ixgbe: add braces around else condition in ixgbe_qv_lock_* calls
Date: Fri, 17 Jan 2014 01:21:36 -0800
Message-ID: <1389950498-8820-2-git-send-email-aaron.f.brown@intel.com>
References: <1389950498-8820-1-git-send-email-aaron.f.brown@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63565 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751784AbaAQJVq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 04:21:46 -0500
In-Reply-To: <1389950498-8820-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch adds braces around the ixgbe_qv_lock_* calls which previously only
had braces around the if portion. Kernel style guidelines for this require
parenthesis around all conditions if they are required around one. In addition
the comment while not illegal C syntax makes the code look wrong at a cursory
glance. This patch corrects the style and adds braces so that the full if-else
block is uniform.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 3a4373f..0186ea2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -424,9 +424,10 @@ static inline bool ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
 #ifdef BP_EXTENDED_STATS
 		q_vector->tx.ring->stats.yields++;
 #endif
-	} else
+	} else {
 		/* we don't care if someone yielded */
 		q_vector->state = IXGBE_QV_STATE_NAPI;
+	}
 	spin_unlock_bh(&q_vector->lock);
 	return rc;
 }
@@ -458,9 +459,10 @@ static inline bool ixgbe_qv_lock_poll(struct ixgbe_q_vector *q_vector)
 #ifdef BP_EXTENDED_STATS
 		q_vector->rx.ring->stats.yields++;
 #endif
-	} else
+	} else {
 		/* preserve yield marks */
 		q_vector->state |= IXGBE_QV_STATE_POLL;
+	}
 	spin_unlock_bh(&q_vector->lock);
 	return rc;
 }
-- 
1.8.5.GIT
