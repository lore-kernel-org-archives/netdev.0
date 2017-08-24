From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: [PATCH net-next] net-next/hinic: Fix MTU limitation
Date: Thu, 24 Aug 2017 21:21:25 +0800
Message-ID: <1503580885-35180-1-git-send-email-aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <zhaochen6@huawei.com>, Aviad Krawczyk <aviad.krawczyk@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix the hw MTU limitation by setting min/max_mtu

Signed-off-by: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Signed-off-by: Zhao Chen <zhaochen6@huawei.com>
---
 drivers/net/ethernet/huawei/hinic/hinic_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
index ae7ad48..7a14963 100644
--- a/drivers/net/ethernet/huawei/hinic/hinic_main.c
+++ b/drivers/net/ethernet/huawei/hinic/hinic_main.c
@@ -980,6 +980,9 @@ static int nic_dev_init(struct pci_dev *pdev)
 	hinic_hwdev_cb_register(nic_dev->hwdev, HINIC_MGMT_MSG_CMD_LINK_STATUS,
 				nic_dev, link_status_event_handler);
 
+	netdev->min_mtu = ETH_MIN_MTU;
+	netdev->max_mtu = ETH_MAX_MTU;
+
 	err = register_netdev(netdev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to register netdev\n");
-- 
1.9.1
