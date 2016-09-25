From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 0/3] ethernet: net: bcmgenet: only use new api ethtool_{get|set}_link_ksettings
Date: Sun, 25 Sep 2016 17:36:31 +0200
Message-ID: <1474817794-31791-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: f.fainelli@gmail.com, jaedon.shin@gmail.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some times ago, a serie of patches were committed :
- commit 62469c76007e ("net: ethernet: bcmgenet: use phydev from struct net_device")
- commit 6b352ebccbcf ("net: ethernet: broadcom: bcmgenet: use new api ethtool_{get|set}_link_ksettings")
The first patch add a regression on this driver, so it should be reverted.
As the second patch depend on the former, it should be reverted too.

The first patch is buggy because there is a "trick" in this driver.
The structure phydev is kept in the private data when the interface
go down, and used when the interface go up to enable the phy before
the function phy_connect is called.

I don't have this hardware, neither the datasheet. So I won't
update the driver to avoid this trick.

But the real goal of the first serie was to move to the new api
ethtool_{get|set}_link_ksettings. So I provide a new version of
the patch without the "cleaning" of driver to use the phydev
store in the net_device structure.

Jaedon Shin (1):
  Revert "net: ethernet: bcmgenet: use phydev from struct net_device"

Philippe Reynes (2):
  Revert "net: ethernet: bcmgenet: use new api
    ethtool_{get|set}_link_ksettings"
  net: ethernet: broadcom: bcmgenet: use new api
    ethtool_{get|set}_link_ksettings

 drivers/net/ethernet/broadcom/genet/bcmgenet.c |   33 ++++++++++++-----------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |    1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   |   24 +++++++++--------
 3 files changed, 31 insertions(+), 27 deletions(-)

-- 
1.7.4.4
