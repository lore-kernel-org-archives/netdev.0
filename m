From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net 1/1] via-velocity: S3 resume fix.
Date: Sun, 5 Feb 2012 10:22:26 +0100
Message-ID: <20120205092226.GB18774@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	David Lv <DavidLv@viatech.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60352 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799Ab2BEJd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 04:33:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lv <DavidLv@viatech.com.cn>

Initially diagnosed on Ubuntu 11.04 with kernel 2.6.38.

velocity_close is not called during a suspend / resume cycle in this
driver and it has no business playing directly with power states.

Signed-off-by: David Lv <DavidLv@viatech.com.cn>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---

 David L., please don't put anything but a valid email address in
 your S-o-b line when you send patches (no parenthesis, plain bracket).
 Thanks.

 drivers/net/ethernet/via/via-velocity.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 4128d6b..cb35b14 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2491,9 +2491,6 @@ static int velocity_close(struct net_device *dev)
 	if (dev->irq != 0)
 		free_irq(dev->irq, dev);
 
-	/* Power down the chip */
-	pci_set_power_state(vptr->pdev, PCI_D3hot);
-
 	velocity_free_rings(vptr);
 
 	vptr->flags &= (~VELOCITY_FLAGS_OPENED);
-- 
1.7.6.5
