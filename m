From: Olof Johansson <olof@lixom.net>
Subject: [PATCH 3/3] pasemi_mac: Disable interface on close
Date: Wed, 23 Jan 2008 13:57:19 -0600
Message-ID: <20080123195719.GD32380@lixom.net>
References: <20080123195537.GA32380@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46903 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751773AbYAWTx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 14:53:29 -0500
Content-Disposition: inline
In-Reply-To: <20080123195537.GA32380@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turns out we never disable the interface. It doesn't really cause
any problems since the channel is off, but it's still better to do it
this way.
    
Signed-off-by: Olof Johansson <olof@lixom.net>

diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index 059c6b0..2e39e02 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1287,6 +1287,7 @@ static int pasemi_mac_close(struct net_device *dev)
 	pasemi_mac_pause_txchan(mac);
 	pasemi_mac_pause_rxint(mac);
 	pasemi_mac_pause_rxchan(mac);
+	pasemi_mac_intf_disable(mac);
 
 	free_irq(mac->tx->chan.irq, mac->tx);
 	free_irq(mac->rx->chan.irq, mac->rx);
