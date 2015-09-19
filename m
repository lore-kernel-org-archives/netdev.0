From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 14/15] RDS: use max_mr from HCA caps than max_fmr
Date: Sat, 19 Sep 2015 19:04:51 -0400
Message-ID: <1442703892-26692-15-git-send-email-santosh.shilimkar@oracle.com>
References: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442703892-26692-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Santosh Shilimkar <ssantosh@kernel.org>

All HCA drivers seems to popullate max_mr caps and few of
them do both max_mr and max_fmr.

Hence update RDS code to make use of max_mr.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 2d3f2ab..883813a 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -148,8 +148,8 @@ static void rds_ib_add_one(struct ib_device *device)
 	rds_ibdev->max_sge = min(dev_attr->max_sge, RDS_IB_MAX_SGE);
 
 	rds_ibdev->fmr_max_remaps = dev_attr->max_map_per_fmr?: 32;
-	rds_ibdev->max_fmrs = dev_attr->max_fmr ?
-			min_t(unsigned int, dev_attr->max_fmr, fmr_pool_size) :
+	rds_ibdev->max_fmrs = dev_attr->max_mr ?
+			min_t(unsigned int, dev_attr->max_mr, fmr_pool_size) :
 			fmr_pool_size;
 
 	rds_ibdev->max_initiator_depth = dev_attr->max_qp_init_rd_atom;
-- 
1.9.1
