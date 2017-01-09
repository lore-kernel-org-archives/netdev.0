From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2] net: dsa: select NET_SWITCHDEV
Date: Mon,  9 Jan 2017 16:49:26 -0500
Message-ID: <20170109214926.20985-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, Jiri Pirko <jiri@resnulli.us>,
        Randy Dunlap <rdunlap@infradead.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The support for DSA Ethernet switch chips depends on TCP/IP networking,
thus explicit that HAVE_NET_DSA depends on INET.

DSA uses SWITCHDEV, thus select it instead of depending on it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Andrew Lunn <andrew@lunn.ch>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
Tested-by: Randy Dunlap <rdunlap@infradead.org>
---
 net/dsa/Kconfig | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 96e47c539bee..39bb5b3a82f2 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -1,12 +1,13 @@
 config HAVE_NET_DSA
 	def_bool y
-	depends on NETDEVICES && !S390
+	depends on INET && NETDEVICES && !S390
 
 # Drivers must select NET_DSA and the appropriate tagging format
 
 config NET_DSA
 	tristate "Distributed Switch Architecture"
-	depends on HAVE_NET_DSA && NET_SWITCHDEV
+	depends on HAVE_NET_DSA
+	select NET_SWITCHDEV
 	select PHYLIB
 	---help---
 	  Say Y if you want to enable support for the hardware switches supported
-- 
2.11.0
