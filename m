From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 06/19] net: hns: fix the error info when
 dma_set_mask_and_coherent fail
Date: Tue, 21 Jun 2016 11:56:26 +0800
Message-ID: <1466481399-70080-7-git-send-email-Yisen.Zhuang@huawei.com>
References: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, andrew@lunn.ch, fengguang.wu@intel.com,
 liguozhu@huawei.com, arnd@arndb.de, charles.chenxin@huawei.com,
 linux-kernel@vger.kernel.org, linuxarm@huawei.com, geliangtang@163.com,
 huangdaode@hisilicon.com, netdev@vger.kernel.org,
 andriy.shevchenko@linux.intel.com, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <yankejian@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1466481399-70080-1-git-send-email-Yisen.Zhuang@huawei.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Qianqian Xie <xieqianqian@huawei.com>

The error info should be printed as "set mask to 64bit fail!" instead of
"set mask to 32bit fail!" in dma_set_mask_and_coherent().

Signed-off-by: Qianqian Xie <xieqianqian@huawei.com>
Signed-off-by: Yisen Zhuang <Yisen.Zhuang@huawei.com>
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index b978db4..00e529f 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1972,7 +1972,7 @@ static int hns_nic_dev_probe(struct platform_device *pdev)
 	if (!dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64)))
 		dev_dbg(dev, "set mask to 64bit\n");
 	else
-		dev_err(dev, "set mask to 32bit fail!\n");
+		dev_err(dev, "set mask to 64bit fail!\n");
 
 	/* carrier off reporting is important to ethtool even BEFORE open */
 	netif_carrier_off(ndev);
-- 
1.9.1
