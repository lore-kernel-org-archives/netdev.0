From: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
Subject: [PATCH v2] net: phy: Log only PHY state transitions
Date: Fri, 28 Jul 2017 13:18:30 +0200
Message-ID: <7a34bf57-4fde-529f-36cf-ad8022185df9@sigmadesigns.com>
References: <8fc7eb8f-9d64-04c3-a1ca-0cc8eec1ee30@sigmadesigns.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>, Mason <slash.tmp@free.fr>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from us-smtp-delivery-107.mimecast.com ([216.205.24.107]:29296 "EHLO
        us-smtp-delivery-107.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751607AbdG1LSh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 07:18:37 -0400
In-Reply-To: <8fc7eb8f-9d64-04c3-a1ca-0cc8eec1ee30@sigmadesigns.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current code, old and new PHY states are always logged.
>From now on, log only PHY state transitions.

Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
---
Fix indentation. I was trying to minimize the diff.
I also considered using a goto to jump over the phydev_dbg() call,
but that didn't feel right.
---
 drivers/net/phy/phy.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index d0626bf5c540..3ff79c3d90f0 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -1226,9 +1226,10 @@ void phy_state_machine(struct work_struct *work)
 	if (err < 0)
 		phy_error(phydev);
 
-	phydev_dbg(phydev, "PHY state change %s -> %s\n",
-		   phy_state_to_str(old_state),
-		   phy_state_to_str(phydev->state));
+	if (old_state != phydev->state)
+		phydev_dbg(phydev, "PHY state change %s -> %s\n",
+			   phy_state_to_str(old_state),
+			   phy_state_to_str(phydev->state));
 
 	/* Only re-schedule a PHY state machine change if we are polling the
 	 * PHY, if PHY_IGNORE_INTERRUPT is set, then we will be moving
-- 
2.11.0
