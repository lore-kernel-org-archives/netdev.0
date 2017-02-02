From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] atl1e: add GRO support
Date: Thu, 02 Feb 2017 06:09:14 -0800
Message-ID: <1486044554.13103.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33179 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdBBOJQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 09:09:16 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so1943649pgd.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 06:09:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It is time to add GRO support to this driver.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index ef003c522ba24f6065f23e3718902a3b190e5c9d..4f7e195af0bc6dff79687547b9979375b35a17d6 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -1472,7 +1472,7 @@ static void atl1e_clean_rx_irq(struct atl1e_adapter *adapter, u8 que,
 					   prrs->vtag);
 				__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 			}
-			netif_receive_skb(skb);
+			napi_gro_receive(&adapter->napi, skb);
 
 skip_pkt:
 	/* skip current packet whether it's ok or not. */
