From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.13 4/16] b44: support ETHTOOL_GPERMADDR
Date: Mon, 12 Sep 2005 10:48:55 -0400
Message-ID: <09122005104855.31965@bilbo.tuxdriver.com>
References: <09122005104855.31900@bilbo.tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, Jon_Wetzel@Dell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751388AbVILPDe@vger.kernel.org>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
In-Reply-To: <09122005104855.31900@bilbo.tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add support for ETHTOOL_GPERMADDR to b44.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/b44.c |    2 ++
 1 files changed, 2 insertions(+)

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1676,6 +1676,7 @@ static struct ethtool_ops b44_ethtool_op
 	.set_pauseparam		= b44_set_pauseparam,
 	.get_msglevel		= b44_get_msglevel,
 	.set_msglevel		= b44_set_msglevel,
+	.get_perm_addr		= ethtool_op_get_perm_addr,
 };
 
 static int b44_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
@@ -1718,6 +1719,7 @@ static int __devinit b44_get_invariants(
 	bp->dev->dev_addr[3] = eeprom[80];
 	bp->dev->dev_addr[4] = eeprom[83];
 	bp->dev->dev_addr[5] = eeprom[82];
+	memcpy(bp->dev->perm_addr, bp->dev->dev_addr, bp->dev->addr_len);
 
 	bp->phy_addr = eeprom[90] & 0x1f;
 
