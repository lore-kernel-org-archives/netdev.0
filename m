From: "Yaniv Rosner" <yaniv.home@broadcom.com>
Subject: [net-2.6 1/2] bnx2x: Fix PHY locking problem
Date: Mon, 16 Aug 2010 19:34:06 +0300
Message-ID: <1281976446.3997.17.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4664 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754083Ab0HPNPy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Aug 2010 09:15:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PHY locking is required between two ports for some external PHYs. Since
initialization was done in the common init function (called only on the 
first port initialization) rather than in the port init function, there
was in fact no PHY locking between the ports. 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_main.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index b4ec2b0..f8c3f08 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -4328,10 +4328,12 @@ static int bnx2x_init_port(struct bnx2x *bp)
 		val |= aeu_gpio_mask;
 		REG_WR(bp, offset, val);
 		}
+		bp->port.need_hw_lock = 1;
 		break;
 
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
+		bp->port.need_hw_lock = 1;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 		/* add SPIO 5 to group 0 */
 		{
 		u32 reg_addr = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
@@ -4341,7 +4343,10 @@ static int bnx2x_init_port(struct bnx2x *bp)
 		REG_WR(bp, reg_addr, val);
 		}
 		break;
-
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8072:
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
+		bp->port.need_hw_lock = 1;
+		break;
 	default:
 		break;
 	}





