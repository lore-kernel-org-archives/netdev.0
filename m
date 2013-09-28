From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 2/6] bnx2x: Correct VF driver info
Date: Sat, 28 Sep 2013 08:46:08 +0300
Message-ID: <1380347172-16670-3-git-send-email-yuvalmin@broadcom.com>
References: <1380347172-16670-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1430 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751397Ab3I1Fqd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Sep 2013 01:46:33 -0400
In-Reply-To: <1380347172-16670-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When running ethtool on VF interfaces, returning values should indicate
that the interface does not support self-test or register dump.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h         | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 97b3d32..a38d049 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2231,7 +2231,7 @@ void bnx2x_igu_clear_sb_gen(struct bnx2x *bp, u8 func, u8 idu_sb_id,
 #define BNX2X_NUM_TESTS_SF		7
 #define BNX2X_NUM_TESTS_MF		3
 #define BNX2X_NUM_TESTS(bp)		(IS_MF(bp) ? BNX2X_NUM_TESTS_MF : \
-						     BNX2X_NUM_TESTS_SF)
+					     IS_VF(bp) ? 0 : BNX2X_NUM_TESTS_SF)
 
 #define BNX2X_PHY_LOOPBACK		0
 #define BNX2X_MAC_LOOPBACK		1
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 120966c..8213cc8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -639,6 +639,9 @@ static int bnx2x_get_regs_len(struct net_device *dev)
 	struct bnx2x *bp = netdev_priv(dev);
 	int regdump_len = 0;
 
+	if (IS_VF(bp))
+		return 0;
+
 	regdump_len = __bnx2x_get_regs_len(bp);
 	regdump_len *= 4;
 	regdump_len += sizeof(struct dump_header);
-- 
1.8.1.227.g44fe835
