From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 1/16] 3c59x: support ETHTOOL_GPERMADDR
Date: Mon, 12 Sep 2005 10:48:54 -0400
Message-ID: <09122005104854.31772@bilbo.tuxdriver.com>
References: <09122005104853.31717@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jgarzik@pobox.com, Jon_Wetzel@Dell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751365AbVILO7J@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104853.31717@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for ETHTOOL_GPERMADDR to 3c59x.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/3c59x.c |    2 ++
 1 files changed, 2 insertions(+)

diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1338,6 +1338,7 @@ static int __devinit vortex_probe1(struc
 		printk(" ***INVALID CHECKSUM %4.4x*** ", checksum);
 	for (i = 0; i < 3; i++)
 		((u16 *)dev->dev_addr)[i] = htons(eeprom[i + 10]);
+	memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 	if (print_info) {
 		for (i = 0; i < 6; i++)
 			printk("%c%2.2x", i ? ':' : ' ', dev->dev_addr[i]);
@@ -3047,6 +3048,7 @@ static struct ethtool_ops vortex_ethtool
 	.set_settings           = vortex_set_settings,
 	.get_link               = vortex_get_link,
 	.nway_reset             = vortex_nway_reset,
+	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
 #ifdef CONFIG_PCI
