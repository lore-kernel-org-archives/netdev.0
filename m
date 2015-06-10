From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 linux-next] net/ibm/emac: use swap() in emac_make_bootlist()
Date: Wed, 10 Jun 2015 18:33:16 +0200
Message-ID: <1433953997-24693-1-git-send-email-fabf@skynet.be>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use kernel.h macro definition.

Thanks to Julia Lawall for Coccinelle scripting support.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/ibm/emac/core.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/core.c b/drivers/net/ethernet/ibm/emac/core.c
index b9df0cb..b60a34d 100644
--- a/drivers/net/ethernet/ibm/emac/core.c
+++ b/drivers/net/ethernet/ibm/emac/core.c
@@ -2999,7 +2999,7 @@ static struct platform_driver emac_driver = {
 static void __init emac_make_bootlist(void)
 {
 	struct device_node *np = NULL;
-	int j, max, i = 0, k;
+	int j, max, i = 0;
 	int cell_indices[EMAC_BOOT_LIST_SIZE];
 
 	/* Collect EMACs */
@@ -3026,12 +3026,8 @@ static void __init emac_make_bootlist(void)
 	for (i = 0; max > 1 && (i < (max - 1)); i++)
 		for (j = i; j < max; j++) {
 			if (cell_indices[i] > cell_indices[j]) {
-				np = emac_boot_list[i];
-				emac_boot_list[i] = emac_boot_list[j];
-				emac_boot_list[j] = np;
-				k = cell_indices[i];
-				cell_indices[i] = cell_indices[j];
-				cell_indices[j] = k;
+				swap(emac_boot_list[i], emac_boot_list[j]);
+				swap(cell_indices[i], cell_indices[j]);
 			}
 		}
 }
-- 
2.4.2
