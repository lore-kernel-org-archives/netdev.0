From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 4/5] dsa: dsa: Fix freeing of fixed-phys from user ports.
Date: Sat, 12 Mar 2016 00:01:39 +0100
Message-ID: <1457737300-23660-5-git-send-email-andrew@lunn.ch>
References: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55193 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933180AbcCKXCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2016 18:02:05 -0500
In-Reply-To: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All ports types can have a fixed PHY associated with it. Remove the
check which limits removal to only CPU and DSA ports.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/dsa.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 1018e7dcfcc9..f100f340d93f 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -443,9 +443,6 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 
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
