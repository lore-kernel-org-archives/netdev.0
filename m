From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2 net-next] sfc: fix an off by one bug
Date: Tue, 7 Feb 2017 10:44:31 +0300
Message-ID: <20170207074431.GA18377@mwanda>
References: <60d163b6-0b49-172f-288c-e1712e04a84e@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bert Kenward <bkenward@solarflare.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Edward Cree <ecree@solarflare.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <60d163b6-0b49-172f-288c-e1712e04a84e@solarflare.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This bug is harmless because it's just a sanity check and we always
pass valid values for "encap_type" but the test is off by one.

Fixes: 9b4108012517 ("sfc: insert catch-all filters for encapsulated traffic")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: Rebased against last linux-next

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 0475f1831b92..dec0c8083ff3 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -5134,7 +5134,7 @@ static int efx_ef10_filter_insert_def(struct efx_nic *efx,
 
 		/* quick bounds check (BCAST result impossible) */
 		BUILD_BUG_ON(EFX_EF10_BCAST != 0);
-		if (encap_type > ARRAY_SIZE(map) || map[encap_type] == 0) {
+		if (encap_type >= ARRAY_SIZE(map) || map[encap_type] == 0) {
 			WARN_ON(1);
 			return -EINVAL;
 		}
