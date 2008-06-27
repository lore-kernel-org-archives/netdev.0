From: Nye Liu <nyet@nyet.org>
Subject: [PATCH] FS_ENET: Don't attempt to set mii_speed when fec_inf is
	null
Date: Fri, 27 Jun 2008 12:26:51 -0700
Message-ID: <20080627192651.GA28291@curtisfong.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pantelis.antoniou@gmail.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from curtis.curtisfong.org ([66.43.110.51]:57358 "EHLO
	curtis.curtisfong.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757023AbYF0Tee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 15:34:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nye Liu <nyet@mrv.com>

When using CONFIG_FIXED_PHY, fec_inf (fep->phydev->bus->priv) is NULL in
fs_enet/mac-fec.c restart(). Dereferencing fec_inf when trying to set the
mii_speed causes a kernel oops.

Signed-off-by: Nye Liu <nyet@mrv.com>

---

diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
index 8a311d1..350bc73 100644
--- a/drivers/net/fs_enet/mac-fec.c
+++ b/drivers/net/fs_enet/mac-fec.c
@@ -328,7 +328,8 @@ static void restart(struct net_device *dev)
        /*
         * Set MII speed.
         */
-       FW(fecp, mii_speed, fec_inf->mii_speed);
+       if (fec_inf)
+           FW(fecp, mii_speed, fec_inf->mii_speed);
 
        /*
         * Clear any outstanding interrupt.

