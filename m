From: <netanel@amazon.com>
Subject: [PATCH net-next 10/13] net: ena: add mtu limitation in ena_change_mtu()
Date: Fri, 9 Jun 2017 01:01:22 +0300
Message-ID: <1496959285-8632-11-git-send-email-netanel@amazon.com>
References: <1496959285-8632-8-git-send-email-netanel@amazon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Netanel Belgazal <netanel@amazon.com>, <dwmw@amazon.com>,
        <zorik@amazon.com>, <matua@amazon.com>, <saeedb@amazon.com>,
        <msw@amazon.com>, <aliguori@amazon.com>, <nafea@amazon.com>,
        <evgenys@amazon.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9101.amazon.com ([207.171.184.25]:2640 "EHLO
        smtp-fw-9101.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751881AbdFHWCw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 18:02:52 -0400
In-Reply-To: <1496959285-8632-8-git-send-email-netanel@amazon.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Netanel Belgazal <netanel@amazon.com>

Signed-off-by: Netanel Belgazal <netanel@amazon.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 7dee448..7f31f4c 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -108,6 +108,13 @@ static int ena_change_mtu(struct net_device *dev, int new_mtu)
 	struct ena_adapter *adapter = netdev_priv(dev);
 	int ret;
 
+	if ((new_mtu > adapter->max_mtu) || (new_mtu < ENA_MIN_MTU)) {
+		netif_err(adapter, drv, dev,
+			  "Invalid MTU setting. new_mtu: %d max mtu: %d min mtu: %d\n",
+			  new_mtu, adapter->max_mtu, ENA_MIN_MTU);
+		return -EINVAL;
+	}
+
 	ret = ena_com_set_dev_mtu(adapter->ena_dev, new_mtu);
 	if (!ret) {
 		netif_dbg(adapter, drv, dev, "set MTU to %d\n", new_mtu);
@@ -3008,8 +3015,6 @@ static void ena_set_conf_feat_params(struct ena_adapter *adapter,
 	ena_set_dev_offloads(feat, netdev);
 
 	adapter->max_mtu = feat->dev_attr.max_mtu;
-	netdev->max_mtu = adapter->max_mtu;
-	netdev->min_mtu = ENA_MIN_MTU;
 }
 
 static int ena_rss_init_default(struct ena_adapter *adapter)
-- 
2.7.4
