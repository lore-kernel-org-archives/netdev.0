From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH] dsa: mv88e6xxx: Enable forwarding for unknown to the CPU port
Date: Tue, 29 Sep 2015 01:50:56 +0200
Message-ID: <1443484256-28873-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:36538 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753955AbbI1X7R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 19:59:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Frames destined to an unknown address must be forwarded to the CPU
port. Otherwise incoming ARP, dhcp leases, etc, do not work.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 6f13f7206762..75831fe29868 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2050,6 +2050,8 @@ static int mv88e6xxx_setup_port(struct dsa_switch *ds, int port)
 				reg |= PORT_CONTROL_FRAME_ETHER_TYPE_DSA;
 			else
 				reg |= PORT_CONTROL_FRAME_MODE_DSA;
+			reg |= PORT_CONTROL_FORWARD_UNKNOWN |
+				PORT_CONTROL_FORWARD_UNKNOWN_MC;
 		}
 
 		if (mv88e6xxx_6352_family(ds) || mv88e6xxx_6351_family(ds) ||
-- 
2.5.1
