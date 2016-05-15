From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/13] i40e: Correct UDP packet header for non_tunnel-ipv6
Date: Sat, 14 May 2016 21:57:30 -0700
Message-ID: <1463288255-1654-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:57094 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504AbcEOE5l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 15 May 2016 00:57:41 -0400
In-Reply-To: <1463288255-1654-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>

This patch corrects Rx ptype payload layer for non_tunneled ipv6. It
should be layer 4 for UDP, instead of layer 3.

Change-ID: I9382e4458ab3c4e58f6d2e9f195d5d4ee513805e
Signed-off-by: Akeem G Abodunrin <akeem.g.abodunrin@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 27c6f9d..422b41d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -696,7 +696,7 @@ struct i40e_rx_ptype_decoded i40e_ptype_lookup[] = {
 	/* Non Tunneled IPv6 */
 	I40E_PTT(88, IP, IPV6, FRG, NONE, NONE, NOF, NONE, PAY3),
 	I40E_PTT(89, IP, IPV6, NOF, NONE, NONE, NOF, NONE, PAY3),
-	I40E_PTT(90, IP, IPV6, NOF, NONE, NONE, NOF, UDP,  PAY3),
+	I40E_PTT(90, IP, IPV6, NOF, NONE, NONE, NOF, UDP,  PAY4),
 	I40E_PTT_UNUSED_ENTRY(91),
 	I40E_PTT(92, IP, IPV6, NOF, NONE, NONE, NOF, TCP,  PAY4),
 	I40E_PTT(93, IP, IPV6, NOF, NONE, NONE, NOF, SCTP, PAY4),
-- 
2.5.5
