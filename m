From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/22] sky2: Use pci_zalloc_consistent
Date: Mon, 23 Jun 2014 06:41:39 -0700
Message-ID: <7d711e89ab42c3b92f59479c6eac2f3a8e49afc7.1403530604.git.joe@perches.com>
References: <cover.1403530604.git.joe@perches.com>
Cc: Mirko Lindner <mlindner@marvell.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1403530604.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the now unnecessary memset too.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/marvell/sky2.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index 6969338..5991514 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -1622,11 +1622,10 @@ static int sky2_alloc_buffers(struct sky2_port *sky2)
 	if (!sky2->tx_ring)
 		goto nomem;
 
-	sky2->rx_le = pci_alloc_consistent(hw->pdev, RX_LE_BYTES,
-					   &sky2->rx_le_map);
+	sky2->rx_le = pci_zalloc_consistent(hw->pdev, RX_LE_BYTES,
+					    &sky2->rx_le_map);
 	if (!sky2->rx_le)
 		goto nomem;
-	memset(sky2->rx_le, 0, RX_LE_BYTES);
 
 	sky2->rx_ring = kcalloc(sky2->rx_pending, sizeof(struct rx_ring_info),
 				GFP_KERNEL);
-- 
1.8.1.2.459.gbcd45b4.dirty
