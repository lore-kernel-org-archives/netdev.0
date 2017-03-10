From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net 2/8] net: bcmgenet: correct MIB access of UniMAC RUNT counters
Date: Thu,  9 Mar 2017 16:49:00 -0800
Message-ID: <20170310004906.10553-3-opendmb@gmail.com>
References: <20170310004906.10553-1-opendmb@gmail.com>
Cc: pgynther@google.com, jaedon.shin@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Doug Berger <doug.berger@broadcom.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170310004906.10553-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Doug Berger <doug.berger@broadcom.com>

The gap between the Tx status counters and the Rx RUNT counters is now
being added to allow correct reporting of the registers.

refs #SWLINUX-4311

Fixes: 1c1008c793fa ("net: bcmgenet: add main driver file")
Signed-off-by: Doug Berger <doug.berger@broadcom.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f0fb7eca8eb4..01a172d95328 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -876,13 +876,16 @@ static void bcmgenet_update_mib_counters(struct bcmgenet_priv *priv)
 		case BCMGENET_STAT_NETDEV:
 		case BCMGENET_STAT_SOFT:
 			continue;
-		case BCMGENET_STAT_MIB_RX:
-		case BCMGENET_STAT_MIB_TX:
 		case BCMGENET_STAT_RUNT:
-			if (s->type != BCMGENET_STAT_MIB_RX)
-				offset = BCMGENET_STAT_OFFSET;
+			offset += BCMGENET_STAT_OFFSET;
+			/* fall through */
+		case BCMGENET_STAT_MIB_TX:
+			offset += BCMGENET_STAT_OFFSET;
+			/* fall through */
+		case BCMGENET_STAT_MIB_RX:
 			val = bcmgenet_umac_readl(priv,
 						  UMAC_MIB_START + j + offset);
+			offset = 0;	/* Reset Offset */
 			break;
 		case BCMGENET_STAT_MISC:
 			if (GENET_IS_V1(priv)) {
-- 
2.11.1
