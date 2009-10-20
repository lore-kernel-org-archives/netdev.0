From: Ben Dooks <ben@simtec.co.uk>
Subject: [patch 3/3] KS8851: Fix ks8851_set_rx_mode() for IFF_MULTICAST
Date: Tue, 20 Oct 2009 10:49:05 +0100
Message-ID: <20091020094954.578325358@fluff.org.uk>
References: <20091020094902.274646871@fluff.org.uk>
Cc: Ping.Doong@Micrel.Com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aeryn.fluff.org.uk ([87.194.8.8]:50625 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751740AbZJTJtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 05:49:52 -0400
Content-Disposition: inline; filename=ks8851-fix-mc-rxmode.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In ks8851_set_rx_mode() the case handling IFF_MULTICAST was also setting
the RXCR1_AE bit by accident. This meant that all unicast frames where
being accepted by the device. Remove RXCR1_AE from this case.

Note, RXCR1_AE was also masking a problem with setting the MAC address
properly, so needs to be applied after fixing the MAC write order.

Fixes a bug reported by Doong, Ping of Micrel. This version of the
patch avoids setting RXCR1_ME for all cases.

Signed-off-by: Ben Dooks <ben@simtec.co.uk>

---
 drivers/net/ks8851.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: b/drivers/net/ks8851.c
===================================================================
--- a/drivers/net/ks8851.c	2009-10-13 13:28:50.000000000 +0100
+++ b/drivers/net/ks8851.c	2009-10-13 13:28:51.000000000 +0100
@@ -980,7 +980,7 @@ static void ks8851_set_rx_mode(struct ne
 			mcptr = mcptr->next;
 		}
 
-		rxctrl.rxcr1 = RXCR1_RXME | RXCR1_RXAE | RXCR1_RXPAFMA;
+		rxctrl.rxcr1 = RXCR1_RXME | RXCR1_RXPAFMA;
 	} else {
 		/* just accept broadcast / unicast */
 		rxctrl.rxcr1 = RXCR1_RXPAFMA;

