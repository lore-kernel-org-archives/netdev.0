From: Dan Carpenter <error27@gmail.com>
Subject: [patch 3/4] pxa168_eth: update call to phy_mii_ioctl()
Date: Tue, 24 Aug 2010 18:54:20 +0200
Message-ID: <20100824165420.GJ29330@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sachin Sanap <ssanap@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56558 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755766Ab0HXQy7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 12:54:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The phy_mii_ioctl() function changed recently.  It now takes a struct
ifreq pointer directly.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 302fb48..f324b76 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -1350,7 +1350,7 @@ static int pxa168_eth_do_ioctl(struct net_device *dev, struct ifreq *ifr,
 {
 	struct pxa168_eth_private *pep = netdev_priv(dev);
 	if (pep->phy != NULL)
-		return phy_mii_ioctl(pep->phy, if_mii(ifr), cmd);
+		return phy_mii_ioctl(pep->phy, ifr, cmd);
 
 	return -EOPNOTSUPP;
 }
