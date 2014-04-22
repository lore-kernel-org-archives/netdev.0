From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/16] i40e: Fix an issue with displaying IPv4 FD filters
Date: Tue, 22 Apr 2014 05:39:22 -0700
Message-ID: <1398170371-3333-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Anjali Singhai Jain <anjali.singhai@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Catherine Sullivan <catherine.sullivan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27100 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932232AbaDVMji (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 08:39:38 -0400
In-Reply-To: <1398170371-3333-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anjali Singhai Jain <anjali.singhai@intel.com>

The flow spec coming in for IPv4 filters is IP_USER_FLOW, which
needed some more info to be communicated up above in order for it
to be displayed correctly.

Change-ID: Ia968238e0d7c4c4df12908ba81f0c4501280f3ec
Signed-off-by: Anjali Singhai Jain <anjali.singhai@intel.com>
Signed-off-by: Catherine Sullivan <catherine.sullivan@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
index 03d99cb..d9a41d3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_ethtool.c
@@ -1189,6 +1189,12 @@ static int i40e_get_ethtool_fdir_entry(struct i40e_pf *pf,
 		return -EINVAL;
 
 	fsp->flow_type = rule->flow_type;
+	if (fsp->flow_type == IP_USER_FLOW) {
+		fsp->h_u.usr_ip4_spec.ip_ver = ETH_RX_NFC_IP4;
+		fsp->h_u.usr_ip4_spec.proto = 0;
+		fsp->m_u.usr_ip4_spec.proto = 0;
+	}
+
 	fsp->h_u.tcp_ip4_spec.psrc = rule->src_port;
 	fsp->h_u.tcp_ip4_spec.pdst = rule->dst_port;
 	fsp->h_u.tcp_ip4_spec.ip4src = rule->src_ip[0];
-- 
1.9.0
