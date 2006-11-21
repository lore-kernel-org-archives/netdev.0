From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 2.6.19] bonding: incorrect bonding state reported via ioctl
Date: Tue, 21 Nov 2006 11:46:44 -0500
Message-ID: <20061121164643.GA2539@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, ctindel@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56006 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1031199AbWKUQtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Nov 2006 11:49:07 -0500
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is a small fix-up to finish out the work done by Jay Vosburgh to
add carrier-state support for bonding devices.  The output in
/proc/net/bonding/bondX was correct, but when collecting the same info
via an iotcl it could still be incorrect.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
---

 bond_main.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3547,7 +3547,7 @@ static int bond_do_ioctl(struct net_devi
 			mii->val_out = 0;
 			read_lock_bh(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
-			if (bond->curr_active_slave) {
+			if (netif_carrier_ok(bond->dev)) {
 				mii->val_out = BMSR_LSTATUS;
 			}
 			read_unlock(&bond->curr_slave_lock);
