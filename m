From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/17] i40e: fix confusing dmesg info for ethtool -L option
Date: Sat, 29 Oct 2016 00:30:52 -0700
Message-ID: <1477726258-111563-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Lihong Yang <lihong.yang@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:10821 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751764AbcJ2HbI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Oct 2016 03:31:08 -0400
In-Reply-To: <1477726258-111563-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lihong Yang <lihong.yang@intel.com>

Ethtool -L option with the combined parameter is for changing the number of
multi-purpose channels of the specified network device. The pre-set maximum
for the combined channels is cpu dependent. Currently, for an i40e device,
when the user sets a value between 64 and the maximum that the cpu can
support for the combined parameter, the i40e driver displays the confusing
info in dmesg to only show 64 as the RSS count regardless of what the
accepted user input is as long as it is larger than 64.

This patch fixes the message in the i40e driver when the user uses
ethtool -L to change the number of the combined channels to consistently
display the user requested value if it is valid and accepted by ethtool.

Change-ID: Ia80a68bc844b779a49e0f76e7d3dcc915032d9af
Signed-off-by: Lihong Yang <lihong.yang@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c25247f..a4bae0a 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8400,8 +8400,8 @@ int i40e_reconfig_rss_queues(struct i40e_pf *pf, int queue_count)
 
 		i40e_pf_config_rss(pf);
 	}
-	dev_info(&pf->pdev->dev, "RSS count/HW max RSS count:  %d/%d\n",
-		 pf->alloc_rss_size, pf->rss_size_max);
+	dev_info(&pf->pdev->dev, "User requested queue count/HW max RSS count:  %d/%d\n",
+		 vsi->req_queue_pairs, pf->rss_size_max);
 	return pf->alloc_rss_size;
 }
 
-- 
2.7.4
