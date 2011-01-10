From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 2/3] qlcnic: fix ethtool diagnostics test
Date: Mon, 10 Jan 2011 02:15:22 -0800
Message-ID: <1294654523-3085-3-git-send-email-amit.salecha@qlogic.com>
References: <1294654523-3085-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sony Chacko <sony.chacko@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:55822 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753398Ab1AJKPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jan 2011 05:15:41 -0500
In-Reply-To: <1294654523-3085-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sony Chacko <sony.chacko@qlogic.com>

IRQ diag test was getting executed only when both register test
and link test passed. The test should get executed if ETH_TEST_FL_OFFLINE
flag is set.

Signed-off-by: Sony Chacko <sony.chacko@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 1e7af70..4c14510 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -672,7 +672,7 @@ qlcnic_diag_test(struct net_device *dev, struct ethtool_test *eth_test,
 	if (data[1])
 		eth_test->flags |= ETH_TEST_FL_FAILED;
 
-	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
+	if (eth_test->flags & ETH_TEST_FL_OFFLINE) {
 		data[2] = qlcnic_irq_test(dev);
 		if (data[2])
 			eth_test->flags |= ETH_TEST_FL_FAILED;
-- 
1.7.3.2

