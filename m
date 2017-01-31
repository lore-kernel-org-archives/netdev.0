From: Colin King <colin.king@canonical.com>
Subject: [PATCH][net-next] sfc: fix an off-by-one compare on an array size
Date: Tue, 31 Jan 2017 16:30:02 +0000
Message-ID: <20170131163002.20882-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

encap_type should be checked to see if it is greater or equal to
the size of array map to fix an off-by-one array size check. This
fixes an array overrun read as detected by static analysis by
CoverityScan, CID#1398883 ("Out-of-bounds-read")

Fixes: 9b41080125176841e ("sfc: insert catch-all filters for encapsulated traffic")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/sfc/ef10.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 8bec938..0475f18 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -5080,7 +5080,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 
 		/* quick bounds check (BCAST result impossible) */
 		BUILD_BUG_ON(EFX_EF10_BCAST != 0);
-		if (encap_type > ARRAY_SIZE(map) || map[encap_type] == 0) {
+		if (encap_type >= ARRAY_SIZE(map) || map[encap_type] == 0) {
 			WARN_ON(1);
 			return -EINVAL;
 		}
-- 
2.10.2
