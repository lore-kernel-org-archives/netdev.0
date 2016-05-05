From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [RFC PATCH net-next 19/20] net: dsa: mv88e6xxx: factorize tag protocol
Date: Thu,  5 May 2016 18:41:03 -0400
Message-ID: <1462488064-1841-20-git-send-email-vivien.didelot@savoirfairelinux.com>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
index cf7d710..81640f6 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -75,7 +75,7 @@ static const char *mv88e6131_drv_probe(struct device *dsa_dev,
 }
 
 struct dsa_switch_driver mv88e6131_switch_driver = {
-	.tag_protocol		= DSA_TAG_PROTO_DSA,
+	.tag_protocol		= DSA_TAG_PROTO_EDSA,
 	.probe			= mv88e6131_drv_probe,
 	.setup			= mv88e6xxx_setup,
 	.set_addr		= mv88e6xxx_set_addr,
-- 
2.8.2
