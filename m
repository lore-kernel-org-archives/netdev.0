From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH RFCv2 0/6] net: phy: Ethernet PHY powerdown optimization
Date: Wed,  4 Dec 2013 16:44:42 +0100
Message-ID: <1386171888-28190-1-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mugunthan V N <mugunthanvnm@ti.com>,
 Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This is v2 of an RFC sent earlier [1] to reduce power consumption of network
PHYs with link that are either unused or the corresponding netdev is down.

In contrast to RFCv1, this now integrates phy_suspend/phy_resume transparent
to the netdev drivers. Also, phy_suspend now only suspends the PHY if WOL is
disabled. Moreover, the phy state machine calls phy_suspend on entering
HALTED state.

Again, a branch with RFCv2 applied to v3.13-rc2 can also be found at
https://github.com/shesselba/linux-dove.git topic/ethphy-power-rfc-v2

[1] http://lwn.net/Articles/574426/

Sebastian Hesselbarth (6):
  net: mv643xx_eth: properly start/stop phy device
  net: phy: marvell: provide genphy suspend/resume
  net: phy: provide phy_resume/phy_suspend helpers
  net: phy: resume/suspend PHYs on attach/detach
  net: phy: suspend unused PHYs on mdio_bus in late_initcall
  net: phy: suspend phydev when going to HALTED

 drivers/net/ethernet/marvell/mv643xx_eth.c |    4 +++-
 drivers/net/phy/marvell.c                  |   22 ++++++++++++++++++++++
 drivers/net/phy/mdio_bus.c                 |   25 +++++++++++++++++++++++++
 drivers/net/phy/phy.c                      |    6 +++++-
 drivers/net/phy/phy_device.c               |   27 +++++++++++++++++++++++++++
 include/linux/phy.h                        |    2 ++
 6 files changed, 84 insertions(+), 2 deletions(-)

---
Cc: David Miller <davem@davemloft.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: Mugunthan V N <mugunthanvnm@ti.com>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
-- 
1.7.2.5
