From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/3] i40e: fix errant PCIe bandwidth message
Date: Tue,  5 Apr 2016 15:30:49 -0700
Message-ID: <1459895451-45300-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459895451-45300-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Stefan Assman <sassman@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:12327 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933746AbcDEWay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 18:30:54 -0400
In-Reply-To: <1459895451-45300-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

There was an error introduced with commit 3fced535079a ("i40e: X722 is
on the IOSF bus and does not report the PCI bus info"), where code was
added but the enabling flag is never set.

CC: Anjali Singhai Jain <anjali.singhai@intel.com>
CC: Stefan Assman <sassman@redhat.com>
Fixes: 3fced535079a ("i40e: X722 is on the IOSF bus ...")
Reported-by: Steve Best <sbest@redhat.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 6700643..3449129 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8559,6 +8559,7 @@ static int i40e_sw_init(struct i40e_pf *pf)
 			     I40E_FLAG_OUTER_UDP_CSUM_CAPABLE |
 			     I40E_FLAG_WB_ON_ITR_CAPABLE |
 			     I40E_FLAG_MULTIPLE_TCP_UDP_RSS_PCTYPE |
+			     I40E_FLAG_NO_PCI_LINK_CHECK |
 			     I40E_FLAG_100M_SGMII_CAPABLE |
 			     I40E_FLAG_USE_SET_LLDP_MIB |
 			     I40E_FLAG_GENEVE_OFFLOAD_CAPABLE;
-- 
2.5.5
