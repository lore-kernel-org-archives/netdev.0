From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 8/8] net: dsa: mv88e6xxx: Fix typ0 when configuring 2.5Gbps
Date: Sat, 21 Jan 2017 00:31:02 +0100
Message-ID: <1484955062-26718-9-git-send-email-andrew@lunn.ch>
References: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:40357 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751396AbdATXef (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 20 Jan 2017 18:34:35 -0500
In-Reply-To: <1484955062-26718-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to enable 2.5Gbps mode, we need the base speed of 10G, plus
the Alt bit setting. Fix a typ0 that used 1Gb base speed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx/port.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index e253ecb6624b..d543a6817d61 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -194,7 +194,7 @@ static int mv88e6xxx_port_set_speed(struct mv88e6xxx_chip *chip, int port,
 		ctrl = PORT_PCS_CTRL_SPEED_1000;
 		break;
 	case 2500:
-		ctrl = PORT_PCS_CTRL_SPEED_1000 | PORT_PCS_CTRL_ALTSPEED;
+		ctrl = PORT_PCS_CTRL_SPEED_10000 | PORT_PCS_CTRL_ALTSPEED;
 		break;
 	case 10000:
 		/* all bits set, fall through... */
-- 
2.11.0
