From: Jerome Brunet <jbrunet@baylibre.com>
Subject: [PATCH net 3/3] dt: bindings: net: use boolean dt properties for eee broken modes
Date: Mon, 19 Dec 2016 16:05:38 +0100
Message-ID: <1482159938-13239-4-git-send-email-jbrunet@baylibre.com>
References: <1482159938-13239-1-git-send-email-jbrunet@baylibre.com>
Cc: Jerome Brunet <jbrunet@baylibre.com>,
        Carlo Caione <carlo@caione.org>,
        Kevin Hilman <khilman@baylibre.com>,
        Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Andre Roth <neolynx@gmail.com>, Andrew Lunn <andrew@lunn.ch>,
        Neil Armstrong <narmstrong@baylibre.com>,
        linux-amlogic@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        Yegor Yefremov <yegorslists@googlemail.com>,
        =?UTF-8?q?Andreas=20F=C3=A4rber?= <afaerber@suse.de>
To: netdev@vger.kernel.org, devicetree@vger.kernel.org,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482159938-13239-1-git-send-email-jbrunet@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patches regarding eee-broken-modes was merged before all people
involved could find an agreement on the best way to move forward.

While we agreed on having a DT property to mark particular modes as broken,
the value used for eee-broken-modes mapped the phy register in very direct
way. Because of this, the concern is that it could be used to implement
configuration policies instead of describing a broken HW.

In the end, having a boolean property for each mode seems to be preferred
over one bit field value mapping the register (too) directly.

Cc: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Jerome Brunet <jbrunet@baylibre.com>
---
 Documentation/devicetree/bindings/net/phy.txt | 10 ++++++++--
 include/dt-bindings/net/mdio.h                | 19 -------------------
 2 files changed, 8 insertions(+), 21 deletions(-)
 delete mode 100644 include/dt-bindings/net/mdio.h

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index 54749b60a466..ff1bc4b1bb3b 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -38,8 +38,14 @@ Optional Properties:
 - enet-phy-lane-swap: If set, indicates the PHY will swap the TX/RX lanes to
   compensate for the board being designed with the lanes swapped.
 
-- eee-broken-modes: Bits to clear in the MDIO_AN_EEE_ADV register to
-  disable EEE broken modes.
+- eee-broken-100tx:
+- eee-broken-1000t:
+- eee-broken-10gt:
+- eee-broken-1000kx:
+- eee-broken-10gkx4:
+- eee-broken-10gkr:
+  Mark the corresponding energy efficient ethernet mode as broken and
+  request the ethernet to stop advertising it.
 
 Example:
 
diff --git a/include/dt-bindings/net/mdio.h b/include/dt-bindings/net/mdio.h
deleted file mode 100644
index 99c6d903d439..000000000000
--- a/include/dt-bindings/net/mdio.h
+++ /dev/null
@@ -1,19 +0,0 @@
-/*
- * This header provides generic constants for ethernet MDIO bindings
- */
-
-#ifndef _DT_BINDINGS_NET_MDIO_H
-#define _DT_BINDINGS_NET_MDIO_H
-
-/*
- * EEE capability Advertisement
- */
-
-#define MDIO_EEE_100TX		0x0002	/* 100TX EEE cap */
-#define MDIO_EEE_1000T		0x0004	/* 1000T EEE cap */
-#define MDIO_EEE_10GT		0x0008	/* 10GT EEE cap */
-#define MDIO_EEE_1000KX		0x0010	/* 1000KX EEE cap */
-#define MDIO_EEE_10GKX4		0x0020	/* 10G KX4 EEE cap */
-#define MDIO_EEE_10GKR		0x0040	/* 10G KR EEE cap */
-
-#endif
-- 
2.7.4
