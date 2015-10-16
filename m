From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 16/17] i40e: increase AQ work limit
Date: Fri, 16 Oct 2015 05:10:24 -0700
Message-ID: <1444997425-3396-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:56709 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099AbbJPMKd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Oct 2015 08:10:33 -0400
In-Reply-To: <1444997425-3396-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

With 64 VFs, we can easily overwhelm the AQ on the PF if we have too low
a limit on the number of AQ requests. This leads to ARQ overflow errors,
and occasionally VFs that fail to initialize.

Since we really only hit this condition on initial VF driver load, the
requests that we process are lightweight, so this extra work doesn't
cause problems for the PF driver.

Change-ID: I620221520d8af987df6ace9ba938ffaf22107681
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index ad48f52..7a58b1f 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -93,7 +93,7 @@
 #endif /* I40E_FCOE */
 #define I40E_MAX_AQ_BUF_SIZE          4096
 #define I40E_AQ_LEN                   256
-#define I40E_AQ_WORK_LIMIT            32
+#define I40E_AQ_WORK_LIMIT            66 /* max number of VFs + a little */
 #define I40E_MAX_USER_PRIORITY        8
 #define I40E_DEFAULT_MSG_ENABLE       4
 #define I40E_QUEUE_WAIT_RETRY_LIMIT   10
-- 
2.4.3
