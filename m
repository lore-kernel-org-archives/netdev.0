From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 01/16] dsa: slave: chip data is optional, don't dereference NULL
Date: Fri, 27 May 2016 03:20:35 +0200
Message-ID: <1464312050-23023-2-git-send-email-andrew@lunn.ch>
References: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	John Crispin <john@phrozen.org>, Bryan.Whitehead@microchip.com,
	Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52516 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755770AbcE0BW4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 May 2016 21:22:56 -0400
In-Reply-To: <1464312050-23023-1-git-send-email-andrew@lunn.ch>
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
