From: Dan Carpenter <error27@gmail.com>
Subject: [patch 1/4] pxa168_eth: remove unneeded null check
Date: Tue, 24 Aug 2010 18:52:46 +0200
Message-ID: <20100824165150.GH29330@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Sachin Sanap <ssanap@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57235 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752143Ab0HXQxU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 12:53:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"pep->pd" isn't checked consistently in this function.  For example it's
dereferenced unconditionally on the next line after the end of the if
condition.  This function is only called from pxa168_eth_probe() and
pep->pd is always non-NULL so I removed the check.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index ecc64d7..857a681 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -1414,10 +1414,8 @@ static int ethernet_phy_setup(struct net_device *dev)
 {
 	struct pxa168_eth_private *pep = netdev_priv(dev);
 
-	if (pep->pd != NULL) {
-		if (pep->pd->init)
-			pep->pd->init();
-	}
+	if (pep->pd->init)
+		pep->pd->init();
 	pep->phy = phy_scan(pep, pep->pd->phy_addr & 0x1f);
 	if (pep->phy != NULL)
 		phy_init(pep, pep->pd->speed, pep->pd->duplex);
