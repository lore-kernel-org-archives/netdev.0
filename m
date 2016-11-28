From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 0/3] Adding PHY Loopback tunable
Date: Mon, 28 Nov 2016 14:23:31 +0100
Message-ID: <1480339411-5768-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0065.outbound.protection.outlook.com ([104.47.40.65]:15232
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754473AbcK1NXz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 08:23:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This series add support for PHY Loopback tunable, and implement it
for MSCC phys.

To configure loopback, the ethtool_tunable structure is used. 'id' must be
set to 'ETHTOOL_PHY_LOOPBACK' and 'data' specifies the loopback type:
ETHTOOL_PHY_LOOPBACK_* (DISABLE, NEAR, FAR or EXTN).

Here is how to configure loopback using ethtool:

Ethtool Help: ethtool -h for PHY tunables
    ethtool --set-phy-tunable DEVNAME      Set PHY tunable
                [ loopback off|near|far|extn ]
    ethtool --get-phy-tunable DEVNAME      Get PHY tunable
                [ loopback ]

Ethtool ex:
  ethtool --set-phy-tunable eth0 loopback near
  ethtool --set-phy-tunable eth0 loopback far
  ethtool --set-phy-tunable eth0 loopback extn
  ethtool --set-phy-tunable eth0 loopback off
  ethtool --get-phy-tunable eth0 loopback

Patches to ethtool will follow shortly.

The feature is tested on Beaglebone Black with VSC 8531 PHY.

Please review.

Best regards
Allan and Raju

Raju Lakkaraju (3):
  ethtool: (uapi) Add ETHTOOL_PHY_LOOPBACK to PHY tunables
  ethtool: Core impl for ETHTOOL_PHY_LOOPBACK tunable.
  net: phy: Add Loopback support in Microsemi PHYs driver

 drivers/net/phy/mscc.c       | 118 +++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/ethtool.h |   8 +++
 net/core/ethtool.c           |   2 +
 3 files changed, 128 insertions(+)

-- 
2.7.3
