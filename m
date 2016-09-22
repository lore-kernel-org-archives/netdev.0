From: Bert Kenward <bkenward@solarflare.com>
Subject: [PATCH net-next] sfc: check async completer is !NULL before calling
Date: Thu, 22 Sep 2016 15:47:45 +0100
Message-ID: <71860880-060a-008c-30f5-61ead379a62c@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        Solarflare Linux Maintainers <linux-net-drivers@solarflare.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:46247 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757337AbcIVOw7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 10:52:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a NULL check before calling asynchronous MCDI completion functions
during device removal.

Fixes: 7014d7f6 ("sfc: allow asynchronous MCDI without completion function")
Signed-off-by: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/mcdi.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/mcdi.c b/drivers/net/ethernet/sfc/mcdi.c
index 9fbc12a..2415209 100644
--- a/drivers/net/ethernet/sfc/mcdi.c
+++ b/drivers/net/ethernet/sfc/mcdi.c
@@ -1156,7 +1156,8 @@ void efx_mcdi_flush_async(struct efx_nic *efx)
 	 * acquired locks in the wrong order.
 	 */
 	list_for_each_entry_safe(async, next, &mcdi->async_list, list) {
-		async->complete(efx, async->cookie, -ENETDOWN, NULL, 0);
+		if (async->complete)
+			async->complete(efx, async->cookie, -ENETDOWN, NULL, 0);
 		list_del(&async->list);
 		kfree(async);
 	}
-- 
2.7.4
