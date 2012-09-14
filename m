From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 24/24] net: seeq: use __iomem pointers for MMIO
Date: Fri, 14 Sep 2012 23:34:52 +0200
Message-ID: <1347658492-11608-25-git-send-email-arnd@arndb.de>
References: <1347658492-11608-1-git-send-email-arnd@arndb.de>
Cc: linux-kernel@vger.kernel.org, Will Deacon <will.deacon@arm.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Nicolas Pitre <nico@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1347658492-11608-1-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ARM is moving to stricter checks on readl/write functions,
so we need to use the correct types everywhere.

Cc: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/seeq/ether3.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index df808ac..6a40dd0 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -99,13 +99,13 @@ typedef enum {
  * The SEEQ8005 doesn't like us writing to its registers
  * too quickly.
  */
-static inline void ether3_outb(int v, const void __iomem *r)
+static inline void ether3_outb(int v, void __iomem *r)
 {
 	writeb(v, r);
 	udelay(1);
 }
 
-static inline void ether3_outw(int v, const void __iomem *r)
+static inline void ether3_outw(int v, void __iomem *r)
 {
 	writew(v, r);
 	udelay(1);
-- 
1.7.10
