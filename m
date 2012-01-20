From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 1/3] skge:  don't assert carrier until link is up
Date: Thu, 19 Jan 2012 16:35:25 -0800
Message-ID: <20120119163525.764252ea@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49246 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754324Ab2ATApV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 19:45:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Skge device would assert carrier (link up) as soon as network device open
was called, rather than waiting until PHY has detected link.


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
This should go to -stable since reporting bogus link up can break lots of things.


--- a/drivers/net/ethernet/marvell/skge.c	2012-01-19 09:55:39.231722844 -0800
+++ b/drivers/net/ethernet/marvell/skge.c	2012-01-19 15:08:06.929771000 -0800
@@ -2576,6 +2576,7 @@ static int skge_up(struct net_device *de
 	}
 
 	/* Initialize MAC */
+	netif_carrier_off(dev);
 	spin_lock_bh(&hw->phy_lock);
 	if (is_genesis(hw))
 		genesis_mac_init(hw, port);
