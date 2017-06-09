From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next] bonding: warn user when 802.3ad speed is unknown
Date: Fri,  9 Jun 2017 15:34:43 +0200
Message-ID: <1497015283-1729-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20170608164811.GB20216@lunn.ch>
Cc: netdev@vger.kernel.org, j.vosburgh@gmail.com, vfalico@gmail.com,
        andy@greyhouse.net, thibaut.collet@6wind.com,
        linville@tuxdriver.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.76.145.23.62.rev.coltfrance.com ([62.23.145.76]:48190 "EHLO
        proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751545AbdFINe6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 09:34:58 -0400
In-Reply-To: <20170608164811.GB20216@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it explicit in the log.

Suggested-by: Andrew Lunn <andrew@lunn.ch>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/bonding/bond_3ad.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index b44a6aeb346d..b15b177662b0 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -322,6 +322,9 @@ static u16 __get_link_speed(struct port *port)
 
 		default:
 			/* unknown speed value from ethtool. shouldn't happen */
+			pr_warn("%s: unknown speed (%d) for port %d (set it to 0)\n",
+				slave->bond->dev->name, slave->speed,
+				port->actor_port_number);
 			speed = 0;
 			break;
 		}
-- 
2.8.1
