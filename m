From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/4] net: dsa: mv88e6xxx: fix hardware bridging
Date: Sun, 11 Oct 2015 18:08:34 -0400
Message-ID: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Guenter Roeck <linux@roeck-us.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DSA and its drivers currently hook the NETDEV_CHANGEUPPER net_device event in
order to configure the VLAN map of every port.

This VLAN map is a feature of these switch chips to hardcode and restrict which
output ports a given input port can egress frames to.

A Linux bridge is a simple untagged VLAN propagated by the bridge code itself.
With a proper 802.1Q support, a driver does not need this hook anymore, and
will simply program the related VLAN object.

This patchset improves the hardware bridging code in the mv88e6xxx driver with
a strict 802.1Q mode.

Ideally, the equivalent must be done for Broadcom Starfighter 2 and Rocker,
before completely getting rid of this hook.

Vivien Didelot (4):
  net: dsa: mv88e6xxx: bridges do not need an FID
  net: dsa: mv88e6xxx: do not support per-port FID
  net: dsa: do not warn unsupported bridge ops
  net: dsa: mv88e6xxx: fix hardware bridging

 drivers/net/dsa/mv88e6171.c |   2 -
 drivers/net/dsa/mv88e6352.c |   2 -
 drivers/net/dsa/mv88e6xxx.c | 215 ++++++--------------------------------------
 drivers/net/dsa/mv88e6xxx.h |   8 --
 net/dsa/slave.c             |   2 +-
 5 files changed, 26 insertions(+), 203 deletions(-)

-- 
2.6.0
