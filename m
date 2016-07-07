From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] bnxt: fix a condition
Date: Thu, 7 Jul 2016 11:23:09 +0300
Message-ID: <20160707082309.GC16742@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeffrey Huang <huangjw@broadcom.com>,
	Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Michael Chan <michael.chan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:24621 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030281AbcGGIXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 04:23:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This code generates as static checker warning because htons(ETH_P_IPV6)
is always true.  From the context it looks like the && was intended to
be !=.

Fixes: 94758f8de037 ('bnxt_en: Add GRO logic for BCM5731X chips.')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 70b148a..659faa6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -997,7 +997,7 @@ static struct sk_buff *bnxt_gro_func_5731x(struct bnxt_tpa_info *tpa_info,
 		 * correct protocol ID, it must be a loopback packet where
 		 * the offsets are off by 4.
 		 */
-		if (proto != htons(ETH_P_IP) && proto && htons(ETH_P_IPV6))
+		if (proto != htons(ETH_P_IP) && proto != htons(ETH_P_IPV6))
 			loopback = true;
 	}
 	if (loopback) {
