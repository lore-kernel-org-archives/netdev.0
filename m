From: Patrick McHardy <kaber@trash.net>
Subject: [MACVLAN]: Fix thinko in macvlan_transfer_operstate()
Date: Sun, 20 Jan 2008 15:47:08 +0100
Message-ID: <47935EEC.6010402@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060201060909060703050207"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59508 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbYATOsI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2008 09:48:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060201060909060703050207
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

Fix a minor thinko in macvlan. The bug is uncritical, so this
doesn't need to go in 2.6.24.


--------------060201060909060703050207
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit b40b16bb72ae1ad192daef55a3e9f81d76cd97ab
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jan 17 09:18:11 2008 +0100

    [MACVLAN]: Fix thinko in macvlan_transfer_operstate()
    
    When the lower device's carrier is off, the macvlan devices's
    carrier state should be checked to decide whether it needs to
    be turned off. Currently the lower device's state is checked
    a second time.
    
    This still works, but unnecessarily tries to turn off the
    carrier when its already off.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 3acf8cd..312526b 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -375,7 +375,7 @@ static void macvlan_transfer_operstate(struct net_device *dev)
 		if (!netif_carrier_ok(dev))
 			netif_carrier_on(dev);
 	} else {
-		if (netif_carrier_ok(lowerdev))
+		if (netif_carrier_ok(dev))
 			netif_carrier_off(dev);
 	}
 }

--------------060201060909060703050207--
