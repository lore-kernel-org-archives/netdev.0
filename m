From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: dsa: do not call phy_start_aneg
Date: Thu,  2 Oct 2014 18:56:03 -0700
Message-ID: <1412301363-8478-2-git-send-email-f.fainelli@gmail.com>
References: <1412301363-8478-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:49784 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752463AbaJCB4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 21:56:13 -0400
Received: by mail-pa0-f54.google.com with SMTP id ey11so586421pad.41
        for <netdev@vger.kernel.org>; Thu, 02 Oct 2014 18:56:13 -0700 (PDT)
In-Reply-To: <1412301363-8478-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f7f1de51edbd ("net: dsa: start and stop the PHY state machine")
add calls to phy_start() in dsa_slave_open() respectively phy_stop() in
dsa_slave_close().

We also call phy_start_aneg() in dsa_slave_create(), and this call is
messing up with the PHY state machine, since we basically start the
auto-negotiation, and later on restart it when calling phy_start().
phy_start() does not currently handle the PHY_FORCING or PHY_AN states
properly, but such a fix would be too invasive for this window.

Fixes: f7f1de51edbd ("net: dsa: start and stop the PHY state machine")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 36953c84ff2d..8030489d9cbe 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -608,7 +608,6 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		p->phy->speed = 0;
 		p->phy->duplex = 0;
 		p->phy->advertising = p->phy->supported | ADVERTISED_Autoneg;
-		phy_start_aneg(p->phy);
 	}
 
 	return slave_dev;
-- 
1.9.1
