From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH net-next 2/2] r6040: use ETH_ZLEN instead of MISR for SKB length checking
Date: Wed, 15 Jan 2014 13:04:26 -0800
Message-ID: <1389819866-32142-3-git-send-email-florian@openwrt.org>
References: <1389819866-32142-1-git-send-email-florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <florian@openwrt.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:33386 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbaAOVEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 16:04:44 -0500
In-Reply-To: <1389819866-32142-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ever since this driver was merged the following code was included:

if (skb->len < MISR)
	skb->len = MISR;

MISR is defined to 0x3C which is also equivalent to ETH_ZLEN, but use
ETH_ZLEN directly which is exactly what we want to be checking for.

Reported-by: Marc Volovic <marcv@ezchip.com>
Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index ff4683a..eb15ebf 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -836,8 +836,8 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 	/* Set TX descriptor & Transmit it */
 	lp->tx_free_desc--;
 	descptr = lp->tx_insert_ptr;
-	if (skb->len < MISR)
-		descptr->len = MISR;
+	if (skb->len < ETH_ZLEN)
+		descptr->len = ETH_ZLEN;
 	else
 		descptr->len = skb->len;
 
-- 
1.8.3.2
