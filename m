From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/15] i40e: don't configure zero-size RSS table
Date: Sat, 24 Sep 2016 23:42:48 -0700
Message-ID: <1474785769-54665-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:47187 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965714AbcIYGm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 25 Sep 2016 02:42:56 -0400
In-Reply-To: <1474785769-54665-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

In some rare cases, we might get a VSI with no queues. In this case, we
cannot configure RSS on this VSI as it will try to divide by zero when
configuring the lookup table.

Change-ID: I6ae173a7dd3481a081e079eb10eb80275de2adb0
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index b434d07..8176596 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8282,6 +8282,8 @@ static int i40e_pf_config_rss(struct i40e_pf *pf)
 	if (!vsi->rss_size)
 		vsi->rss_size = min_t(int, pf->alloc_rss_size,
 				      vsi->num_queue_pairs);
+	if (!vsi->rss_size)
+		return -EINVAL;
 
 	lut = kzalloc(vsi->rss_table_size, GFP_KERNEL);
 	if (!lut)
-- 
2.7.4
