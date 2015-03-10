From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/3] net: dsa: Centralise getting switch id
Date: Tue, 10 Mar 2015 23:05:57 +0100
Message-ID: <1426025160-13992-2-git-send-email-andrew@lunn.ch>
References: <1426025160-13992-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57219 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753278AbbCJWJe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 18:09:34 -0400
In-Reply-To: <1426025160-13992-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get the switch id and save it away in the private mv88x6xxx structure
in a centralised piece of code, rather than each driver doing it itself.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6352.c | 2 --
 drivers/net/dsa/mv88e6xxx.c | 2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 9121e6dce267..a30e5147a3e7 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -374,8 +374,6 @@ static int mv88e6352_setup(struct dsa_switch *ds)
 
 	mutex_init(&ps->eeprom_mutex);
 
-	ps->id = REG_READ(REG_PORT(0), 0x03) & 0xfff0;
-
 	ret = mv88e6352_switch_reset(ds);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 9c9e5fa2ce70..e7e4933692cb 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -1139,6 +1139,8 @@ int mv88e6xxx_setup_common(struct dsa_switch *ds)
 	mutex_init(&ps->stats_mutex);
 	mutex_init(&ps->phy_mutex);
 
+	ps->id = REG_READ(REG_PORT(0), 0x03) & 0xfff0;
+
 	ps->fid_mask = (1 << DSA_MAX_PORTS) - 1;
 
 	INIT_WORK(&ps->bridge_work, mv88e6xxx_bridge_work);
-- 
2.1.4
