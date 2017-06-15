From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 01/15] net/mlx5: Update eqe_type_str() event names
Date: Thu, 15 Jun 2017 16:49:12 -0700
Message-ID: <1497570552.14396.30.camel@perches.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
         <20170615214252.30140-2-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>
To: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0051.hostedemail.com ([216.40.44.51]:47961 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751644AbdFOXtR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 19:49:17 -0400
In-Reply-To: <20170615214252.30140-2-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-06-16 at 00:42 +0300, Saeed Mahameed wrote:
> From: Eli Cohen <eli@mellanox.com>
> 
> Add missing NIC_VPORT_CHANGE event.
> 
> Signed-off-by: Eli Cohen <eli@mellanox.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx5/core/eq.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
> index 0ed8e90ba54f..23048247d827 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
> @@ -157,6 +157,8 @@ static const char *eqe_type_str(u8 type)
>  		return "MLX5_EVENT_TYPE_PAGE_FAULT";
>  	case MLX5_EVENT_TYPE_PPS_EVENT:
>  		return "MLX5_EVENT_TYPE_PPS_EVENT";
> +	case MLX5_EVENT_TYPE_NIC_VPORT_CHANGE:
> +		return "MLX5_EVENT_TYPE_NIC_VPORT_CHANGE";
>  	case MLX5_EVENT_TYPE_FPGA_ERROR:
>  		return "MLX5_EVENT_TYPE_FPGA_ERROR";
>  	default:

Maybe one day convert this to use a macro
to reduce the case/string duplication.

Maybe what ath9k uses:
---
 drivers/net/ethernet/mellanox/mlx5/core/eq.c | 74 ++++++++++------------------
 1 file changed, 26 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 0ed8e90ba54f..3e79de07c3ee 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -110,55 +110,33 @@ static struct mlx5_eqe *next_eqe_sw(struct mlx5_eq *eq)
 
 static const char *eqe_type_str(u8 type)
 {
+#define case_rtn_string(val) case val: return #val
 	switch (type) {
-	case MLX5_EVENT_TYPE_COMP:
-		return "MLX5_EVENT_TYPE_COMP";
-	case MLX5_EVENT_TYPE_PATH_MIG:
-		return "MLX5_EVENT_TYPE_PATH_MIG";
-	case MLX5_EVENT_TYPE_COMM_EST:
-		return "MLX5_EVENT_TYPE_COMM_EST";
-	case MLX5_EVENT_TYPE_SQ_DRAINED:
-		return "MLX5_EVENT_TYPE_SQ_DRAINED";
-	case MLX5_EVENT_TYPE_SRQ_LAST_WQE:
-		return "MLX5_EVENT_TYPE_SRQ_LAST_WQE";
-	case MLX5_EVENT_TYPE_SRQ_RQ_LIMIT:
-		return "MLX5_EVENT_TYPE_SRQ_RQ_LIMIT";
-	case MLX5_EVENT_TYPE_CQ_ERROR:
-		return "MLX5_EVENT_TYPE_CQ_ERROR";
-	case MLX5_EVENT_TYPE_WQ_CATAS_ERROR:
-		return "MLX5_EVENT_TYPE_WQ_CATAS_ERROR";
-	case MLX5_EVENT_TYPE_PATH_MIG_FAILED:
-		return "MLX5_EVENT_TYPE_PATH_MIG_FAILED";
-	case MLX5_EVENT_TYPE_WQ_INVAL_REQ_ERROR:
-		return "MLX5_EVENT_TYPE_WQ_INVAL_REQ_ERROR";
-	case MLX5_EVENT_TYPE_WQ_ACCESS_ERROR:
-		return "MLX5_EVENT_TYPE_WQ_ACCESS_ERROR";
-	case MLX5_EVENT_TYPE_SRQ_CATAS_ERROR:
-		return "MLX5_EVENT_TYPE_SRQ_CATAS_ERROR";
-	case MLX5_EVENT_TYPE_INTERNAL_ERROR:
-		return "MLX5_EVENT_TYPE_INTERNAL_ERROR";
-	case MLX5_EVENT_TYPE_PORT_CHANGE:
-		return "MLX5_EVENT_TYPE_PORT_CHANGE";
-	case MLX5_EVENT_TYPE_GPIO_EVENT:
-		return "MLX5_EVENT_TYPE_GPIO_EVENT";
-	case MLX5_EVENT_TYPE_PORT_MODULE_EVENT:
-		return "MLX5_EVENT_TYPE_PORT_MODULE_EVENT";
-	case MLX5_EVENT_TYPE_REMOTE_CONFIG:
-		return "MLX5_EVENT_TYPE_REMOTE_CONFIG";
-	case MLX5_EVENT_TYPE_DB_BF_CONGESTION:
-		return "MLX5_EVENT_TYPE_DB_BF_CONGESTION";
-	case MLX5_EVENT_TYPE_STALL_EVENT:
-		return "MLX5_EVENT_TYPE_STALL_EVENT";
-	case MLX5_EVENT_TYPE_CMD:
-		return "MLX5_EVENT_TYPE_CMD";
-	case MLX5_EVENT_TYPE_PAGE_REQUEST:
-		return "MLX5_EVENT_TYPE_PAGE_REQUEST";
-	case MLX5_EVENT_TYPE_PAGE_FAULT:
-		return "MLX5_EVENT_TYPE_PAGE_FAULT";
-	case MLX5_EVENT_TYPE_PPS_EVENT:
-		return "MLX5_EVENT_TYPE_PPS_EVENT";
-	case MLX5_EVENT_TYPE_FPGA_ERROR:
-		return "MLX5_EVENT_TYPE_FPGA_ERROR";
+	case_rtn_string(MLX5_EVENT_TYPE_COMP);
+	case_rtn_string(MLX5_EVENT_TYPE_PATH_MIG);
+	case_rtn_string(MLX5_EVENT_TYPE_COMM_EST);
+	case_rtn_string(MLX5_EVENT_TYPE_SQ_DRAINED);
+	case_rtn_string(MLX5_EVENT_TYPE_SRQ_LAST_WQE);
+	case_rtn_string(MLX5_EVENT_TYPE_SRQ_RQ_LIMIT);
+	case_rtn_string(MLX5_EVENT_TYPE_CQ_ERROR);
+	case_rtn_string(MLX5_EVENT_TYPE_WQ_CATAS_ERROR);
+	case_rtn_string(MLX5_EVENT_TYPE_PATH_MIG_FAILED);
+	case_rtn_string(MLX5_EVENT_TYPE_WQ_INVAL_REQ_ERROR);
+	case_rtn_string(MLX5_EVENT_TYPE_WQ_ACCESS_ERROR);
+	case_rtn_string(MLX5_EVENT_TYPE_SRQ_CATAS_ERROR);
+	case_rtn_string(MLX5_EVENT_TYPE_INTERNAL_ERROR);
+	case_rtn_string(MLX5_EVENT_TYPE_PORT_CHANGE);
+	case_rtn_string(MLX5_EVENT_TYPE_GPIO_EVENT);
+	case_rtn_string(MLX5_EVENT_TYPE_PORT_MODULE_EVENT);
+	case_rtn_string(MLX5_EVENT_TYPE_REMOTE_CONFIG);
+	case_rtn_string(MLX5_EVENT_TYPE_DB_BF_CONGESTION);
+	case_rtn_string(MLX5_EVENT_TYPE_STALL_EVENT);
+	case_rtn_string(MLX5_EVENT_TYPE_CMD);
+	case_rtn_string(MLX5_EVENT_TYPE_PAGE_REQUEST);
+	case_rtn_string(MLX5_EVENT_TYPE_PAGE_FAULT);
+	case_rtn_string(MLX5_EVENT_TYPE_PPS_EVENT);
+	case_rtn_string(MLX5_EVENT_TYPE_FPGA_ERROR);
+	case_rtn_string(MLX5_EVENT_TYPE_NIC_VPORT_CHANGE);
 	default:
 		return "Unrecognized event";
 	}
