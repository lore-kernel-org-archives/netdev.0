From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH v2 6/6] net: pch_gbe: Allow longer for resets
Date: Wed, 3 Feb 2016 12:02:44 +0000
Message-ID: <1454500964-6256-7-git-send-email-paul.burton@imgtec.com>
References: <1454500964-6256-1-git-send-email-paul.burton@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Burton <paul.burton@imgtec.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <linux-mips@linux-mips.org>, Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454500964-6256-1-git-send-email-paul.burton@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Resets of the EG20T MAC on the MIPS Boston development board take longer
than the 1000 loops that pch_gbe_wait_clr_bit was performing. Bump up
the number of loops.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>

---

Changes in v2: None

 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 00ef83c..87994d2 100644
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
2.7.0
