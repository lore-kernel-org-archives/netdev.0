From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/15] i40e: avoid large memcpy by assigning struct
Date: Wed, 17 Feb 2016 09:51:42 -0800
Message-ID: <1455731506-62165-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28480 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161411AbcBQRvw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:52 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Assign the i40e_pf structure directly instead of using a large memcpy,
which avoids a sparse warning and lets the compiler optimize the copy
since it knows the size of the structure in advance.

Change-ID: I17604e23be2616521eb760290befcb767b52b3f7
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 7aae056..3948587 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -185,9 +185,11 @@ static ssize_t i40e_dbg_dump_write(struct file *filp,
 		if (i40e_dbg_prep_dump_buf(pf, buflen)) {
 			p = i40e_dbg_dump_buf;
 
-			len = sizeof(struct i40e_pf);
-			memcpy(p, pf, len);
-			p += len;
+			/* avoid use of memcpy here due to sparse warning
+			 * about copy size.
+			 */
+			*((struct i40e_pf *)p) = *pf;
+			p += sizeof(struct i40e_pf);
 
 			len = (sizeof(struct i40e_aq_desc)
 					* pf->hw.aq.num_asq_entries);
-- 
2.5.0
