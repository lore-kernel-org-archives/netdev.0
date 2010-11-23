From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH] au1000_eth: fix invalid address accessing the MAC enable
 register
Date: Tue, 23 Nov 2010 17:40:25 +0100
Message-ID: <4CEBEE79.8040507@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux-MIPS <linux-mips@linux-mips.org>,
	Florian Fainelli <florian@openwrt.org>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"aup->enable" holds already the address pointing to the MAC enable
register. The bug was introduced by commit d0e7cb:

"au1000-eth: remove volatiles, switch to I/O accessors".

CC: Florian Fainelli <florian@openwrt.org>
Signed-off-by: Wolfgang Grandegger <wg@denx.de>
Acked-by: Florian Fainelli <florian@openwrt.org>

---
 drivers/net/au1000_eth.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 43489f8..53eff9b 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -155,10 +155,10 @@ static void au1000_enable_mac(struct net_device *dev, int force_reset)
 	spin_lock_irqsave(&aup->lock, flags);
 
 	if (force_reset || (!aup->mac_enabled)) {
-		writel(MAC_EN_CLOCK_ENABLE, &aup->enable);
+		writel(MAC_EN_CLOCK_ENABLE, aup->enable);
 		au_sync_delay(2);
 		writel((MAC_EN_RESET0 | MAC_EN_RESET1 | MAC_EN_RESET2
-				| MAC_EN_CLOCK_ENABLE), &aup->enable);
+				| MAC_EN_CLOCK_ENABLE), aup->enable);
 		au_sync_delay(2);
 
 		aup->mac_enabled = 1;
@@ -503,9 +503,9 @@ static void au1000_reset_mac_unlocked(struct net_device *dev)
 
 	au1000_hard_stop(dev);
 
-	writel(MAC_EN_CLOCK_ENABLE, &aup->enable);
+	writel(MAC_EN_CLOCK_ENABLE, aup->enable);
 	au_sync_delay(2);
-	writel(0, &aup->enable);
+	writel(0, aup->enable);
 	au_sync_delay(2);
 
 	aup->tx_full = 0;
@@ -1119,7 +1119,7 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 	/* set a random MAC now in case platform_data doesn't provide one */
 	random_ether_addr(dev->dev_addr);
 
-	writel(0, &aup->enable);
+	writel(0, aup->enable);
 	aup->mac_enabled = 0;
 
 	pd = pdev->dev.platform_data;
-- 
1.7.2.3

