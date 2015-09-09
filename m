From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 3/4] net: mv643xx_eth: use kzalloc
Date: Wed,  9 Sep 2015 10:38:04 +0200
Message-ID: <1441787886-7214-4-git-send-email-linux@rasmusvillemoes.dk>
References: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The double memset is a little ugly; using kzalloc avoids it altogether.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index d52639bc491f..960169efe636 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1859,14 +1859,11 @@ oom:
 		return;
 	}
 
-	mc_spec = kmalloc(0x200, GFP_ATOMIC);
+	mc_spec = kzalloc(0x200, GFP_ATOMIC);
 	if (mc_spec == NULL)
 		goto oom;
 	mc_other = mc_spec + (0x100 >> 2);
 
-	memset(mc_spec, 0, 0x100);
-	memset(mc_other, 0, 0x100);
-
 	netdev_for_each_mc_addr(ha, dev) {
 		u8 *a = ha->addr;
 		u32 *table;
-- 
2.1.3
