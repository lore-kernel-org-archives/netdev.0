From: Colin King <colin.king@canonical.com>
Subject: [PATCH] liquidio: remove redundant setting of inst_processed to zero
Date: Wed,  1 Nov 2017 09:09:13 +0000
Message-ID: <20171101090913.16215-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The zero value assigned to inst_processed at the end of each
iteration of the do-while loop is overwritten on the next iteration
and hence it is a redundant assignment and can be removed. Cleans
up clang warning:

drivers/net/ethernet/cavium/liquidio/request_manager.c:480:3:
warning: Value stored to 'inst_processed' is never read

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/cavium/liquidio/request_manager.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 1e0fbce86d60..11aaa35e45ab 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -477,8 +477,6 @@ octeon_flush_iq(struct octeon_device *oct, struct octeon_instr_queue *iq,
 		}
 
 		tot_inst_processed += inst_processed;
-		inst_processed = 0;
-
 	} while (tot_inst_processed < napi_budget);
 
 	if (napi_budget && (tot_inst_processed >= napi_budget))
-- 
2.14.1
