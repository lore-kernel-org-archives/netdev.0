From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net 0/3] net: dsa: mv88e6xxx: fix hardware cross-chip bridging
Date: Thu, 14 Apr 2016 14:42:06 -0400
Message-ID: <1460659329-11473-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to accelerate cross-chip switching of frames with the hardware,
the DSA Tag ports, used to interconnect switch devices, must learn SA
and DA addresses, and share the same FDB with the user ports.

The two first patches restore address learning on DSA links. This fixes
hardware cross-chip bridging in a VLAN filtering enabled system, which
implements a bridge group as a 802.1Q VLAN and thus share an isolated
address database between DSA and user ports.

The third patch changes the distinct default databases used for each
port, to the same address database. This fixes the hardware cross-chip
bridging in a VLAN filtering disabled system, where a bridge group gets
implemented only as a port-based VLAN.

Vivien Didelot (3):
  net: dsa: mv88e6xxx: unlock DSA and CPU ports
  net: dsa: mv88e6xxx: enable SA learning on DSA ports
  net: dsa: mv88e6xxx: share a default FDB

 drivers/net/dsa/mv88e6xxx.c | 34 +++++-----------------------------
 1 file changed, 5 insertions(+), 29 deletions(-)

-- 
2.8.0
