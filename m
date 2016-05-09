From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 15/21] net: dsa: mv88e6131: drop VLAN Ethertype setup
Date: Mon,  9 May 2016 13:22:52 -0400
Message-ID: <1462814578-6249-16-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462814578-6249-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50935 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbcEIRXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 13:23:48 -0400
In-Reply-To: <1462814578-6249-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 6131 switch models have a Core Tag Type register. Their setup code
is setting it to 0x8100, which is the reset default.

Drop this specific part which is correctly configured on reset anyway.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6131.c | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index d05fc79..1c3b245 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -65,11 +65,6 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	int ret;
 	u32 reg;
 
-	/* Set the VLAN ethertype to 0x8100. */
-	ret = mv88e6xxx_reg_write(ps, REG_GLOBAL, GLOBAL_CORE_TAG_TYPE, 0x8100);
-	if (ret)
-		return ret;
-
 	/* Disable ARP mirroring, and configure the upstream port as
 	 * the port to which ingress and egress monitor frames are to
 	 * be sent.
-- 
2.8.2
