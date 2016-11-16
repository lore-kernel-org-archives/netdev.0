From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] sfc: remove napi_hash_del() call
Date: Wed, 16 Nov 2016 06:01:47 -0800
Message-ID: <1479304907.8455.171.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Edward Cree <ecree@solarflare.com>,
        Bert Kenward <bkenward@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36302 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751522AbcKPOBt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:01:49 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so14803528pgx.3
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:01:49 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Calling napi_hash_del() after netif_napi_del() is pointless.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Edward Cree <ecree@solarflare.com>
Cc: Bert Kenward <bkenward@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 649bc508fa4b9ea42aa08331c50335e1a51f9259..52ca0404c49121f1c86126ab7d443b1144f20720 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2113,10 +2113,9 @@ static void efx_init_napi(struct efx_nic *efx)
 
 static void efx_fini_napi_channel(struct efx_channel *channel)
 {
-	if (channel->napi_dev) {
+	if (channel->napi_dev)
 		netif_napi_del(&channel->napi_str);
-		napi_hash_del(&channel->napi_str);
-	}
+
 	channel->napi_dev = NULL;
 }
 
