From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v2 0/5] net: phy: Ethernet PHY powerdown optimization
Date: Fri, 13 Dec 2013 10:20:24 +0100
Message-ID: <1386926429-28818-1-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mugunthan V N <mugunthanvnm@ti.com>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386513631-11284-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is v2 of the ethernet PHY power optimization patches to reduce
power consumption of network PHYs with link that are either unused or
the corresponding netdev is down.

Compared to the last version, this patch set drops a patch to disable
unused PHYs after late initcall, as it is not compatible with a modular
mdio bus [1]. I'll investigate different ways to have a modular mdio bus
driver get notified when driver loading is done.

Again, a branch with v2 applied to v3.13-rc2 can also be found at
https://github.com/shesselba/linux-dove.git topic/ethphy-power-v2

[1] http://www.spinics.net/lists/arm-kernel/msg293028.html

Sebastian Hesselbarth (5):
  net: mv643xx_eth: properly start/stop phy device
  net: phy: marvell: provide genphy suspend/resume
  net: phy: provide phy_resume/phy_suspend helpers
  net: phy: resume/suspend PHYs on attach/detach
  net: phy: suspend phydev when going to HALTED

 drivers/net/ethernet/marvell/mv643xx_eth.c |    4 +++-
 drivers/net/phy/marvell.c                  |   22 ++++++++++++++++++++++
 drivers/net/phy/phy.c                      |    6 +++++-
 drivers/net/phy/phy_device.c               |   27 +++++++++++++++++++++++++++
 include/linux/phy.h                        |    2 ++
 5 files changed, 59 insertions(+), 2 deletions(-)

---
Cc: David Miller <davem@davemloft.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
-- 
1.7.2.5
