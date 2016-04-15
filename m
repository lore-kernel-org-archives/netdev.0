From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/7] net: dsa: mv88e6xxx: factorize switch info
Date: Fri, 15 Apr 2016 19:21:21 -0400
Message-ID: <1460762488-2633-1-git-send-email-vivien.didelot@savoirfairelinux.com>
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

Changes v1 -> v2:
  - define PORT_SWITCH_ID_PROD_NUM_* values
  - use plain struct mv88e6xxx_info
  - remove non used yet ps->rev

Vivien Didelot (7):
  net: dsa: mv88e6xxx: drop double ds assignment
  net: dsa: mv88e6xxx: drop revision probing
  net: dsa: mv88e6xxx: add switch info
  net: dsa: mv88e6xxx: add family to info
  net: dsa: mv88e6xxx: add number of ports to info
  net: dsa: mv88e6xxx: add number of db to info
  net: dsa: mv88e6xxx: remove switch ID

 drivers/net/dsa/mv88e6123.c |  45 +++++-----
 drivers/net/dsa/mv88e6131.c |  53 ++++++------
 drivers/net/dsa/mv88e6171.c |  36 +++++---
 drivers/net/dsa/mv88e6352.c |  55 ++++++++----
 drivers/net/dsa/mv88e6xxx.c | 200 ++++++++++++--------------------------------
 drivers/net/dsa/mv88e6xxx.h |  92 +++++++++-----------
 6 files changed, 203 insertions(+), 278 deletions(-)

-- 
2.8.0
