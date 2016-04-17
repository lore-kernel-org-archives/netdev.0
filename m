From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v4 0/9] net: dsa: mv88e6xxx: factorize switch info
Date: Sun, 17 Apr 2016 13:23:54 -0400
Message-ID: <1460913843-7459-1-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Changes v3 -> v4:
  - constify probed name in DSA
  - rebase patchset above conflicting commit 48ace4e

Changes v2 -> v3:
  - update commit messages and add Andrew's tags
  - keep the info lookup code in a separated function
  - split the single switch ID reading in probe in a new commit

Changes v1 -> v2:
  - define PORT_SWITCH_ID_PROD_NUM_* values
  - use plain struct mv88e6xxx_info
  - remove non used yet ps->rev

Vivien Didelot (9):
  net: dsa: constify probed name
  net: dsa: mv88e6xxx: drop double ds assignment
  net: dsa: mv88e6xxx: drop revision probing
  net: dsa: mv88e6xxx: read switch ID in probe
  net: dsa: mv88e6xxx: add switch info
  net: dsa: mv88e6xxx: add family to info
  net: dsa: mv88e6xxx: add number of ports to info
  net: dsa: mv88e6xxx: add number of db to info
  net: dsa: mv88e6xxx: remove switch ID from ps

 drivers/net/dsa/bcm_sf2.c   |   6 +-
 drivers/net/dsa/mv88e6060.c |  10 +--
 drivers/net/dsa/mv88e6123.c |  51 +++++------
 drivers/net/dsa/mv88e6131.c |  59 ++++++------
 drivers/net/dsa/mv88e6171.c |  42 ++++++---
 drivers/net/dsa/mv88e6352.c |  61 ++++++++-----
 drivers/net/dsa/mv88e6xxx.c | 215 ++++++++++++++------------------------------
 drivers/net/dsa/mv88e6xxx.h |  97 +++++++++-----------
 include/net/dsa.h           |   5 +-
 net/dsa/dsa.c               |   6 +-
 10 files changed, 247 insertions(+), 305 deletions(-)

-- 
2.8.0
