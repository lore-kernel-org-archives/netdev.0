From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH 4/4] net: qlcnic: delete redundant memsets
Date: Wed,  9 Sep 2015 10:38:05 +0200
Message-ID: <1441787886-7214-5-git-send-email-linux@rasmusvillemoes.dk>
References: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441787886-7214-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In all cases, mbx->req.arg and mbx->rsp.arg have just been allocated
using kcalloc(), so these six memsets are redundant.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
I cranked $context_lines to 11 to make the kcallocs visible.

 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c      | 2 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c          | 2 --
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c | 2 --
 3 files changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 5ab3adf88166..9f0bdd993955 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -910,24 +910,22 @@ int qlcnic_83xx_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
 			mbx->req.arg = kcalloc(mbx->req.num, sizeof(u32),
 					       GFP_ATOMIC);
 			if (!mbx->req.arg)
 				return -ENOMEM;
 			mbx->rsp.arg = kcalloc(mbx->rsp.num, sizeof(u32),
 					       GFP_ATOMIC);
 			if (!mbx->rsp.arg) {
 				kfree(mbx->req.arg);
 				mbx->req.arg = NULL;
 				return -ENOMEM;
 			}
-			memset(mbx->req.arg, 0, sizeof(u32) * mbx->req.num);
-			memset(mbx->rsp.arg, 0, sizeof(u32) * mbx->rsp.num);
 			temp = adapter->ahw->fw_hal_version << 29;
 			mbx->req.arg[0] = (type | (mbx->req.num << 16) | temp);
 			mbx->cmd_op = type;
 			return 0;
 		}
 	}
 
 	dev_err(&adapter->pdev->dev, "%s: Invalid mailbox command opcode 0x%x\n",
 		__func__, type);
 	return -EINVAL;
 }
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
index 6e6f18fc5d76..a5f422f26cb4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ctx.c
@@ -65,24 +65,22 @@ int qlcnic_82xx_alloc_mbx_args(struct qlcnic_cmd_args *mbx,
 			mbx->req.arg = kcalloc(mbx->req.num,
 					       sizeof(u32), GFP_ATOMIC);
 			if (!mbx->req.arg)
 				return -ENOMEM;
 			mbx->rsp.arg = kcalloc(mbx->rsp.num,
 					       sizeof(u32), GFP_ATOMIC);
 			if (!mbx->rsp.arg) {
 				kfree(mbx->req.arg);
 				mbx->req.arg = NULL;
 				return -ENOMEM;
 			}
-			memset(mbx->req.arg, 0, sizeof(u32) * mbx->req.num);
-			memset(mbx->rsp.arg, 0, sizeof(u32) * mbx->rsp.num);
 			mbx->req.arg[0] = type;
 			break;
 		}
 	}
 	return 0;
 }
 
 /* Free up mailbox registers */
 void qlcnic_free_mbx_args(struct qlcnic_cmd_args *cmd)
 {
 	kfree(cmd->req.arg);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
index 546cd5f1c85a..7327b729ba2e 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sriov_common.c
@@ -721,24 +721,22 @@ static int qlcnic_sriov_alloc_bc_mbx_args(struct qlcnic_cmd_args *mbx, u32 type)
 			mbx->req.arg = kcalloc(mbx->req.num, sizeof(u32),
 					       GFP_ATOMIC);
 			if (!mbx->req.arg)
 				return -ENOMEM;
 			mbx->rsp.arg = kcalloc(mbx->rsp.num, sizeof(u32),
 					       GFP_ATOMIC);
 			if (!mbx->rsp.arg) {
 				kfree(mbx->req.arg);
 				mbx->req.arg = NULL;
 				return -ENOMEM;
 			}
-			memset(mbx->req.arg, 0, sizeof(u32) * mbx->req.num);
-			memset(mbx->rsp.arg, 0, sizeof(u32) * mbx->rsp.num);
 			mbx->req.arg[0] = (type | (mbx->req.num << 16) |
 					   (3 << 29));
 			mbx->rsp.arg[0] = (type & 0xffff) | mbx->rsp.num << 16;
 			return 0;
 		}
 	}
 	return -EINVAL;
 }
 
 static int qlcnic_sriov_prepare_bc_hdr(struct qlcnic_bc_trans *trans,
 				       struct qlcnic_cmd_args *cmd,
-- 
2.1.3
