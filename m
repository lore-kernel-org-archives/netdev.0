From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] cxgb4: silence shift wrapping static checker warning
Date: Thu, 9 Jan 2014 08:34:00 +0300
Message-ID: <20140109053400.GF1265@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>,
	Kumar Sanghvi <kumaras@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:50684 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbaAIFdy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 00:33:54 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I don't know how large "tp->vlan_shift" is but static checkers worry
about shift wrapping bugs here.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index cb05be905def..81e8402a74b4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -423,7 +423,7 @@ u64 cxgb4_select_ntuple(struct net_device *dev,
 	 * in the Compressed Filter Tuple.
 	 */
 	if (tp->vlan_shift >= 0 && l2t->vlan != VLAN_NONE)
-		ntuple |= (F_FT_VLAN_VLD | l2t->vlan) << tp->vlan_shift;
+		ntuple |= (u64)(F_FT_VLAN_VLD | l2t->vlan) << tp->vlan_shift;
 
 	if (tp->port_shift >= 0)
 		ntuple |= (u64)l2t->lport << tp->port_shift;
