From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: do not use slave MII bus for fixed PHYs
Date: Sat, 14 Mar 2015 13:21:59 -0700
Message-ID: <1426364519-13465-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34761 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751300AbbCNUWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Mar 2015 16:22:45 -0400
Received: by pacwe9 with SMTP id we9so22377285pac.1
        for <netdev@vger.kernel.org>; Sat, 14 Mar 2015 13:22:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit cd28a1a9baee7 ("net: dsa: fully divert PHY reads/writes if
requested") introduced a check for particular PHYs that need to be
accessed using the slave MII bus created by DSA, but this check was too
inclusive. This would prevent fixed PHYs from being successfully
registered because those should not go through the slave MII bus created
by DSA.

Make sure we check that the PHY is not a fixed PHY to prevent that from
happening.

Fixes: cd28a1a9baee7 ("net: dsa: fully divert PHY reads/writes if requested")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Hi David,

This change is only in net-next for now, thanks!

 net/dsa/slave.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 188b69773e70..6511552039d6 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -675,7 +675,8 @@ static int dsa_slave_phy_setup(struct dsa_slave_priv *p,
 		 * want to bind this device using the slave MII bus created by
 		 * DSA to make that happen.
 		 */
-		if (ret >= 0 && (ds->phys_mii_mask & (1 << ret))) {
+		if (!phy_is_fixed && ret >= 0 &&
+		    (ds->phys_mii_mask & (1 << ret))) {
 			ret = dsa_slave_phy_connect(p, slave_dev, ret);
 			if (ret)
 				return ret;
-- 
2.1.0
