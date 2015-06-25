From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 8/9] bnx2x: Release nvram lock on error flow
Date: Thu, 25 Jun 2015 15:19:28 +0300
Message-ID: <1435234769-5625-9-git-send-email-Yuval.Mintz@qlogic.com>
References: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:25228 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751720AbbFYMUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:20:18 -0400
In-Reply-To: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During an error flow when trying to access the nvram the driver doesn't
release the hw lock it acquired.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index caf6b31..76b9052 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1230,6 +1230,7 @@ static int bnx2x_acquire_nvram_lock(struct bnx2x *bp)
 	if (!(val & (MCPR_NVM_SW_ARB_ARB_ARB1 << port))) {
 		DP(BNX2X_MSG_ETHTOOL | BNX2X_MSG_NVM,
 		   "cannot get access to nvram interface\n");
+		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_NVRAM);
 		return -EBUSY;
 	}
 
-- 
1.9.3
