From: Gilad Ben-Yossef <gilad@benyossef.com>
Subject: [PATCH net] dsa: fix promiscuity leak on slave dev open error
Date: Thu, 25 Jun 2015 16:32:35 +0300
Message-ID: <1435239155-14607-1-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Gilad Ben-Yossef <giladb@ezchip.com>,
	"Florian Fainelli" <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"Andrew Lunn" <andrew@lunn.ch>, Scott Feldman <sfeldma@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0100.outbound.protection.outlook.com ([157.55.234.100]:18462
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752469AbbFYNsR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 09:48:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DSA master netdev promiscuity counter was not being properly
decremented on slave device open error path.

Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
CC: Gilad Ben-Yossef <giladb@ezchip.com>
CC: David S. Miller <davem@davemloft.net>
CC: Florian Fainelli <f.fainelli@gmail.com>
CC: Guenter Roeck <linux@roeck-us.net>
CC: Andrew Lunn <andrew@lunn.ch>
CC: Scott Feldman <sfeldma@gmail.com>
---
 net/dsa/slave.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 04ffad3..0917123 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -112,7 +112,7 @@ static int dsa_slave_open(struct net_device *dev)
 
 clear_promisc:
 	if (dev->flags & IFF_PROMISC)
-		dev_set_promiscuity(master, 0);
+		dev_set_promiscuity(master, -1);
 clear_allmulti:
 	if (dev->flags & IFF_ALLMULTI)
 		dev_set_allmulti(master, -1);
-- 
1.7.1
