From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 20/21] net: dsa: mv88e6131: use EDSA tag protocol
Date: Mon,  9 May 2016 13:22:57 -0400
Message-ID: <1462814578-6249-21-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462814578-6249-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:50984 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbcEIRXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 13:23:54 -0400
In-Reply-To: <1462814578-6249-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

6131 is the only driver to set the tag protocol to DSA_TAG_PROTO_DSA.
Since it works fine with DSA_TAG_PROTO_EDSA, change its value, like all
other mv88e6xxx drivers.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/Kconfig     | 2 +-
 drivers/net/dsa/mv88e6131.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 4aaadce..7e01dce 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -17,7 +17,7 @@ config NET_DSA_MV88E6131
 	tristate "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
 	depends on NET_DSA
 	select NET_DSA_MV88E6XXX
-	select NET_DSA_TAG_DSA
+	select NET_DSA_TAG_EDSA
 	---help---
 	  This enables support for the Marvell 88E6085/6095/6095F/6131
 	  ethernet switch chips.
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 22952be..bbad199 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -59,7 +59,7 @@ static const char *mv88e6131_drv_probe(struct device *dsa_dev,
 }
 
 struct dsa_switch_driver mv88e6131_switch_driver = {
-	.tag_protocol		= DSA_TAG_PROTO_DSA,
+	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6131_drv_probe,
 	.setup			= mv88e6xxx_setup,
 	.set_addr		= mv88e6xxx_set_addr,
-- 
2.8.2
