From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 3/6] net: dsa: b53: Define SF2 MIB layout
Date: Fri, 26 Aug 2016 12:18:31 -0700
Message-ID: <1472239114-26212-4-git-send-email-f.fainelli@gmail.com>
References: <1472239114-26212-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jonas.gorski@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33142 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752302AbcHZTSu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 15:18:50 -0400
Received: by mail-pa0-f65.google.com with SMTP id vy10so5115962pac.0
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 12:18:50 -0700 (PDT)
In-Reply-To: <1472239114-26212-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 58xx and 7445 chips use the Starfighter2 code, define its MIB layout
and introduce a helper function: is58xx() which checks for both of these
IDs for now.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/b53/b53_common.c | 63 ++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/b53/b53_priv.h   |  6 ++++
 2 files changed, 69 insertions(+)

diff --git a/drivers/net/dsa/b53/b53_common.c b/drivers/net/dsa/b53/b53_common.c
index d014c918ebfd..ca13ee134562 100644
--- a/drivers/net/dsa/b53/b53_common.c
+++ b/drivers/net/dsa/b53/b53_common.c
@@ -167,6 +167,65 @@ static const struct b53_mib_desc b53_mibs[] = {
 
 #define B53_MIBS_SIZE	ARRAY_SIZE(b53_mibs)
 
+static const struct b53_mib_desc b53_mibs_58xx[] = {
+	{ 8, 0x00, "TxOctets" },
+	{ 4, 0x08, "TxDropPkts" },
+	{ 4, 0x0c, "TxQPKTQ0" },
+	{ 4, 0x10, "TxBroadcastPkts" },
+	{ 4, 0x14, "TxMulticastPkts" },
+	{ 4, 0x18, "TxUnicastPKts" },
+	{ 4, 0x1c, "TxCollisions" },
+	{ 4, 0x20, "TxSingleCollision" },
+	{ 4, 0x24, "TxMultipleCollision" },
+	{ 4, 0x28, "TxDeferredCollision" },
+	{ 4, 0x2c, "TxLateCollision" },
+	{ 4, 0x30, "TxExcessiveCollision" },
+	{ 4, 0x34, "TxFrameInDisc" },
+	{ 4, 0x38, "TxPausePkts" },
+	{ 4, 0x3c, "TxQPKTQ1" },
+	{ 4, 0x40, "TxQPKTQ2" },
+	{ 4, 0x44, "TxQPKTQ3" },
+	{ 4, 0x48, "TxQPKTQ4" },
+	{ 4, 0x4c, "TxQPKTQ5" },
+	{ 8, 0x50, "RxOctets" },
+	{ 4, 0x58, "RxUndersizePkts" },
+	{ 4, 0x5c, "RxPausePkts" },
+	{ 4, 0x60, "RxPkts64Octets" },
+	{ 4, 0x64, "RxPkts65to127Octets" },
+	{ 4, 0x68, "RxPkts128to255Octets" },
+	{ 4, 0x6c, "RxPkts256to511Octets" },
+	{ 4, 0x70, "RxPkts512to1023Octets" },
+	{ 4, 0x74, "RxPkts1024toMaxPktsOctets" },
+	{ 4, 0x78, "RxOversizePkts" },
+	{ 4, 0x7c, "RxJabbers" },
+	{ 4, 0x80, "RxAlignmentErrors" },
+	{ 4, 0x84, "RxFCSErrors" },
+	{ 8, 0x88, "RxGoodOctets" },
+	{ 4, 0x90, "RxDropPkts" },
+	{ 4, 0x94, "RxUnicastPkts" },
+	{ 4, 0x98, "RxMulticastPkts" },
+	{ 4, 0x9c, "RxBroadcastPkts" },
+	{ 4, 0xa0, "RxSAChanges" },
+	{ 4, 0xa4, "RxFragments" },
+	{ 4, 0xa8, "RxJumboPkt" },
+	{ 4, 0xac, "RxSymblErr" },
+	{ 4, 0xb0, "InRangeErrCount" },
+	{ 4, 0xb4, "OutRangeErrCount" },
+	{ 4, 0xb8, "EEELpiEvent" },
+	{ 4, 0xbc, "EEELpiDuration" },
+	{ 4, 0xc0, "RxDiscard" },
+	{ 4, 0xc8, "TxQPKTQ6" },
+	{ 4, 0xcc, "TxQPKTQ7" },
+	{ 4, 0xd0, "TxPkts64Octets" },
+	{ 4, 0xd4, "TxPkts65to127Octets" },
+	{ 4, 0xd8, "TxPkts128to255Octets" },
+	{ 4, 0xdc, "TxPkts256to511Ocets" },
+	{ 4, 0xe0, "TxPkts512to1023Ocets" },
+	{ 4, 0xe4, "TxPkts1024toMaxPktOcets" },
+};
+
+#define B53_MIBS_58XX_SIZE	ARRAY_SIZE(b53_mibs_58xx)
+
 static int b53_do_vlan_op(struct b53_device *dev, u8 op)
 {
 	unsigned int i;
@@ -635,6 +694,8 @@ static const struct b53_mib_desc *b53_get_mib(struct b53_device *dev)
 		return b53_mibs_65;
 	else if (is63xx(dev))
 		return b53_mibs_63xx;
+	else if (is58xx(dev))
+		return b53_mibs_58xx;
 	else
 		return b53_mibs;
 }
@@ -645,6 +706,8 @@ static unsigned int b53_get_mib_size(struct b53_device *dev)
 		return B53_MIBS_65_SIZE;
 	else if (is63xx(dev))
 		return B53_MIBS_63XX_SIZE;
+	else if (is58xx(dev))
+		return B53_MIBS_58XX_SIZE;
 	else
 		return B53_MIBS_SIZE;
 }
diff --git a/drivers/net/dsa/b53/b53_priv.h b/drivers/net/dsa/b53/b53_priv.h
index cf2ff2cbc8ab..76672dae412d 100644
--- a/drivers/net/dsa/b53/b53_priv.h
+++ b/drivers/net/dsa/b53/b53_priv.h
@@ -175,6 +175,12 @@ static inline int is5301x(struct b53_device *dev)
 		dev->chip_id == BCM53019_DEVICE_ID;
 }
 
+static inline int is58xx(struct b53_device *dev)
+{
+	return dev->chip_id == BCM58XX_DEVICE_ID ||
+		dev->chip_id == BCM7445_DEVICE_ID;
+}
+
 #define B53_CPU_PORT_25	5
 #define B53_CPU_PORT	8
 
-- 
2.7.4
