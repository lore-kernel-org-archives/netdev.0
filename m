From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2] bonding: warn user when 802.3ad speed is unknown
Date: Fri,  9 Jun 2017 17:58:08 +0200
Message-ID: <1497023888-1420-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20170609145932.GG20756@lunn.ch>
Cc: netdev@vger.kernel.org, davem@davemloft.net, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:49591 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751642AbdFIP6W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 11:58:22 -0400
In-Reply-To: <20170609145932.GG20756@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Goal is to advertise the user when ethtool speeds and 802.3ad speeds are
desynchronized.
When this case happens, the kernel needs to be patched.

Suggested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Here is another proposal. Comments are welcome.

v2: use pr_warn_once()
    warn only when speed != SPEED_UNKNOWN

 drivers/net/bonding/bond_3ad.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b44a6aeb346d..165a8009c640 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -322,6 +322,11 @@ static u16 __get_link_speed(struct port *port)
 
 		default:
 			/* unknown speed value from ethtool. shouldn't happen */
+			if (slave->speed != SPEED_UNKNOWN)
+				pr_warn_once("%s: unknown ethtool speed (%d) for port %d (set it to 0)\n",
+					     slave->bond->dev->name,
+					     slave->speed,
+					     port->actor_port_number);
 			speed = 0;
 			break;
 		}
-- 
2.8.1
