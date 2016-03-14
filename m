From: Andrew Lunn <andrew@lunn.ch>
Subject: [RFC PATCH 5/8] dsa: mv88e6123_61_65: Wire up the mv88e6xxx interrupt code
Date: Mon, 14 Mar 2016 01:33:48 +0100
Message-ID: <1457915631-16696-6-git-send-email-andrew@lunn.ch>
References: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55938 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932298AbcCNAeh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Mar 2016 20:34:37 -0400
In-Reply-To: <1457915631-16696-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of the shared interrupt code, so for example phy interrupts
can be passed onto the phylib.
---
 drivers/net/dsa/mv88e6123_61_65.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index d4fcf4570d95..c8111007ef24 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -97,7 +97,11 @@ static int mv88e6123_61_65_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	return mv88e6xxx_setup_ports(ds);
+	ret = mv88e6xxx_setup_ports(ds);
+	if (ret < 0)
+		return ret;
+
+	return mv88e6xxx_setup_irqs(ds);
 }
 
 struct dsa_switch_driver mv88e6123_61_65_switch_driver = {
-- 
2.7.0
