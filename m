From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 08/31] [LMC]: lmc_main wants to use skb_tailroom
Date: Tue, 20 Mar 2007 19:55:26 -0300
Message-ID: <20070320225526.GU17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.230]:35152 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752062AbXCTWza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 18:55:30 -0400
Received: by wr-out-0506.google.com with SMTP id 41so72453wry
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 15:55:30 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At that point it is equivalent to what was being used, skb->end - skb->data,
and the need is clearly the one skb_tailroom satisfies.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 drivers/net/wan/lmc/lmc_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 5bb18c0..a576113 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1932,7 +1932,7 @@ static void lmc_softreset (lmc_softc_t * const sc) /*fold00*/
         sc->lmc_rxring[i].status = 0x80000000;
 
         /* used to be PKT_BUF_SZ now uses skb since we lose some to head room */
-        sc->lmc_rxring[i].length = skb_end_pointer(skb) - skb->data;
+        sc->lmc_rxring[i].length = skb_tailroom(skb);
 
         /* use to be tail which is dumb since you're thinking why write
          * to the end of the packj,et but since there's nothing there tail == data
-- 
1.5.0.3

