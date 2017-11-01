From: Lipeng <lipeng321@huawei.com>
Subject: [PATCH net-next 8/9] net: hns3: Fix a misuse to devm_free_irq
Date: Wed, 1 Nov 2017 22:47:21 +0800
Message-ID: <1509547642-51110-9-git-send-email-lipeng321@huawei.com>
References: <1509547642-51110-1-git-send-email-lipeng321@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <lipeng321@huawei.com>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1509547642-51110-1-git-send-email-lipeng321@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: qumingguang <qumingguang@huawei.com>

we should use free_irq to free the nic irq during the unloading time.
because we use request_irq to apply it when nic up. It will crash if
up net device after reset the port.
This patch fixes the issue.

Signed-off-by: qumingguang <qumingguang@huawei.com>
Signed-off-by: Lipeng <lipeng321@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
index 681a043..8084fff 100644
--- a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
@@ -2558,9 +2558,8 @@ static int hns3_nic_uninit_vector_data(struct hns3_nic_priv *priv)
 			(void)irq_set_affinity_hint(
 				priv->tqp_vector[i].vector_irq,
 						    NULL);
-			devm_free_irq(&pdev->dev,
-				      priv->tqp_vector[i].vector_irq,
-				      &priv->tqp_vector[i]);
+			free_irq(priv->tqp_vector[i].vector_irq,
+				 &priv->tqp_vector[i]);
 		}
 
 		priv->ring_data[i].ring->irq_init_flag = HNS3_VECTOR_NOT_INITED;
-- 
1.9.1
