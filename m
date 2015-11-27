From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v3 net 3/6] net: mvneta: fix bit assignment for RX packet irq enable
Date: Fri, 27 Nov 2015 16:44:23 +0100
Message-ID: <1448639066-13074-4-git-send-email-mw@semihalf.com>
References: <1448639066-13074-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448639066-13074-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A value originally defined in the driver was inappropriate. Even though
the ingress was somehow working, writing MVNETA_RXQ_INTR_ENABLE_ALL_MASK
to MVNETA_INTR_ENABLE didn't make any effect, because the bits [31:16]
are reserved and read-only.

This commit updates MVNETA_RXQ_INTR_ENABLE_ALL_MASK to be compliant with
the controller's documentation.

Signed-off-by: Marcin Wojtas <mw@semihalf.com>

Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network
unit")
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 64c46f0..5dffb68 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -160,7 +160,7 @@
 
 #define MVNETA_INTR_ENABLE                       0x25b8
 #define      MVNETA_TXQ_INTR_ENABLE_ALL_MASK     0x0000ff00
-#define      MVNETA_RXQ_INTR_ENABLE_ALL_MASK     0xff000000  // note: neta says it's 0x000000FF
+#define      MVNETA_RXQ_INTR_ENABLE_ALL_MASK     0x000000ff
 
 #define MVNETA_RXQ_CMD                           0x2680
 #define      MVNETA_RXQ_DISABLE_SHIFT            8
-- 
1.8.3.1
