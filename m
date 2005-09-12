From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 16/16] via-rhine: support ETHTOOL_GPERMADDR
Date: Mon, 12 Sep 2005 10:48:58 -0400
Message-ID: <09122005104858.32735@bilbo.tuxdriver.com>
References: <09122005104858.32669@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rl@hellgate.ch, jgarzik@pobox.com, Jon_Wetzel@Dell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751321AbVILPEd@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104858.32669@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for ETHTOOL_GPERMADDR to via-rhine.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/via-rhine.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -814,8 +814,9 @@ static int __devinit rhine_init_one(stru
 
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = ioread8(ioaddr + StationAddr + i);
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
-	if (!is_valid_ether_addr(dev->dev_addr)) {
+	if (!is_valid_ether_addr(dev->perm_addr)) {
 		rc = -EIO;
 		printk(KERN_ERR "Invalid MAC address\n");
 		goto err_out_unmap;
@@ -1829,6 +1830,7 @@ static struct ethtool_ops netdev_ethtool
 	.set_wol		= rhine_set_wol,
 	.get_sg			= ethtool_op_get_sg,
 	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
