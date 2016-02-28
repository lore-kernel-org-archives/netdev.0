From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH RFC v2 31/32] dsa: dsa: Fix freeing of fixed-phys from user ports.
Date: Sun, 28 Feb 2016 17:41:39 +0100
Message-ID: <1456677700-23027-32-git-send-email-andrew@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45009 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759366AbcB1Qnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 11:43:40 -0500
In-Reply-To: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All ports types can have a fixed PHY associated with it. Remove the
check which limits removal to only CPU and DSA ports.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 73f962d81d40..e969a43f7a21 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -400,9 +400,6 @@ static void dsa_switch_finish_one(struct dsa_switch *ds)
 
 	/* Remove any fixed link PHYs */
 	for (port = 0; port < DSA_MAX_PORTS; port++) {
-		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
-			continue;
-
 		port_dn = cd->port_dn[port];
 		if (of_phy_is_fixed_link(port_dn)) {
 			phydev = of_phy_find_device(port_dn);
-- 
2.7.0
