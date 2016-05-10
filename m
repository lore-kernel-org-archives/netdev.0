From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 1/7] dsa: mv88e6xxx: Initialise the mutex as soon as it is created
Date: Tue, 10 May 2016 23:27:19 +0200
Message-ID: <1462915645-24674-2-git-send-email-andrew@lunn.ch>
References: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35001 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293AbcEJV3d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 17:29:33 -0400
In-Reply-To: <1462915645-24674-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

By initialising immediately it, we don't run the danger of using it
before it is initialised.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6xxx.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 1e5ca8e0f48e..b2d27bfd53c2 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -3118,8 +3118,6 @@ static int mv88e6xxx_setup(struct dsa_switch *ds)
 
 	ps->ds = ds;
 
-	mutex_init(&ps->smi_mutex);
-
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
 
 	if (mv88e6xxx_has(ps, MV88E6XXX_FLAG_EEPROM))
@@ -3566,6 +3564,7 @@ static const char *mv88e6xxx_probe(struct device *dsa_dev,
 	ps->bus = bus;
 	ps->sw_addr = sw_addr;
 	ps->info = info;
+	mutex_init(&ps->smi_mutex);
 
 	*priv = ps;
 
-- 
2.8.1
