From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v3 0/3] net: phy: add phy_ethtool_{get|set}_link_ksettings
Date: Tue, 10 May 2016 00:19:40 +0200
Message-ID: <1462832383-25541-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: fugang.duan@nxp.com, f.fainelli@gmail.com, davem@davemloft.net,
	decot@googlers.com, ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ethtool callbacks {get|set}_link_ksettings may be the
same for many drivers. So we add two generics callbacks
phy_ethtool_{get|set}_link_ksettings.

To use those generics callbacks, the ethernet driver must
use the pointer phydev contained in struct net_device, and
not use a private structure to store this pointer.

Changelog:
v3:
- rename function to phy_ethtool_{get|set}_link_ksettings
- move code to net/phy/phy.c
  This feedback were provided by David Decotigny
v2:
- use generic function instead of macro
- ethernet driver use the pointer phydev provided by struct net_device
  Those idea were provided by Ben Hutchings,
  and Florian Fainelli acknowledge them.

Philippe Reynes (3):
  net: phy: add phy_ethtool_{get|set}_link_ksettings
  net: ethernet: fec: use phydev from struct net_device
  net: ethernet: fec: use phy_ethtool_{get|set}_link_ksettings

 drivers/net/ethernet/freescale/fec.h      |    1 -
 drivers/net/ethernet/freescale/fec_main.c |   71 +++++++++--------------------
 drivers/net/phy/phy.c                     |   24 ++++++++++
 include/linux/phy.h                       |    4 ++
 4 files changed, 49 insertions(+), 51 deletions(-)

-- 
1.7.4.4
