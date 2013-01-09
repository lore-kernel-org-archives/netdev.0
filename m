From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next] bnx2x: align define usage to satisfy static
 checkers
Date: Wed, 9 Jan 2013 19:04:35 +0200
Message-ID: <1357751075-23112-1-git-send-email-ariele@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Ariel Elior" <ariele@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1498 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932123Ab3AIRBu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2013 12:01:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Static checkers complained that the E1H_FUNC_MAX define is used
incorrectly in bnx2x_pretend_func(). The complaint was justified,
although its not a real bug, as the first part of the conditional
protects us in this case (a real bug would happen if a VF tried to
use the pretend func, but there are no VFs in E1H chips).

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 5fcaee1..8740b52 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13361,7 +13361,7 @@ int bnx2x_pretend_func(struct bnx2x *bp, u16 pretend_func_val)
 {
 	u32 pretend_reg;
 
-	if (CHIP_IS_E1H(bp) && pretend_func_val > E1H_FUNC_MAX)
+	if (CHIP_IS_E1H(bp) && pretend_func_val >= E1H_FUNC_MAX)
 		return -1;
 
 	/* get my own pretend register */
-- 
1.7.9.GIT
