From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [RFC] IXP4xx: Add PHYLIB MII ioctl to the Ethernet driver.
Date: Sun, 21 Dec 2008 02:15:44 +0100
Message-ID: <m3ocz6ba67.fsf@maximus.localdomain>
References: <m3vdtebadt.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:52087 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779AbYLUBPx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2008 20:15:53 -0500
In-Reply-To: <m3vdtebadt.fsf@maximus.localdomain> (Krzysztof Halasa's message of "Sun\, 21 Dec 2008 02\:11\:10 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Few patches I'm posting for review only.

Not for operational use.

IXP4xx: Add PHYLIB MII ioctl to the Ethernet driver.
    
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -789,9 +789,11 @@ static void eth_set_mcast_list(struct net_device *dev)
 
 static int eth_ioctl(struct net_device *dev, struct ifreq *req, int cmd)
 {
+	struct port *port = netdev_priv(dev);
+
 	if (!netif_running(dev))
 		return -EINVAL;
-	return -EINVAL;
+	return phy_mii_ioctl(port->phydev, if_mii(req), cmd);
 }
 
 

-- 
Krzysztof Halasa
