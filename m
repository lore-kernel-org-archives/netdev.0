From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 00/11] net: dsa: rework EEE support
Date: Mon, 31 Jul 2017 18:17:08 -0400
Message-ID: <20170731221719.16695-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

EEE implies configuring the port's PHY and MAC of both ends of the wire.

The current EEE support in DSA mixes PHY and MAC configuration, which is
bad because PHYs must be configured through a proper PHY driver. The DSA
switch operations for EEE are only meant for configuring the port's MAC,
which are integrated in the Ethernet switch device.

This patchset fixes the EEE support in qca8k driver, makes the DSA layer
call phy_init_eee for all drivers, and remove the EEE support from the
mv88e6xxx driver since the Marvell PHY driver should be enough for it.

Vivien Didelot (11):
  net: dsa: make EEE ops optional
  net: dsa: qca8k: fix EEE init
  net: dsa: qca8k: enable EEE once
  net: dsa: qca8k: do not cache unneeded EEE fields
  net: dsa: qca8k: remove qca8k_get_eee
  net: dsa: bcm_sf2: remove unneeded supported flags
  net: dsa: mv88e6xxx: call phy_init_eee
  net: dsa: call phy_init_eee in DSA layer
  net: dsa: remove PHY device argument from .set_eee
  net: dsa: mv88e6xxx: remove EEE support
  net: dsa: rename switch EEE ops

 drivers/net/dsa/bcm_sf2.c        | 26 +++--------
 drivers/net/dsa/mv88e6xxx/chip.c | 82 ----------------------------------
 drivers/net/dsa/mv88e6xxx/chip.h |  6 ---
 drivers/net/dsa/mv88e6xxx/phy.c  | 96 ----------------------------------------
 drivers/net/dsa/mv88e6xxx/phy.h  | 22 ---------
 drivers/net/dsa/mv88e6xxx/port.c | 17 -------
 drivers/net/dsa/mv88e6xxx/port.h |  3 --
 drivers/net/dsa/qca8k.c          | 68 ++--------------------------
 drivers/net/dsa/qca8k.h          |  1 -
 include/net/dsa.h                | 11 +++--
 net/dsa/slave.c                  | 48 ++++++++++++--------
 11 files changed, 45 insertions(+), 335 deletions(-)

-- 
2.13.3
