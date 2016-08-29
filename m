From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/14] fm10k: NAPI polling routine must return actual work done
Date: Mon, 29 Aug 2016 02:13:38 -0700
Message-ID: <1472462026-42133-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com, Paolo Abeni <pabeni@redhat.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44642 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756883AbcH2JNu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 Aug 2016 05:13:50 -0400
In-Reply-To: <1472462026-42133-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When fm10k_poll fully cleans rings it returns 0. This is incorrect as it
messes up the budget accounting in the core NAPI code. Fix this by
returning actual work done, capped at budget - 1 since the core doesn't
expect a return of the full budget when the driver modifies the NAPI
status.

Cc: Paolo Abeni <pabeni@redhat.com>
Cc: Venkatesh Srinivas <venkateshs@google.com>
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Acked-by: Paolo Abeni <pabeni@redhat.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 4b65364..32d4429 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1484,7 +1484,7 @@ static int fm10k_poll(struct napi_struct *napi, int budget)
 	/* re-enable the q_vector */
 	fm10k_qv_enable(q_vector);
 
-	return 0;
+	return min(work_done, budget - 1);
 }
 
 /**
-- 
2.7.4
