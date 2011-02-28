From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-2.6 3/7] bnx2x: Fix ethtool -t link test for MF
 (non-pmf) devices.
Date: Mon, 28 Feb 2011 15:37:12 +0200
Message-ID: <1298900232.28024.119.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4264 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753915Ab1B1NjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Feb 2011 08:39:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_ethtool.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 5b0fe7a..ef29199 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -1932,11 +1932,11 @@ static void bnx2x_self_test(struct net_device *dev,
 		buf[4] = 1;
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
-	if (bp->port.pmf)
-		if (bnx2x_link_test(bp, is_serdes) != 0) {
-			buf[5] = 1;
-			etest->flags |= ETH_TEST_FL_FAILED;
-		}
+
+	if (bnx2x_link_test(bp, is_serdes) != 0) {
+		buf[5] = 1;
+		etest->flags |= ETH_TEST_FL_FAILED;
+	}
 
 #ifdef BNX2X_EXTRA_DEBUG
 	bnx2x_panic_dump(bp);
-- 
1.7.2.2




