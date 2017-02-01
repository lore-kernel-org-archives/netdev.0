From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 2/2] net: dsa: mv88e6xxx: Fix typ0 when configuring 2.5Gbps
Date: Thu,  2 Feb 2017 00:46:16 +0100
Message-ID: <1485992776-23750-3-git-send-email-andrew@lunn.ch>
References: <1485992776-23750-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52949 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750898AbdBAXrC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 18:47:02 -0500
In-Reply-To: <1485992776-23750-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to enable 2.5Gbps mode, we need the base speed of 10G, plus
the Alt bit setting. Fix a typ0 that used 1Gb base speed.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
v2: Add Reviewed-by
---
 drivers/net/dsa/mv88e6xxx/port.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx/port.c b/drivers/net/dsa/mv88e6xxx/port.c
index 0db7fa0373ae..d380a93b092c 100644
--- a/drivers/net/dsa/mv88e6xxx/port.c
+++ b/drivers/net/dsa/mv88e6xxx/port.c
@@ -193,7 +193,7 @@ static int mv88e6xxx_port_set_speed(struct mv88e6xxx_chip *chip, int port,
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
