From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH 25/28] net: pch_gbe: allow longer for resets
Date: Mon, 30 Nov 2015 16:21:50 +0000
Message-ID: <1448900513-20856-26-git-send-email-paul.burton@imgtec.com>
References: <1448900513-20856-1-git-send-email-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Burton <paul.burton@imgtec.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <linux-mips@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448900513-20856-1-git-send-email-paul.burton@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resets of the EG20T MAC on the MIPS Boston development board take longer
than the 1000 loops that pch_gbe_wait_clr_bit was performing. Bump up
the number of loops.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>
---

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index f2a9a38..f650f45 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -321,7 +321,7 @@ static void pch_gbe_wait_clr_bit(void *reg, u32 bit)
 	u32 tmp;
 
 	/* wait busy */
-	tmp = 1000;
+	tmp = 10000;
 	while ((ioread32(reg) & bit) && --tmp)
 		cpu_relax();
 	if (!tmp)
-- 
2.6.2
