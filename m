From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/3] net: dsa: voidify STP setter and FDB/VLAN add ops
Date: Wed,  6 Apr 2016 11:55:02 -0400
Message-ID: <1459958105-1090-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Scott Feldman <sfeldma@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neither the DSA layer nor the bridge code (see br_set_state) really care
about eventual errors from STP state setters, so make it void.

The DSA layer separates the prepare and commit phases of switchdev in
two different functions. Logical errors must not happen in commit
routines, so make them void.

Changes v1 -> v2:
  - rename port_stp_update to port_stp_state_set
  - don't change code flow of bcm_sf2_sw_br_set_stp_state
  - prefer netdev_err over netdev_warn

Vivien Didelot (3):
  net: dsa: make the STP state function return void
  net: dsa: make the FDB add function return void
  net: dsa: make the VLAN add function return void

 Documentation/networking/dsa/dsa.txt |  2 +-
 drivers/net/dsa/bcm_sf2.c            | 25 +++++++--------
 drivers/net/dsa/mv88e6171.c          |  2 +-
 drivers/net/dsa/mv88e6352.c          |  2 +-
 drivers/net/dsa/mv88e6xxx.c          | 44 +++++++++++----------------
 drivers/net/dsa/mv88e6xxx.h          | 14 ++++-----
 include/net/dsa.h                    |  8 ++---
 net/dsa/slave.c                      | 59 ++++++++++++++++--------------------
 8 files changed, 69 insertions(+), 87 deletions(-)

-- 
2.8.0
