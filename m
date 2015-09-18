From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: bcmgenet: Remove duplicate test for tx_coalesce_usecs_high
Date: Fri, 18 Sep 2015 14:16:53 -0700
Message-ID: <1442611013-9470-1-git-send-email-f.fainelli@gmail.com>
Cc: julia.lawall@lip6.fr, kbuild-all@01.org,
	Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	jaedon.shin@gmail.com, pgynther@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33544 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbbIRVRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 17:17:01 -0400
Received: by pacex6 with SMTP id ex6so60646743pac.0
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 14:17:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were checking twice for ec->tx_coalesce_usecs_high, remove the
duplicate test.

Reported-by: Julia Lawall <julia.lawall@lip6.fr>
Reported-by: kbuild-all@01.org
Fixes: 2f9130709d2c19 ("net: bcmgenet: Implement TX coalescing control knobs")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 1e72722abbf1..efcb1119076f 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -608,8 +608,7 @@ static int bcmgenet_set_coalesce(struct net_device *dev,
 	 * transmitted, or when the ring is emtpy.
 	 */
 	if (ec->tx_coalesce_usecs || ec->tx_coalesce_usecs_high ||
-	    ec->tx_coalesce_usecs_irq || ec->tx_coalesce_usecs_high ||
-	    ec->tx_coalesce_usecs_low)
+	    ec->tx_coalesce_usecs_irq || ec->tx_coalesce_usecs_low)
 		return -EOPNOTSUPP;
 
 	/* Program all TX queues with the same values, as there is no
-- 
2.1.0
