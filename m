From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net] amd-xgbe: Add the __GFP_NOWARN flag to Rx buffer
 allocation
Date: Mon, 29 Jun 2015 11:22:12 -0500
Message-ID: <20150629162212.20833.16427.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0121.outbound.protection.outlook.com ([65.55.169.121]:53937
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752582AbbF2QyZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 12:54:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When allocating Rx related buffers, alloc_pages is called using an order
number that is decreased until successful. A system under stress can
experience failures during this allocation process resulting in a warning
being issued. This message can be of concern to end users even though the
failure is not fatal. Since the failure is not fatal and can occur
multiple times, the driver should include the __GFP_NOWARN flag to
suppress the warning message from being issued.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index dd03ad8..661cdaa 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -268,7 +268,7 @@ static int xgbe_alloc_pages(struct xgbe_prv_data *pdata,
 	int ret;
 
 	/* Try to obtain pages, decreasing order if necessary */
-	gfp |= __GFP_COLD | __GFP_COMP;
+	gfp |= __GFP_COLD | __GFP_COMP | __GFP_NOWARN;
 	while (order >= 0) {
 		pages = alloc_pages(gfp, order);
 		if (pages)
