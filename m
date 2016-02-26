From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/9] net: dsa: mv88e6xxx: implement VLAN filtering
Date: Fri, 26 Feb 2016 13:15:59 -0500
Message-ID: <1456510568-13679-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Kevin Smith <kevin.smith@elecsyscorp.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixes hardware bridging for non 802.1Q aware systems.

The mv88e6xxx DSA driver currently depends on CONFIG_VLAN_8021Q and
CONFIG_BRIDGE_VLAN_FILTERING enabled for correct bridging between switch ports.

Patch 1/9 adds support for the VLAN filtering switchdev attribute in DSA.

Patchs 2/9 and 3/9 add helper functions for the following patches.

Patchs 4/9 to 6/9 assign dynamic address databases to VLANs, ports, and
bridge groups (the lowest available FID is cleared and assigned), and thus
restore support for per-port FDB operations.

Patchs 7/9 to 9/9 refine ports isolation and setup 802.1Q on user demand.

With this patchset, ports get correctly bridged and the driver behaves as
expected, with or without 802.1Q support.

With CONFIG_VLAN_8021Q enabled, setting a default PVID to the bridge correctly
propagates the corresponding VLAN, in addition to the hardware bridging:

    # echo 42 > /sys/class/net/<bridge>/bridge/default_pvid

But considering CONFIG_BRIDGE_VLAN_FILTERING enabled, the hardware VLAN
filtering is enabled on all bridge members only when the user requests it:

    # echo 1 > /sys/class/net/<bridge>/bridge/vlan_filtering

Vivien Didelot (9):
  net: dsa: support VLAN filtering switchdev attr
  net: dsa: mv88e6xxx: extract single VLAN retrieval
  net: dsa: mv88e6xxx: extract single FDB dump
  net: dsa: mv88e6xxx: assign dynamic FDB to VLANs
  net: dsa: mv88e6xxx: assign default FDB to ports
  net: dsa: mv88e6xxx: assign dynamic FDB to bridges
  net: dsa: mv88e6xxx: restore VLANTable map control
  net: dsa: mv88e6xxx: remove reserved VLANs
  net: dsa: mv88e6xxx: support VLAN filtering

 drivers/net/dsa/mv88e6171.c |   1 +
 drivers/net/dsa/mv88e6352.c |   1 +
 drivers/net/dsa/mv88e6xxx.c | 441 ++++++++++++++++++++++++++++++++++----------
 drivers/net/dsa/mv88e6xxx.h |   6 +
 include/net/dsa.h           |   2 +
 net/dsa/slave.c             |  21 +++
 6 files changed, 370 insertions(+), 102 deletions(-)

-- 
2.7.1
