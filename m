From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 0/8] net: dsa: mv88e6xxx: factorize switch info
Date: Sat, 16 Apr 2016 18:41:37 -0400
Message-ID: <1460846505-20305-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset factorizes the mv88e6xxx code by sharing a new extendable
info structure to store static data such as switch family, product
number, number of ports, number of databases and the name.

The next step is to add a "flags" bitmap member to the info structure in
order to simplify the shared code with a feature-based logic instead of
checking their family/ID.

This is a step forward having a single mv88e6xxx driver supporting many
similar devices, like any usual Linux driver.

Changes v2 -> v3:
  - update commit messages and add Andrew's tags
  - keep the info lookup code in a separated function
  - split the single switch ID reading in probe in a new commit

Changes v1 -> v2:
  - define PORT_SWITCH_ID_PROD_NUM_* values
  - use plain struct mv88e6xxx_info
  - remove non used yet ps->rev

Vivien Didelot (8):
  net: dsa: mv88e6xxx: drop double ds assignment
  net: dsa: mv88e6xxx: drop revision probing
  net: dsa: mv88e6xxx: read switch ID in probe
  net: dsa: mv88e6xxx: add switch info
  net: dsa: mv88e6xxx: add family to info
  net: dsa: mv88e6xxx: add number of ports to info
  net: dsa: mv88e6xxx: add number of db to info
  net: dsa: mv88e6xxx: remove switch ID from ps

 drivers/net/dsa/mv88e6123.c |  45 +++++-----
 drivers/net/dsa/mv88e6131.c |  53 ++++++------
 drivers/net/dsa/mv88e6171.c |  36 +++++---
 drivers/net/dsa/mv88e6352.c |  55 ++++++++----
 drivers/net/dsa/mv88e6xxx.c | 206 ++++++++++++++------------------------------
 drivers/net/dsa/mv88e6xxx.h |  92 ++++++++------------
 6 files changed, 214 insertions(+), 273 deletions(-)

-- 
2.8.0
