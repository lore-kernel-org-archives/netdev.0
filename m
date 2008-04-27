From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 5/6] sis190: remove needless MII reset
Date: Sun, 27 Apr 2008 19:05:25 +0200
Message-ID: <20080427170525.GF26953@electric-eye.fr.zoreil.com>
References: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32774 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754606AbYD0RYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Apr 2008 13:24:37 -0400
Content-Disposition: inline
In-Reply-To: <20080427170023.GA26953@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It does not help the auto-negotiation process to settle.

Added a debug message to give some hindsight when things
do not work as expected.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index 0b22e75..20f4829 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -899,10 +899,9 @@ static void sis190_phy_task(struct work_struct *work)
 		mod_timer(&tp->timer, jiffies + HZ/10);
 	} else if (!(mdio_read_latched(ioaddr, phy_id, MII_BMSR) &
 		     BMSR_ANEGCOMPLETE)) {
-		net_link(tp, KERN_WARNING "%s: PHY reset until link up.\n",
-			 dev->name);
 		netif_carrier_off(dev);
-		mdio_write(ioaddr, phy_id, MII_BMCR, val | BMCR_RESET);
+		net_link(tp, KERN_WARNING "%s: auto-negotiating...\n",
+			 dev->name);
 		mod_timer(&tp->timer, jiffies + SIS190_PHY_TIMEOUT);
 	} else {
 		/* Rejoice ! */
-- 
1.5.3.3

