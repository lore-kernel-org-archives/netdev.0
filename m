From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 14/15] i40evf: change type of flags variable
Date: Thu, 13 Feb 2014 03:48:52 -0800
Message-ID: <1392292133-32120-15-git-send-email-aaron.f.brown@intel.com>
References: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Aaron Brown <aaron.f.brown@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:29634 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754376AbaBMLvO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:51:14 -0500
In-Reply-To: <1392292133-32120-1-git-send-email-aaron.f.brown@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

As pointed out by Dan Carpenter (from Oracle), the flags variable is
declared as a 64-bit long but all of the flags are defined as u32,
which may lead to unintended consequences. Fix this by declaring flags
as u32 (since we don't need any more than about a dozen flags right
now), and remove the volatile qualifier, since it's unnecessary and
just makes checkpatch cry.

Change-ID: I137d3bb1842bf7e9456b5929ca54e3b0ed45dcab
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Dan Carpenter <dan.carpenter@oracle.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index 696c9d1..5e0a344 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -205,7 +205,7 @@ struct i40evf_adapter {
 	int num_msix_vectors;
 	struct msix_entry *msix_entries;
 
-	volatile unsigned long flags;
+	u32 flags;
 #define I40EVF_FLAG_RX_CSUM_ENABLED              (u32)(1)
 #define I40EVF_FLAG_RX_1BUF_CAPABLE              (u32)(1 << 1)
 #define I40EVF_FLAG_RX_PS_CAPABLE                (u32)(1 << 2)
-- 
1.8.5.GIT
