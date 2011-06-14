From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 14/24] bnx2x: update DCB data during PMF
 migration
Date: Tue, 14 Jun 2011 14:33:57 +0300
Message-ID: <201106141433.57888.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4105 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756319Ab1FNLen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:34:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_dcb.h  |    2 +-
 drivers/net/bnx2x/bnx2x_main.c |    2 ++
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_dcb.h b/drivers/net/bnx2x/bnx2x_dcb.h
index 7887834..b3a655f 100644
--- a/drivers/net/bnx2x/bnx2x_dcb.h
+++ b/drivers/net/bnx2x/bnx2x_dcb.h
@@ -184,7 +184,7 @@ enum {
 };
 
 void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state);
-
+void bnx2x_dcbx_pmf_update(struct bnx2x *bp);
 /* DCB netlink */
 #ifdef BCM_DCBNL
 extern const struct dcbnl_rtnl_ops bnx2x_dcbnl_ops;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 628598e..73a22fd 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2477,6 +2477,8 @@ static void bnx2x_pmf_update(struct bnx2x *bp)
 	bp->port.pmf = 1;
 	DP(NETIF_MSG_LINK, "pmf %d\n", bp->port.pmf);
 
+	bnx2x_dcbx_pmf_update(bp);
+
 	/* enable nig attention */
 	val = (0xff0f | (1 << (BP_E1HVN(bp) + 4)));
 	if (bp->common.int_block == INT_BLOCK_HC) {
-- 
1.7.4.1


