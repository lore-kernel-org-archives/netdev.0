From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/15] i40e: Increase minimum number of allocated VSI
Date: Sat, 24 Sep 2016 23:42:42 -0700
Message-ID: <1474785769-54665-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem Abodunrin <akeem.g.abodunrin@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:47187 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965627AbcIYGmy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:54 -0400
In-Reply-To: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem Abodunrin <akeem.g.abodunrin@intel.com>

This patch increases minimum number of allocated VSIs, so as to resolve
failure adding VSI for VF when 64-VFs assigned to a PF. The driver
supports up to 128 VFs per device, users can decide to enable up to
64-VFs on a single PF, especially 2 X 40 devices. In that scenario, with
VMDq co-existence, there would be starvation of VSIs - with this patch,
supported features would have enough VSIs for configuration now.

Change-ID: If084f4cd823667af8fe7fdc11489c705b32039d5
Signed-off-by: Akeem Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 30aaee4..6b22df6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -74,7 +74,7 @@
 #define I40E_MIN_NUM_DESCRIPTORS	64
 #define I40E_MIN_MSIX			2
 #define I40E_DEFAULT_NUM_VMDQ_VSI	8 /* max 256 VSIs */
-#define I40E_MIN_VSI_ALLOC		51 /* LAN, ATR, FCOE, 32 VF, 16 VMDQ */
+#define I40E_MIN_VSI_ALLOC		83 /* LAN, ATR, FCOE, 64 VF */
 /* max 16 qps */
 #define i40e_default_queues_per_vmdq(pf) \
 		(((pf)->flags & I40E_FLAG_RSS_AQ_CAPABLE) ? 4 : 1)
-- 
2.7.4
