From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 1/4] bnx2x: fix non-pmf device load flow
Date: Sun, 6 Mar 2011 22:49:25 +0200
Message-ID: <1299444565.13442.4.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3882 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754403Ab1CFU6f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Mar 2011 15:58:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove port MAX BW configuration from non-pmf functions,
which caused reconfigure of HW according to 10G (fake) link.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 032ae18..469ca60 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2092,8 +2092,9 @@ static void bnx2x_cmng_fns_init(struct bnx2x *bp, u8 read_cfg, u8 cmng_type)
 		bnx2x_calc_vn_weight_sum(bp);
 
 		/* calculate and set min-max rate for each vn */
-		for (vn = VN_0; vn < E1HVN_MAX; vn++)
-			bnx2x_init_vn_minmax(bp, vn);
+		if (bp->port.pmf)
+			for (vn = VN_0; vn < E1HVN_MAX; vn++)
+				bnx2x_init_vn_minmax(bp, vn);
 
 		/* always enable rate shaping and fairness */
 		bp->cmng.flags.cmng_enables |=
-- 
1.7.2.2




