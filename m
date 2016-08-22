From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 4/4] net: mv88e6xxx: Enable PORT_CONTROL_FORWARD_UNKNOWN for DSA-tagged CPU ports
Date: Mon, 22 Aug 2016 16:01:04 +0200
Message-ID: <1471874464-16142-5-git-send-email-andrew@lunn.ch>
References: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Cc: Jamie Lentin <jm@lentin.co.uk>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40511 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751032AbcHVOBb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 10:01:31 -0400
In-Reply-To: <1471874464-16142-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamie Lentin <jm@lentin.co.uk>

Without it, a mv88e6131 switch will not forward incoming unicast
packets to the CPU port.

Signed-off-by: Jamie Lentin <jm@lentin.co.uk>
---
 drivers/net/dsa/mv88e6xxx/chip.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
index 1d5f9576e62a..82d45165803c 100644
--- a/drivers/net/dsa/mv88e6xxx/chip.c
+++ b/drivers/net/dsa/mv88e6xxx/chip.c
@@ -2490,11 +2490,11 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
 	if (dsa_is_cpu_port(ds, port)) {
 		if (mv88e6xxx_has(chip, MV88E6XXX_FLAG_EDSA))
 			reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA |
-				PORT_CONTROL_FORWARD_UNKNOWN |
 				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 		else
 			reg |= PORT_CONTROL_DSA_TAG;
-		reg |= PORT_CONTROL_EGRESS_ADD_TAG;
+		reg |= PORT_CONTROL_EGRESS_ADD_TAG |
+			PORT_CONTROL_FORWARD_UNKNOWN;
 	}
 	if (dsa_is_dsa_port(ds, port)) {
 		if (mv88e6xxx_6095_family(chip) ||
-- 
2.8.1
