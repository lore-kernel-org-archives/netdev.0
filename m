From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH] net: phy: Log only PHY state transitions
Date: Tue, 25 Jul 2017 11:31:46 +0200
Message-ID: <8fc7eb8f-9d64-04c3-a1ca-0cc8eec1ee30@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, Mason <slash.tmp@free.fr>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([216.205.24.107]:43794 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750781AbdGYJbu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 05:31:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current code, old and new PHY states are always logged.
>From now on, log only PHY state transitions.

Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
---
 drivers/net/phy/phy.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d0626bf5c540..6bb764e716fc 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1226,7 +1226,8 @@ void phy_state_machine(struct work_struct *work)
 	if (err < 0)
 		phy_error(phydev);
 
-	phydev_dbg(phydev, "PHY state change %s -> %s\n",
+	if (old_state != phydev->state)
+		phydev_dbg(phydev, "PHY state change %s -> %s\n",
 		   phy_state_to_str(old_state),
 		   phy_state_to_str(phydev->state));
 
-- 
2.11.0
