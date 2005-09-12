From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 11/16] pcnet32: support ETHTOOL_GPERMADDR
Date: Mon, 12 Sep 2005 10:48:57 -0400
Message-ID: <09122005104857.32412@bilbo.tuxdriver.com>
References: <09122005104857.32349@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tsbogend@alpha.franken.de, jgarzik@pobox.com, Jon_Wetzel@Dell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751335AbVILPH5@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104857.32349@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for ETHTOOL_GPERMADDR to pcnet32.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/pcnet32.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -957,6 +957,7 @@ static struct ethtool_ops pcnet32_ethtoo
     .phys_id		= pcnet32_phys_id,
     .get_regs_len	= pcnet32_get_regs_len,
     .get_regs		= pcnet32_get_regs,
+    .get_perm_addr	= ethtool_op_get_perm_addr,
 };
 
 /* only probes for non-PCI devices, the rest are handled by
@@ -1185,9 +1186,10 @@ pcnet32_probe1(unsigned long ioaddr, int
 	    memcpy(dev->dev_addr, promaddr, 6);
 	}
     }
+    memcpy(dev->perm_addr, dev->dev_addr, dev->addr_len);
 
     /* if the ethernet address is not valid, force to 00:00:00:00:00:00 */
-    if (!is_valid_ether_addr(dev->dev_addr))
+    if (!is_valid_ether_addr(dev->perm_addr))
 	memset(dev->dev_addr, 0, sizeof(dev->dev_addr));
 
     if (pcnet32_debug & NETIF_MSG_PROBE) {
