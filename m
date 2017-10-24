From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH net 2/3] net: mvpp2: fix invalid parameters order when calling the tcam init
Date: Tue, 24 Oct 2017 11:41:27 +0200
Message-ID: <20171024094128.24433-2-antoine.tenart@free-electrons.com>
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

When calling mvpp2_prs_mac_multi_set() from mvpp2_prs_mac_init(), two
parameters (the port index and the table index) are inverted. Fixes
this.

Fixes: 3f518509dedc ("ethernet: Add new driver for Marvell Armada 375 network unit")
Signed-off-by: Antoine Tenart <antoine.tenart@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvpp2.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 2b79b570f4e5..5aa57c035ed8 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -2614,8 +2614,8 @@ static void mvpp2_prs_mac_init(struct mvpp2 *priv)
 	/* place holders only - no ports */
 	mvpp2_prs_mac_drop_all_set(priv, 0, false);
 	mvpp2_prs_mac_promisc_set(priv, 0, false);
-	mvpp2_prs_mac_multi_set(priv, MVPP2_PE_MAC_MC_ALL, 0, false);
-	mvpp2_prs_mac_multi_set(priv, MVPP2_PE_MAC_MC_IP6, 0, false);
+	mvpp2_prs_mac_multi_set(priv, 0, MVPP2_PE_MAC_MC_ALL, false);
+	mvpp2_prs_mac_multi_set(priv, 0, MVPP2_PE_MAC_MC_IP6, false);
 }
 
 /* Set default entries for various types of dsa packets */
-- 
2.14.2
