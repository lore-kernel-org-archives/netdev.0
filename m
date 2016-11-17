From: "Allan W. Nielsen" <allan.nielsen@microsemi.com>
Subject: [PATCH net-next v3 0/5] Adding PHY-Tunables and downshift support
Date: Thu, 17 Nov 2016 13:07:19 +0100
Message-ID: <1479384444-31122-1-git-send-email-allan.nielsen@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <raju.lakkaraju@microsemi.com>, <allan.nielsen@microsemi.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0061.outbound.protection.outlook.com ([104.47.40.61]:57280
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S936373AbcKQRja (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 12:39:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

(This is a re-post of the v3 patch set with a new cover letter - I was not
aware that the cover letters was used a commit comments in merge commits).

This series add support for PHY tunables, and uses this facility to
configure downshifting. The downshifting mechanism is implemented for MSCC
phys.

This series tries to address the comments provided back in mid October when
this feature was posted along with fast-link-failure. Fast-link-failure has
been separated out, but we would like to pick continue on that if/when we
agree on how the phy-tunables and downshifting should be done.

The proposed generic interface is similar to
ETHTOOL_GTUNABLE/ETHTOOL_STUNABLE, it uses the same type
(ethtool_tunable/tunable_type_id) but a new enum (phy_tunable_id) is added
to reflect the PHY tunable.

The implementation just call the newly added function pointers in
get_tunable/set_tunable phy_device structure.

To configure downshifting, the ethtool_tunable structure is used. 'id' must
be set to 'ETHTOOL_PHY_DOWNSHIFT', 'type_id' must be set to
'ETHTOOL_TUNABLE_U8' and 'data' value configure the amount of downshift
re-tries.

If configured to DOWNSHIFT_DEV_DISABLE, then downshift is disabled If
configured to DOWNSHIFT_DEV_DEFAULT_COUNT, then it is up to the device to
choose a device-specific re-try count.

Tested on Beaglebone Black with VSC 8531 PHY.

Change set:
v0:

- Link Speed downshift and Fast Link failure-2 features coded by using
  Device tree.
v1: 
- Split the Downshift and FLF2 features in different set of patches.
- Removed DT access and implemented IOCTL access suggested by Andrew.
- Added function pointers in get_tunable/set_tunable phy_device structure
v2:
- Added trace message with a hist is printed when downshifting clould not
  be eanbled with the requested count
- (ethtool) Syntax is changed from "--set-phy-tunable downshift on|off|%d"
  to "--set-phy-tunable [downshift on|off [count N]]" - as requested by
  Andrew.
v3:
- Fixed Spelling in "net: phy: Add downshift get/set support in Microsemi
  PHYs driver"

Raju Lakkaraju (5):
  ethtool: (uapi) Add ETHTOOL_PHY_GTUNABLE and ETHTOOL_PHY_STUNABLE
  ethtool: Implements ETHTOOL_PHY_GTUNABLE/ETHTOOL_PHY_STUNABLE
  ethtool: (uapi) Add ETHTOOL_PHY_DOWNSHIFT to PHY tunables
  ethtool: Core impl for ETHTOOL_PHY_DOWNSHIFT tunable
  net: phy: Add downshift get/set support in Microsemi PHYs driver

 drivers/net/phy/mscc.c       | 100 +++++++++++++++++++++++++++++++++++++++++++
 include/linux/phy.h          |   7 +++
 include/uapi/linux/ethtool.h |  18 +++++++-
 net/core/ethtool.c           |  93 ++++++++++++++++++++++++++++++++++++++++
 4 files changed, 217 insertions(+), 1 deletion(-)

-- 
2.7.4
