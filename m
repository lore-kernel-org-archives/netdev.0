From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/6] net: dsa: mv88e6131: HW bridging support for 6185
Date: Thu, 31 Mar 2016 16:53:40 -0400
Message-ID: <1459457626-30082-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
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

Changes v1 -> v2:
 - Describe the different numbers of databases and prefer a feature-based logic
   over the current ID/family-based logic.

Vivien Didelot (6):
  net: dsa: mv88e6xxx: protect SID register access
  net: dsa: mv88e6xxx: protect FID registers access
  net: dsa: mv88e6xxx: variable number of databases
  net: dsa: mv88e6xxx: support 256 databases
  net: dsa: mv88e6xxx: map destination addresses for 6185
  net: dsa: mv88e6131: enable hardware bridging

 drivers/net/dsa/mv88e6131.c |  11 ++++
 drivers/net/dsa/mv88e6xxx.c | 134 +++++++++++++++++++++++++++++++++++---------
 2 files changed, 118 insertions(+), 27 deletions(-)

-- 
2.7.4
