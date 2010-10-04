From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 8/8] qlcnic: set mtu lower limit
Date: Mon,  4 Oct 2010 07:20:16 -0700
Message-ID: <1286202016-18026-9-git-send-email-amit.salecha@qlogic.com>
References: <1286202016-18026-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sritej Velaga <sritej.velaga@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:26251 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755861Ab0JDOUS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 10:20:18 -0400
In-Reply-To: <1286202016-18026-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sritej Velaga <sritej.velaga@qlogic.com>

Setting mtu < 68 is not supported.

Signed-off-by: Sritej Velaga <sritej.velaga@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h    |    1 +
 drivers/net/qlcnic/qlcnic_hw.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 9d80171..42a2883 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -95,6 +95,7 @@
 #define FIRST_PAGE_GROUP_END	0x100000
 
 #define P3_MAX_MTU                     (9600)
+#define P3_MIN_MTU                     (68)
 #define QLCNIC_MAX_ETHERHDR                32 /* This contains some padding */
 
 #define QLCNIC_P3_RX_BUF_MAX_LEN         (QLCNIC_MAX_ETHERHDR + ETH_DATA_LEN)
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 712cfab..9d3e16d 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -758,9 +758,9 @@ int qlcnic_change_mtu(struct net_device *netdev, int mtu)
 	struct qlcnic_adapter *adapter = netdev_priv(netdev);
 	int rc = 0;
 
-	if (mtu > P3_MAX_MTU) {
-		dev_err(&adapter->netdev->dev, "mtu > %d bytes unsupported\n",
-						P3_MAX_MTU);
+	if (mtu < P3_MIN_MTU || mtu > P3_MAX_MTU) {
+		dev_err(&adapter->netdev->dev, "%d bytes < mtu < %d bytes"
+			" not supported\n", P3_MAX_MTU, P3_MIN_MTU);
 		return -EINVAL;
 	}
 
-- 
1.6.3.3

