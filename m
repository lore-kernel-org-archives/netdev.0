From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next 0/5] Adding PHY-Tunables and downshift support
Date: Fri, 4 Nov 2016 11:35:37 +0100
Message-ID: <1478255742-25693-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>,
        <cphealy@gmail.com>, <robh@kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0041.outbound.protection.outlook.com ([104.47.40.41]:18752
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750763AbcKDKgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 06:36:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This series add support for PHY tunables, and uses this facility to configure
downshifting. The downshifting mechanism is implemented for MSCC phys.

This series tries to address the comments provided back in mid October when this
feature was posted along with fast-link-failure. Fast-link-failure has been
separated out, but we would like to pick continue on that if/when we agree on
how the phy-tunables and downshifting should be done.

The proposed generic interface is similar to ETHTOOL_GTUNABLE/ETHTOOL_STUNABLE,
it uses the same type (ethtool_tunable/tunable_type_id) but a new enum
(phy_tunable_id) is added to reflect the PHY tunable.

The implementation just call the newly added function pointers in
get_tunable/set_tunable phy_device structure.

To configure downshifting, the ethtool_tunable structure is used. 'id' must be
set to 'ETHTOOL_PHY_DOWNSHIFT', 'type_id' must be set to 'ETHTOOL_TUNABLE_U8'
and 'data' value configure the amount of downshift re-tries.

If configured to DOWNSHIFT_DEV_DISABLE, then downshift is disabled
If configured to DOWNSHIFT_DEV_DEFAULT_COUNT, then it is up to the device to
choose a device-specific re-try count.

Patches to implement this in ethtool will follow in a few minutes.

Please review.

Best regards
Allan and Raju

Raju Lakkaraju (5):
  ethtool: (uapi) Add ETHTOOL_PHY_GTUNABLE and ETHTOOL_PHY_STUNABLE
  ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE
  ethtool: (uapi) Add ETHTOOL_PHY_DOWNSHIFT to PHY tunables
  ethtool: Core impl for ETHTOOL_PHY_DOWNSHIFT tunable
  net: phy: Add downshift get/set support in Microsemi PHYs driver

 drivers/net/phy/mscc.c       | 102 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/phy.h          |   7 +++
 include/uapi/linux/ethtool.h |  11 ++++-
 net/core/ethtool.c           |  82 ++++++++++++++++++++++++++++++++++
 4 files changed, 201 insertions(+), 1 deletion(-)

-- 
2.7.3
