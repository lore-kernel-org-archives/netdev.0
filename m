From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Fix vxlan endianity issue
Date: Wed, 19 Aug 2015 10:21:58 +0300
Message-ID: <1439968918-4608-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Rajesh.Borundia@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:22675 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752562AbbHSH2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 03:28:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f34fa14cc033 ("bnx2x: Add vxlan RSS support") has introduced an
endianity issue when passing the vxlan UDP port to the HW.

Reported-by: <fengguang.wu@intel.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Please apply this to 'net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index d276de3..b7d32e8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -967,7 +967,7 @@ static inline int bnx2x_func_start(struct bnx2x *bp)
 	else /* CHIP_IS_E1X */
 		start_params->network_cos_mode = FW_WRR;
 
-	start_params->vxlan_dst_port = cpu_to_le16(bp->vxlan_dst_port);
+	start_params->vxlan_dst_port = bp->vxlan_dst_port;
 
 	start_params->inner_rss = 1;
 
-- 
1.9.3
