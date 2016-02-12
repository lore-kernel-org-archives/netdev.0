From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/4] net: dsa: pass bridge device to drivers
Date: Fri, 12 Feb 2016 12:09:37 -0500
Message-ID: <1455296981-27998-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset simplifies the DSA layer.

A switch may support multiple bridges with the same hardware VLAN. Thus a check
such as dsa_bridge_check_vlan_range must be moved from the DSA layer to the
concerned driver.

The first purpose of this patchset is to help moving this check to the
mv88e6xxx driver, which is the only one affected at the moment.

To do that, pass directly the bridge net_device structure down to the DSA
drivers, instead of calculating a bitmask of bridge members.

The second purpose is to prepare the replacement of the complex
port_vlan_getnext approach. A second patchset is ready to follow, implementing
port_vlan_dump and thus simplifying the DSA slave code one more time.

Note that this patchset applies on top of https://lkml.org/lkml/2016/2/5/532.

Vivien Didelot (4):
  net: dsa: mv88e6xxx: add port private structure
  net: dsa: pass bridge down to drivers
  net: dsa: mv88e6xxx: check hardware VLAN in use
  net: dsa: remove dsa_bridge_check_vlan_range

 Documentation/networking/dsa/dsa.txt |  7 +---
 drivers/net/dsa/bcm_sf2.c            | 12 +++---
 drivers/net/dsa/bcm_sf2.h            |  2 +
 drivers/net/dsa/mv88e6xxx.c          | 81 ++++++++++++++++++++++++++++++++++--
 drivers/net/dsa/mv88e6xxx.h          | 13 ++++--
 include/net/dsa.h                    |  5 +--
 net/dsa/slave.c                      | 81 +-----------------------------------
 7 files changed, 102 insertions(+), 99 deletions(-)

-- 
2.7.1
