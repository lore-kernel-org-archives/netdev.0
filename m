From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 1/3] ethtool: (uapi) Add ETHTOOL_PHY_LOOPBACK to PHY tunables
Date: Mon, 28 Nov 2016 14:24:30 +0100
Message-ID: <1480339472-5823-2-git-send-email-allan.nielsen@microsemi.com>
References: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0048.outbound.protection.outlook.com ([104.47.33.48]:2464
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754482AbcK1NZ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 08:25:26 -0500
In-Reply-To: <1480339472-5823-1-git-send-email-allan.nielsen@microsemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>

3 types of PHY loopback are supported.
i.e. Near-End Loopback, Far-End Loopback and External Loopback.

Near-End Loopback:
Transmitted data (TXD) is looped back in the PCS block onto the receive
data signal (RXD). When Near-End loopback enable, no data is transmitted
over the network. no data receive from the network.

Far-End Loopback:
This loopback is a special test mode to allow testing the PHY from link
partner side. In this mode data that is received from the link partner pass
through the PHY's receiver, looped back on the MII and transmitted back to
the link partner.
Data present on the transmit data pins of the MAC interface is ignored when
using this test.

External Loopback:
An RJ45 loopback cable can be used to route the transmit signals an the
output of the trnsformer back to the receiver inputs. This loopback will
work at either 10 or 100 or 1000 Mbps speed.
RJ45 Loopback cable created by conncting pin 1 to pin 3 and connecting pin
2 to pin 6.

Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Signed-off-by: Allan W. Nielsen <allan.nielsen@microsemi.com>
---
 include/uapi/linux/ethtool.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/include/uapi/linux/ethtool.h b/include/uapi/linux/ethtool.h
index f0db778..59629f5 100644
--- a/include/uapi/linux/ethtool.h
+++ b/include/uapi/linux/ethtool.h
@@ -254,6 +254,7 @@ struct ethtool_tunable {
 enum phy_tunable_id {
 	ETHTOOL_PHY_ID_UNSPEC,
 	ETHTOOL_PHY_DOWNSHIFT,
+	ETHTOOL_PHY_LOOPBACK,
 	/*
 	 * Add your fresh new phy tunable attribute above and remember to update
 	 * phy_tunable_strings[] in net/core/ethtool.c
@@ -261,6 +262,13 @@ enum phy_tunable_id {
 	__ETHTOOL_PHY_TUNABLE_COUNT,
 };
 
+enum phy_loopback_type {
+	ETHTOOL_PHY_LOOPBACK_DISABLE,
+	ETHTOOL_PHY_LOOPBACK_NEAR,
+	ETHTOOL_PHY_LOOPBACK_FAR,
+	ETHTOOL_PHY_LOOPBACK_EXTN
+};
+
 /**
  * struct ethtool_regs - hardware register dump
  * @cmd: Command number = %ETHTOOL_GREGS
-- 
2.7.3
