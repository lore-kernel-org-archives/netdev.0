From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/6] net: dsa: abstract PHY accesses
Date: Mon, 15 Aug 2016 17:18:56 -0400
Message-ID: <20160815211902.2236-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Marvell 88E6xxx switch chips have different way to access the PHY
devices registers. 

Old chips use a direct access to the PHY registers. Next chips have a
PHY Polling Unit (PPU) which needs to be disabled before accessing PHY
registers. Newer chips have an indirect access to the PHY devices so
that disabling the PPU is not necessary.

This patchset abstracts these accesses behind a new mv88e6xxx_phy_* API.

It also has the side effect to fix the temperature access code for
88E61xx chips which were using the wrong PHY access functions.

Vivien Didelot (6):
  net: dsa: mv88e6xxx: rename _mv88e6xxx_wait
  net: dsa: mv88e6xxx: describe Multi-chip registers
  net: dsa: mv88e6xxx: rework Global2 SMI PHY access
  net: dsa: mv88e6xxx: abstract PHY ops
  net: dsa: mv88e6xxx: describe PHY page and SerDes
  net: dsa: mv88e6xxx: use the new PHY API

 drivers/net/dsa/mv88e6xxx/chip.c      | 541 ++++++++++++++++++----------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 117 +++++---
 2 files changed, 369 insertions(+), 289 deletions(-)

-- 
2.9.3
