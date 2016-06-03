From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 01/17] net: dsa: slave: chip data is optional, don't dereference NULL
Date: Fri,  3 Jun 2016 18:44:00 +0200
Message-ID: <1464972256-10408-2-git-send-email-andrew@lunn.ch>
References: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58717 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932120AbcFCQuw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2016 12:50:52 -0400
In-Reply-To: <1464972256-10408-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new binding does not make use of dsa_chip_data, a.k.a cd.  When
retrieving the size of the EEPROM attached to a switch, don't assume
there is a cd attached to the switch structure.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 net/dsa/slave.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 152436cdab30..135a91706755 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -615,7 +615,7 @@ static int dsa_slave_get_eeprom_len(struct net_device *dev)
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct dsa_switch *ds = p->parent;
 
-	if (ds->cd->eeprom_len)
+	if (ds->cd && ds->cd->eeprom_len)
 		return ds->cd->eeprom_len;
 
 	if (ds->drv->get_eeprom_len)
-- 
2.8.1
