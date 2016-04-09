From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: bcmgenet: use napi_complete_done()
Date: Fri, 08 Apr 2016 22:06:40 -0700
Message-ID: <1460178400.6473.469.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Petri Gynther <pgynther@google.com>,
	Florian Fainelli <f.fainelli@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:36390 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750777AbcDIFGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 01:06:43 -0400
Received: by mail-qg0-f41.google.com with SMTP id f52so106971227qga.3
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 22:06:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

By using napi_complete_done(), we allow fine tuning
of /sys/class/net/ethX/gro_flush_timeout for higher GRO aggregation
efficiency for a Gbit NIC.

Check commit 24d2e4a50737 ("tg3: use napi_complete_done()") for details.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Petri Gynther <pgynther@google.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index f7b42b9fc979..e823013d3125 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1735,7 +1735,7 @@ static int bcmgenet_rx_poll(struct napi_struct *napi, int budget)
 	work_done = bcmgenet_desc_rx(ring, budget);
 
 	if (work_done < budget) {
-		napi_complete(napi);
+		napi_complete_done(napi, work_done);
 		ring->int_enable(ring);
 	}
 
