From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH] cxgb3: fix linkup issue
Date: Tue, 20 Apr 2010 10:32:20 +0900
Message-ID: <4BCD0424.8030501@ct.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:50220 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949Ab0DTBdq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 21:33:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

I encountered an issue that not to link up on cxgb3 fabric.
I bisected and found that this regression was introduced by
0f07c4ee8c800923ae7918c231532a9256233eed.

Correct to pass phy_addr to cphy_init() at t3_xaui_direct_phy_prep().

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
---
 drivers/net/cxgb3/ael1002.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/cxgb3/ael1002.c
index 5248f9e..35cd367 100644
--- a/drivers/net/cxgb3/ael1002.c
+++ b/drivers/net/cxgb3/ael1002.c
@@ -934,7 +934,7 @@ static struct cphy_ops xaui_direct_ops = {
 int t3_xaui_direct_phy_prep(struct cphy *phy, struct adapter *adapter,
 			    int phy_addr, const struct mdio_ops *mdio_ops)
 {
-	cphy_init(phy, adapter, MDIO_PRTAD_NONE, &xaui_direct_ops, mdio_ops,
+	cphy_init(phy, adapter, phy_addr, &xaui_direct_ops, mdio_ops,
 		  SUPPORTED_10000baseT_Full | SUPPORTED_AUI | SUPPORTED_TP,
 		  "10GBASE-CX4");
 	return 0;
-- 
1.6.3.3

