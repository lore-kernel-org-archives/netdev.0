From: akpm@osdl.org
Subject: [patch 4/8] bonding: incorrect bonding state reported via ioctl
Date: Mon, 04 Dec 2006 15:04:54 -0800
Message-ID: <200612042306.kB4N63Ki008001@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, andy@greyhouse.net,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:53660 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937450AbWLDXGP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:06:15 -0500
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Gospodarek <andy@greyhouse.net>

This is a small fix-up to finish out the work done by Jay Vosburgh to add
carrier-state support for bonding devices.  The output in
/proc/net/bonding/bondX was correct, but when collecting the same info via
an iotcl it could still be incorrect.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/bonding/bond_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/bonding/bond_main.c~bonding-incorrect-bonding-state-reported-via-ioctl drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c~bonding-incorrect-bonding-state-reported-via-ioctl
+++ a/drivers/net/bonding/bond_main.c
@@ -3684,7 +3684,7 @@ static int bond_do_ioctl(struct net_devi
 			mii->val_out = 0;
 			read_lock_bh(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
-			if (bond->curr_active_slave) {
+			if (netif_carrier_ok(bond->dev)) {
 				mii->val_out = BMSR_LSTATUS;
 			}
 			read_unlock(&bond->curr_slave_lock);
_
