From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 13/22] net: Fix dependencies for !HAS_IOMEM archs
Date: Mon, 25 Jan 2016 23:24:12 +0100
Message-ID: <1453760661-1444-14-git-send-email-richard@nod.at>
References: <1453760661-1444-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	user-mode-linux-devel@lists.sourceforge.net,
	Richard Weinberger <richard@nod.at>,
	Alexey Brodkin <abrodkin@synopsys.com>,
	Tal Zilcer <talz@ezchip.com>, Noam Camus <noamc@ezchip.com>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <user-mode-linux-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1453760661-1444-1-git-send-email-richard@nod.at>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/user-mode-linux-devel>,
	<mailto:user-mode-linux-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=user-mode-linux-devel>
List-Post: <mailto:user-mode-linux-devel@lists.sourceforge.net>
List-Help: <mailto:user-mode-linux-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/user-mode-linux-devel>,
	<mailto:user-mode-linux-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: user-mode-linux-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Not every arch has io memory.
So, unbreak the build by fixing the dependencies.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 drivers/net/ethernet/ezchip/Kconfig | 1 +
 drivers/net/phy/Kconfig             | 1 +
 2 files changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ezchip/Kconfig b/drivers/net/ethernet/ezchip/Kconfig
index 48ecbc8..b423ad3 100644
--- a/drivers/net/ethernet/ezchip/Kconfig
+++ b/drivers/net/ethernet/ezchip/Kconfig
@@ -18,6 +18,7 @@ if NET_VENDOR_EZCHIP
 config EZCHIP_NPS_MANAGEMENT_ENET
 	tristate "EZchip NPS management enet support"
 	depends on OF_IRQ && OF_NET
+	depends on HAS_IOMEM
 	---help---
 	  Simple LAN device for debug or management purposes.
 	  Device supports interrupts for RX and TX(completion).
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index 60994a8..f0a7702 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -186,6 +186,7 @@ config MDIO_GPIO
 config MDIO_OCTEON
 	tristate "Support for MDIO buses on Octeon and ThunderX SOCs"
 	depends on 64BIT
+	depends on HAS_IOMEM
 	help
 
 	  This module provides a driver for the Octeon and ThunderX MDIO
-- 
1.8.4.5


------------------------------------------------------------------------------
Site24x7 APM Insight: Get Deep Visibility into Application Performance
APM + Mobile APM + RUM: Monitor 3 App instances at just $35/Month
Monitor end-to-end web transactions and take corrective actions now
Troubleshoot faster and improve end-user experience. Signup Now!
http://pubads.g.doubleclick.net/gampad/clk?id=267308311&iu=/4140
