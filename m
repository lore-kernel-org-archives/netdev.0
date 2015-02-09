From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: Use even more ARQ descriptors
Date: Mon,  9 Feb 2015 02:43:50 -0800
Message-ID: <1423478641-3138-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16331 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760158AbbBIKoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2015 05:44:05 -0500
In-Reply-To: <1423478641-3138-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

When enabling 64 VFs and loading the VF driver in the host kernel, we
can easily overrun the PF's admin receive queue. Double the size of this
queue, and increase the work limit to allow the PF to handle more
requests in a single pass through the service task.

Change-ID: I0efbbdc61954bffad422a2f33c4b948a59370bf5
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index fadf8fa..b35413d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -87,8 +87,8 @@
 #define I40E_MINIMUM_FCOE             1 /* minimum number of QPs for FCoE */
 #endif /* I40E_FCOE */
 #define I40E_MAX_AQ_BUF_SIZE          4096
-#define I40E_AQ_LEN                   128
-#define I40E_AQ_WORK_LIMIT            16
+#define I40E_AQ_LEN                   256
+#define I40E_AQ_WORK_LIMIT            32
 #define I40E_MAX_USER_PRIORITY        8
 #define I40E_DEFAULT_MSG_ENABLE       4
 #define I40E_QUEUE_WAIT_RETRY_LIMIT   10
-- 
1.9.3
