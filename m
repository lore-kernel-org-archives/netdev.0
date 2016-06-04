From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 01/17] net: dsa: slave: chip data is optional, don't dereference NULL
Date: Sat,  4 Jun 2016 21:16:52 +0200
Message-ID: <1465067829-1875-3-git-send-email-andrew@lunn.ch>
References: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Shawn Guo <shawnguo@kernel.org>,
	Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59556 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740AbcFDTXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 15:23:54 -0400
In-Reply-To: <1465067829-1875-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new binding does not make use of dsa_chip_data, a.k.a cd.  When
retrieving the size of the EEPROM attached to a switch, don't assume
there is a cd attached to the switch structure.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Reviewed-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
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
