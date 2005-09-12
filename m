From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 2/16] 8139cp: support ETHTOOL_GPERMADDR
Date: Mon, 12 Sep 2005 10:48:54 -0400
Message-ID: <09122005104854.31837@bilbo.tuxdriver.com>
References: <09122005104854.31772@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, Jon_Wetzel@Dell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751318AbVILO5j@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104854.31772@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for ETHTOOL_GPERMADDR to 8139cp.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/8139cp.c |    2 ++
 1 files changed, 2 insertions(+)

diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -1575,6 +1575,7 @@ static struct ethtool_ops cp_ethtool_ops
 	.set_wol		= cp_set_wol,
 	.get_strings		= cp_get_strings,
 	.get_ethtool_stats	= cp_get_ethtool_stats,
+	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
 static int cp_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
@@ -1773,6 +1774,7 @@ static int cp_init_one (struct pci_dev *
 	for (i = 0; i < 3; i++)
 		((u16 *) (dev->dev_addr))[i] =
 		    le16_to_cpu (read_eeprom (regs, i + 7, addr_len));
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	dev->open = cp_open;
 	dev->stop = cp_close;
