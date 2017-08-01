From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 00/11] net: dsa: rework EEE support
Date: Tue,  1 Aug 2017 16:32:30 -0400
Message-ID: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:44764 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752478AbdHAUgr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 16:36:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EEE implies configuring the port's PHY and MAC of both ends of the wire.

The current EEE support in DSA mixes PHY and MAC configuration, which is
bad because PHYs must be configured through a proper PHY driver. The DSA
switch operations for EEE are only meant for configuring the port's MAC,
which are integrated in the Ethernet switch device.

This patchset fixes the EEE support in qca8k driver, makes the DSA layer
call phy_init_eee for all drivers, and remove the EEE support from the
mv88e6xxx driver since the Marvell PHY driver should be enough for it.

Changes in v2:
 - make PHY device and DSA EEE ops mandatory for slave EEE operations.
 - simply return 0 in drivers which don't need to do anything to
   configure the port' MAC. Subsequent PHY calls will be enough.

Vivien Didelot (11):
  net: dsa: PHY device is mandatory for EEE
  net: dsa: qca8k: fix EEE init
  net: dsa: qca8k: enable EEE once
  net: dsa: qca8k: do not cache unneeded EEE fields
  net: dsa: qca8k: empty qca8k_get_eee
  net: dsa: bcm_sf2: remove unneeded supported flags
  net: dsa: mv88e6xxx: call phy_init_eee
  net: dsa: call phy_init_eee in DSA layer
  net: dsa: remove PHY device argument from .set_eee
  net: dsa: mv88e6xxx: remove EEE support
  net: dsa: rename switch EEE ops

 drivers/net/dsa/bcm_sf2.c        | 26 +++--------
 drivers/net/dsa/mv88e6xxx/chip.c | 86 +++++------------------------------
 drivers/net/dsa/mv88e6xxx/chip.h |  6 ---
 drivers/net/dsa/mv88e6xxx/phy.c  | 96 ----------------------------------------
 drivers/net/dsa/mv88e6xxx/phy.h  | 22 ---------
 drivers/net/dsa/mv88e6xxx/port.c | 17 -------
 drivers/net/dsa/mv88e6xxx/port.h |  3 --
 drivers/net/dsa/qca8k.c          | 68 ++++------------------------
 drivers/net/dsa/qca8k.h          |  1 -
 include/net/dsa.h                | 11 +++--
 net/dsa/slave.c                  | 30 ++++++++-----
 11 files changed, 49 insertions(+), 317 deletions(-)

-- 
2.13.3
