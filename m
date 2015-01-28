From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch net-next] hisilicon: add some missing curly braces
Date: Wed, 28 Jan 2015 21:58:33 +0300
Message-ID: <20150128185833.GA10259@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dingtianhong <dingtianhong@huawei.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The if block was supposed to have curly braces.  In the current code we
complain about dropped rx packets when we shouldn't.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index 525214e..c02b81b 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -567,10 +567,11 @@ static irqreturn_t hip04_mac_interrupt(int irq, void *dev_id)
 	writel_relaxed(DEF_INT_MASK, priv->base + PPE_RINT);
 
 	if (unlikely(ists & DEF_INT_ERR)) {
-		if (ists & (RCV_NOBUF | RCV_DROP))
+		if (ists & (RCV_NOBUF | RCV_DROP)) {
 			stats->rx_errors++;
 			stats->rx_dropped++;
 			netdev_err(ndev, "rx drop\n");
+		}
 		if (ists & TX_DROP) {
 			stats->tx_dropped++;
 			netdev_err(ndev, "tx drop\n");
