From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 3/10] bnx2x: enable inta on the pci bus when
 used
Date: Wed, 4 Apr 2012 07:41:25 +0300
Message-ID: <1333514492-20425-4-git-send-email-yuvalmin@broadcom.com>
References: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4920 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657Ab2DDErX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 00:47:23 -0400
In-Reply-To: <1333514492-20425-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During boot-from-SAN, if msix interrupts are unavailable and inta
is requested, it is possible that inta would be disabled in the
pci bus. This patch enables inta when requested.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 44b6f9f..16de19f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -1363,6 +1363,9 @@ static void bnx2x_igu_int_enable(struct bnx2x *bp)
 
 	REG_WR(bp, IGU_REG_PF_CONFIGURATION, val);
 
+	if (val & IGU_PF_CONF_INT_LINE_EN)
+		pci_intx(bp->pdev, true);
+
 	barrier();
 
 	/* init leading/trailing edge */
-- 
1.7.9.rc2
