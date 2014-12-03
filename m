From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net v2 1/2] amd-xgbe: Do not clear interrupt indicator
Date: Wed, 3 Dec 2014 08:36:36 -0600
Message-ID: <20141203143636.25084.33707.stgit@tlendack-t1.amdoffice.net>
References: <20141203143630.25084.91079.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0117.outbound.protection.outlook.com ([207.46.100.117]:18386
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752818AbaLCOgl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 09:36:41 -0500
In-Reply-To: <20141203143630.25084.91079.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupt value within the xgbe_ring_data structure is used as an
indicator of which Rx descriptor should have the INTE bit set to
generate an interrupt when that Rx descriptor is used.  This bit was
mistakenly cleared when unmapping the associated ring data, effectively
nullifying the ethtool rx-frames support.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-desc.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
index 6fc5da0..43b7d2e 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-desc.c
@@ -356,7 +356,6 @@ static void xgbe_unmap_skb(struct xgbe_prv_data *pdata,
 
 	rdata->tso_header = 0;
 	rdata->len = 0;
-	rdata->interrupt = 0;
 	rdata->mapped_as_page = 0;
 
 	if (rdata->state_saved) {
