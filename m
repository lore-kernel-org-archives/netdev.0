From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/7] net: dsa: mv88e6xxx: HW bridging support for 6185
Date: Sat, 26 Mar 2016 21:59:36 -0400
Message-ID: <1459043983-12088-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Guenter Roeck <linux@roeck-us.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All packets passing through a switch of the 6185 family are currently all
directed to the CPU port. This means that port bridging is software driven.

To enable hardware bridging for this switch family, we need to implement the
port mapping operations, the FDB operations, and optionally the VLAN operations
(for 802.1Q and VLAN filtering aware systems).

However this family only has 256 FDBs indexed by 8-bit identifiers, opposed to
4096 FDBs with 12-bit identifiers for other families such as 6352. It also
doesn't have dedicated FID registers for ATU and VTU operations.

This patchset fixes these differences, and enable hardware bridging for 6185.

Vivien Didelot (7):
  net: dsa: mv88e6xxx: 6185 port default FID is 8-bit
  net: dsa: mv88e6xxx: 6185 has only 256 FDBs
  net: dsa: mv88e6xxx: write FID in ATU command
  net: dsa: mv88e6xxx: fix ATU FID access for 6185
  net: dsa: mv88e6xxx: fix VTU FID access for 6185
  net: dsa: mv88e6xxx: map destination addresses for 6185
  net: dsa: mv88e6131: enable hardware bridging

 drivers/net/dsa/mv88e6131.c | 11 ++++++
 drivers/net/dsa/mv88e6xxx.c | 84 ++++++++++++++++++++++++++++++++-------------
 drivers/net/dsa/mv88e6xxx.h |  7 ++--
 3 files changed, 76 insertions(+), 26 deletions(-)

-- 
2.7.4
