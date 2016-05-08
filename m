From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2 0/3] net: ethtool: add ethtool_op_{get|set}_link_ksettings
Date: Sun,  8 May 2016 23:44:34 +0200
Message-ID: <1462743877-31738-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: fugang.duan@nxp.com, davem@davemloft.net, ben@decadent.org.uk,
	kan.liang@intel.com, decot@googlers.com, aduyck@mirantis.com,
	jiri@mellanox.com, jacob.e.keller@intel.com, tom@herbertland.com,
	andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ethtool callbacks {get|set}_link_ksettings may be the
same for many drivers. So we add two generics callbacks
ethtool_op_{get|set}_link_ksettings.

To use those generics callbacks, the ethernet driver must
use the pointer phydev contained in struct net_device, and
not use a private structure to store this pointer.

Changelog:
v2:
- use generic function instead of macro
- ethernet driver use the pointer phydev provided by struct net_device
  Those idea were provided by Ben Hutchings,
  and Florian Fainelli acknowledge them.

Philippe Reynes (3):
  net: core: ethtool: add ethtool_op_{get|set}_link_ksettings
  net: ethernet: fec: use phydev from struct net_device
  net: ethernet: fec: use ethtool_op_{get|set}_link_ksettings

 drivers/net/ethernet/freescale/fec.h      |    1 -
 drivers/net/ethernet/freescale/fec_main.c |   71 +++++++++--------------------
 include/linux/ethtool.h                   |    5 ++
 net/core/ethtool.c                        |   24 ++++++++++
 4 files changed, 50 insertions(+), 51 deletions(-)

-- 
1.7.4.4
