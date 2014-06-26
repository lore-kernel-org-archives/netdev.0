From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/14] i40e: Avoid adding the TCP-IPv4 filter twice
Date: Thu, 26 Jun 2014 05:13:50 -0700
Message-ID: <1403784834-23301-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:10417 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757668AbaFZMOb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jun 2014 08:14:31 -0400
In-Reply-To: <1403784834-23301-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

There wasn't a need to play the logic twice, it seems
like a left over from when we had to add two PTYPEs for
one filter. There should be no change in the number of
filters that actually got added to the hardware.

Change-ID: I5071d02eafd020b60e30eb96219f110f334eec85
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 13 -------------
 1 file changed, 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index e49f31d..4d96b74 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -271,19 +271,6 @@ static int i40e_add_del_fdir_tcpv4(struct i40e_vsi *vsi,
 			 fd_data->pctype, ret);
 	}
 
-	fd_data->pctype = I40E_FILTER_PCTYPE_NONF_IPV4_TCP;
-
-	ret = i40e_program_fdir_filter(fd_data, raw_packet, pf, add);
-	if (ret) {
-		dev_info(&pf->pdev->dev,
-			 "Filter command send failed for PCTYPE %d (ret = %d)\n",
-			 fd_data->pctype, ret);
-		err = true;
-	} else {
-		dev_info(&pf->pdev->dev, "Filter OK for PCTYPE %d (ret = %d)\n",
-			  fd_data->pctype, ret);
-	}
-
 	return err ? -EOPNOTSUPP : 0;
 }
 
-- 
1.9.3
