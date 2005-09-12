From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 14/16] sundance: support ETHTOOL_GPERMADDR
Date: Mon, 12 Sep 2005 10:48:58 -0400
Message-ID: <09122005104858.32604@bilbo.tuxdriver.com>
References: <09122005104857.32541@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, Jon_Wetzel@Dell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751330AbVILO6Y@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104857.32541@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for ETHTOOL_GPERMADDR to sundance.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/sundance.c |    2 ++
 1 files changed, 2 insertions(+)

diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -549,6 +549,7 @@ static int __devinit sundance_probe1 (st
 	for (i = 0; i < 3; i++)
 		((u16 *)dev->dev_addr)[i] =
 			le16_to_cpu(eeprom_read(ioaddr, i + EEPROM_SA_OFFSET));
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	dev->base_addr = (unsigned long)ioaddr;
 	dev->irq = irq;
@@ -1619,6 +1620,7 @@ static struct ethtool_ops ethtool_ops = 
 	.get_link = get_link,
 	.get_msglevel = get_msglevel,
 	.set_msglevel = set_msglevel,
+	.get_perm_addr = ethtool_op_get_perm_addr,
 };
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
