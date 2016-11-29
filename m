From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v3 net-next 4/6] net: mvneta: Only disable mvneta_bm for
 64-bits
Date: Tue, 29 Nov 2016 10:37:24 +0100
Message-ID: <040255efd08ba2497ab28edae78ca5e1835d5824.1480412215.git-series.gregory.clement@free-electrons.com>
References: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jisheng Zhang <jszhang@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Dmitri Epshtein <dima@marvell.com>, Nadav Haklai <nadavh@marvell.com>,
 Yelena Krivosheev <yelena@marvell.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Marcin Wojtas <mw@semihalf.com>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
References: <cover.a09aeaf5ba62853d595153626b6121ef52a3e9b4.1480412215.git-series.gregory.clement@free-electrons.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Actually only the mvneta_bm support is not 64-bits compatible.
The mvneta code itself can run on 64-bits architecture.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/Kconfig | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 66fd9dbb2ca7..2ccea9dd9248 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -44,6 +44,7 @@ config MVMDIO
 config MVNETA_BM_ENABLE
 	tristate "Marvell Armada 38x/XP network interface BM support"
 	depends on MVNETA
+	depends on !64BIT
 	---help---
 	  This driver supports auxiliary block of the network
 	  interface units in the Marvell ARMADA XP and ARMADA 38x SoC
@@ -58,7 +59,6 @@ config MVNETA
 	tristate "Marvell Armada 370/38x/XP network interface support"
 	depends on PLAT_ORION || COMPILE_TEST
 	depends on HAS_DMA
-	depends on !64BIT
 	select MVMDIO
 	select FIXED_PHY
 	---help---
@@ -71,6 +71,7 @@ config MVNETA
 
 config MVNETA_BM
 	tristate
+	depends on !64BIT
 	default y if MVNETA=y && MVNETA_BM_ENABLE!=n
 	default MVNETA_BM_ENABLE
 	select HWBM
-- 
git-series 0.8.10
