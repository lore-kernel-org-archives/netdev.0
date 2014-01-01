From: Yaniv Rosner <yanivr@broadcom.com>
Subject: [PATCH net 4/5] bnx2x: Fix incorrect link-up report
Date: Wed, 1 Jan 2014 11:06:44 +0200
Message-ID: <1388567205-20210-5-git-send-email-yanivr@broadcom.com>
References: <1388567205-20210-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:21489 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753354AbaAAJIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 04:08:05 -0500
In-Reply-To: <1388567205-20210-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a problem where link is reported to be up when SFP+ module is plugged in
without cable. This occurs with specific module types which may generate
temporary TX_FAULT indication. Solution is to avoid changing any link parameters
when checking TX_FAULT indication while physical link is down.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 68417e1..998cce3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -13360,6 +13360,10 @@ static u8 bnx2x_analyze_link_error(struct link_params *params,
 	DP(NETIF_MSG_LINK, "Link changed:[%x %x]->%x\n", vars->link_up,
 	   old_status, status);
 
+	/* Do not touch the link in case physical link down */
+	if ((vars->phy_flags & PHY_PHYSICAL_LINK_FLAG) == 0)
+		return 1;
+
 	/* a. Update shmem->link_status accordingly
 	 * b. Update link_vars->link_up
 	 */
-- 
1.7.1
