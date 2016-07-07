From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/9] net: dsa: mv88e6xxx: STP and Global 2 cleanup
Date: Thu,  7 Jul 2016 08:57:49 -0400
Message-ID: <20160707125758.1547-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41873 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750899AbcGGM6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 08:58:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Marvell switches registers are organized in distinct internal SMI
devices, such as PHY, Port, Global 1 or Global 2 registers sets.

Since not all chips support every registers sets or have slightly
differences in them (such as old 88E6060 or new 88E6390 likely to be
supported soon), make the setup code clearer now by removing a few
family checks and adding flags to describe the Global 2 registers map.

This patchset has no functional changes except enabling basic STP
support and bridging on most chips when getting rid of a few
inconsistencies in chip descriptions (patch 1).

Next patchsets will introduce better description of other register maps.

Vivien Didelot (9):
  net: dsa: mv88e6xxx: remove basic function flags
  net: dsa: mv88e6xxx: split setup of Global 1 and 2
  net: dsa: mv88e6xxx: extract device mapping
  net: dsa: mv88e6xxx: extract trunk mapping
  net: dsa: mv88e6xxx: add cap for MGMT Enables bits
  net: dsa: mv88e6xxx: rework Switch MAC setter
  net: dsa: mv88e6xxx: add cap for PVT
  net: dsa: mv88e6xxx: add cap for Priority Override
  net: dsa: mv88e6xxx: add cap for IRL

 drivers/net/dsa/mv88e6xxx/chip.c      | 423 ++++++++++++++++++++--------------
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h | 149 +++++++-----
 2 files changed, 339 insertions(+), 233 deletions(-)

-- 
2.9.0
