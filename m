From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net 3/3] net: mvpp2: do not sleep in set_rx_mode
Date: Tue, 24 Oct 2017 11:41:28 +0200
Message-ID: <20171024094128.24433-3-antoine.tenart@free-electrons.com>
References: <20171024094128.24433-1-antoine.tenart@free-electrons.com>
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024094128.24433-1-antoine.tenart@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch replaces GFP_KERNEL by GFP_ATOMIC to avoid sleeping in the
ndo_set_rx_mode() call which is called with BH disabled.

Fixes: 3f518509dedc ("ethernet: Add new driver for Marvell Armada 375 network unit")
Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 5aa57c035ed8..a3231fe98384 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -3396,7 +3396,7 @@ mvpp2_prs_mac_da_range_find(struct mvpp2 *priv, int pmap, const u8 *da,
 	struct mvpp2_prs_entry *pe;
 	int tid;
 
-	pe = kzalloc(sizeof(*pe), GFP_KERNEL);
+	pe = kzalloc(sizeof(*pe), GFP_ATOMIC);
 	if (!pe)
 		return NULL;
 	mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_MAC);
@@ -3458,7 +3458,7 @@ static int mvpp2_prs_mac_da_accept(struct mvpp2 *priv, int port,
 		if (tid < 0)
 			return tid;
 
-		pe = kzalloc(sizeof(*pe), GFP_KERNEL);
+		pe = kzalloc(sizeof(*pe), GFP_ATOMIC);
 		if (!pe)
 			return -ENOMEM;
 		mvpp2_prs_tcam_lu_set(pe, MVPP2_PRS_LU_MAC);
-- 
2.14.2
