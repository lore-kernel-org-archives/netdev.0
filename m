From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 12/16] r8169: support ETHTOOL_GPERMADDR
Date: Mon, 12 Sep 2005 10:48:57 -0400
Message-ID: <09122005104857.32477@bilbo.tuxdriver.com>
References: <09122005104857.32412@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, jgarzik@pobox.com, Jon_Wetzel@Dell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751348AbVILPF2@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104857.32412@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for ETHTOOL_GPERMADDR to r8169.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/r8169.c |    2 ++
 1 files changed, 2 insertions(+)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1028,6 +1028,7 @@ static struct ethtool_ops rtl8169_ethtoo
 	.get_strings		= rtl8169_get_strings,
 	.get_stats_count	= rtl8169_get_stats_count,
 	.get_ethtool_stats	= rtl8169_get_ethtool_stats,
+	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
 static void rtl8169_write_gmii_reg_bit(void __iomem *ioaddr, int reg, int bitnum,
@@ -1512,6 +1513,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	/* Get MAC address.  FIXME: read EEPROM */
 	for (i = 0; i < MAC_ADDR_LEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
 	dev->open = rtl8169_open;
 	dev->hard_start_xmit = rtl8169_start_xmit;
