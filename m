From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/2] net: systemport: do not clear IFF_MULTICAST flag
Date: Fri, 20 Jun 2014 13:01:39 -0700
Message-ID: <1403294500-31905-2-git-send-email-f.fainelli@gmail.com>
References: <1403294500-31905-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:45291 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240AbaFTUBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 16:01:47 -0400
Received: by mail-ig0-f171.google.com with SMTP id h18so906050igc.10
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 13:01:46 -0700 (PDT)
In-Reply-To: <1403294500-31905-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SYSTEMPORT Ethernet MAC supports multicast just fine, it just lacks
any sort of Unicast/Broadcast/Multicasting filtering at the Ethernet MAC
level since that is handled by the front end Ethernet switch, but that
is properly handled by bcm_sysport_set_rx_mode().

Some user-space applications might be relying on the presence of this
flag to prevent using multicast sockets, this also prevents that
interface from joining the IPv6 all-router mcast group.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 141160ef249a..f6bccd847ee6 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -1589,12 +1589,6 @@ static int bcm_sysport_probe(struct platform_device *pdev)
 	BUILD_BUG_ON(sizeof(struct bcm_tsb) != 8);
 	dev->needed_headroom += sizeof(struct bcm_tsb);
 
-	/* We are interfaced to a switch which handles the multicast
-	 * filtering for us, so we do not support programming any
-	 * multicast hash table in this Ethernet MAC.
-	 */
-	dev->flags &= ~IFF_MULTICAST;
-
 	/* libphy will adjust the link state accordingly */
 	netif_carrier_off(dev);
 
-- 
1.9.1
