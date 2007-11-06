From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] sky2: netpoll on port 0 only
Date: Tue, 6 Nov 2007 11:45:40 -0800
Message-ID: <20071106114540.75ec66ab@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:48506 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755014AbXKFTr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 14:47:58 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Netpoll will only work on port 0 because of the restrictive
relationship between NAPI and netpoll.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/drivers/net/sky2.c	2007-11-06 09:09:18.000000000 -0800
+++ b/drivers/net/sky2.c	2007-11-06 11:42:48.000000000 -0800
@@ -3995,7 +3995,8 @@ static __devinit struct net_device *sky2
 	dev->tx_timeout = sky2_tx_timeout;
 	dev->watchdog_timeo = TX_WATCHDOG;
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	dev->poll_controller = sky2_netpoll;
+	if (port == 0)
+		dev->poll_controller = sky2_netpoll;
 #endif
 
 	sky2 = netdev_priv(dev);
