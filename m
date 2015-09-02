From: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
Subject: [PATCH] net: eth: altera: fix napi poll_list corruption
Date: Wed, 2 Sep 2015 17:49:29 +0900
Message-ID: <20150902.174929.153474872.nemoto@toshiba-tops.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Vince Bridgers <vbridger@opensource.altera.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from topsowa.toshiba-tops.co.jp ([61.200.21.19]:61790 "EHLO
	TPSSRV64.toshiba-tops.co.jp" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751508AbbIBIz0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 04:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tse_poll() calls __napi_complete() with irq enabled.  This leads napi
poll_list corruption and may stop all napi drivers working.
Use napi_complete() instead of __napi_complete().

Signed-off-by: Atsushi Nemoto <nemoto@toshiba-tops.co.jp>
---
 drivers/net/ethernet/altera/altera_tse_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index da48e66..8207877 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -511,8 +511,7 @@ static int tse_poll(struct napi_struct *napi, int budget)
 
 	if (rxcomplete < budget) {
 
-		napi_gro_flush(napi, false);
-		__napi_complete(napi);
+		napi_complete(napi);
 
 		netdev_dbg(priv->dev,
 			   "NAPI Complete, did %d packets with budget %d\n",
-- 
