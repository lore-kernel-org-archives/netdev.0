From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 3/4] net: systemport: fix comment about HW prepending 2bytes
Date: Thu,  5 Jun 2014 10:22:17 -0700
Message-ID: <1401988938-25940-4-git-send-email-f.fainelli@gmail.com>
References: <1401988938-25940-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:48053 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbaFERWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 13:22:41 -0400
Received: by mail-pb0-f47.google.com with SMTP id rp16so1402146pbb.20
        for <netdev@vger.kernel.org>; Thu, 05 Jun 2014 10:22:41 -0700 (PDT)
In-Reply-To: <1401988938-25940-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comment about how the hardware prepends 2bytes to align the IP
header on a 4-byte boundary was not correct, fix that.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index fc84aba0cde0..54b51db0caf3 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -528,9 +528,9 @@ static unsigned int bcm_sysport_desc_rx(struct bcm_sysport_priv *priv,
 		if (likely(status & DESC_L4_CSUM))
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-		/* Hardware pre-pends packets with 2bytes between Ethernet
-		 * and IP header plus we have the Receive Status Block, strip
-		 * off all of this from the SKB.
+		/* Hardware pre-pends packets with 2bytes before Ethernet
+		 * header plus we have the Receive Status Block, strip off all
+		 * of this from the SKB.
 		 */
 		skb_pull(skb, sizeof(*rsb) + 2);
 		len -= (sizeof(*rsb) + 2);
-- 
1.9.1
