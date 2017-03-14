From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: sun: sungem: rix a possible null dereference
Date: Tue, 14 Mar 2017 22:23:21 +0100
Message-ID: <1489526601-9423-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, jarod@redhat.com,
        felipe.balbi@linux.intel.com, edumazet@google.com, fw@strlen.de,
        dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34207 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751872AbdCNVXi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 17:23:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function gem_begin_auto_negotiation dereference
the pointer ep before testing if it's null. This
patch add a check on ep before dereferencing it.

This issue was added by the patch 92552fdd557:
"net: sun: sungem: use new api ethtool_{get|set}_link_ksettings".

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/sun/sungem.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/sungem.c b/drivers/net/ethernet/sun/sungem.c
index dbfca04..fa607d0 100644
--- a/drivers/net/ethernet/sun/sungem.c
+++ b/drivers/net/ethernet/sun/sungem.c
@@ -1259,8 +1259,9 @@ static void gem_begin_auto_negotiation(struct gem *gp,
 	int duplex;
 	u32 advertising;
 
-	ethtool_convert_link_mode_to_legacy_u32(&advertising,
-						ep->link_modes.advertising);
+	if (ep)
+		ethtool_convert_link_mode_to_legacy_u32(
+			&advertising, ep->link_modes.advertising);
 
 	if (gp->phy_type != phy_mii_mdio0 &&
      	    gp->phy_type != phy_mii_mdio1)
-- 
1.7.4.4
