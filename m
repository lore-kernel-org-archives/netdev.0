From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 1/4] qed: Correct order of wwnn and wwpn
Date: Fri, 2 Jun 2017 08:58:30 +0300
Message-ID: <20170602055833.21814-2-Yuval.Mintz@cavium.com>
References: <20170602055833.21814-1-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-scsi@vger.kernel.org>, <nilesh.javali@cavium.com>,
        <chad.dupuis@cavium.com>, <saurav.kashyap@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20170602055833.21814-1-Yuval.Mintz@cavium.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver reads values via HSI splitting this 8-byte into 2 32-bit
values and builds a single u64 field - but it does so by shifting
the lower field instead of the higher.
Luckily, we still don't use these fields for anything - but we're about
to start.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 31c88e1..e82f329 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1736,10 +1736,10 @@ int qed_mcp_fill_shmem_func_info(struct qed_hwfn *p_hwfn,
 		DP_NOTICE(p_hwfn, "MAC is 0 in shmem\n");
 	}
 
-	info->wwn_port = (u64)shmem_info.fcoe_wwn_port_name_upper |
-			 (((u64)shmem_info.fcoe_wwn_port_name_lower) << 32);
-	info->wwn_node = (u64)shmem_info.fcoe_wwn_node_name_upper |
-			 (((u64)shmem_info.fcoe_wwn_node_name_lower) << 32);
+	info->wwn_port = (u64)shmem_info.fcoe_wwn_port_name_lower |
+			 (((u64)shmem_info.fcoe_wwn_port_name_upper) << 32);
+	info->wwn_node = (u64)shmem_info.fcoe_wwn_node_name_lower |
+			 (((u64)shmem_info.fcoe_wwn_node_name_upper) << 32);
 
 	info->ovlan = (u16)(shmem_info.ovlan_stag & FUNC_MF_CFG_OV_STAG_MASK);
 
-- 
2.9.4
