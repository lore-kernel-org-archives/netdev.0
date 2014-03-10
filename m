From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: [PATCH v2 0/3] net: phy: fix uninitalized WOL struct in phy_ethtool_get_wol
Date: Mon, 10 Mar 2014 21:50:58 +0100
Message-ID: <1394484661-4554-1-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1394413270-7169-1-git-send-email-sebastian.hesselbarth@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394413270-7169-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David,

this is a small patch set based on a single patch sent earlier [1] to
fix uninitalized struct ethtool_wolinfo in phy_ethtool_get_wol.
Compared to the single patch, this clears the whole struct
ethtool_wolinfo passed to phy_ethtool_get_wol and adds a check for
non-NULL struct phy_device.

I also added two cleanup patches for current users of
phy_ethtool_get_wol. Those two patches are also based on v3.14-rc1 but
aren't really part of the fix. They can wait for v3.15 and I'll rebase
on request.

[1] https://lkml.org/lkml/2014/3/9/169

Sebastian Hesselbarth (3):
  net: phy: fix uninitalized WOL parameters in phy_ethtool_get_wol
  net: mv643xx_eth: simplify phy_ethtool_get_wol call
  net: cpsw: simplify phy_ethtool_get_wol call

 drivers/net/ethernet/marvell/mv643xx_eth.c | 5 +----
 drivers/net/ethernet/ti/cpsw.c             | 7 +------
 drivers/net/phy/phy.c                      | 4 +++-
 3 files changed, 5 insertions(+), 11 deletions(-)

---
Cc: David Miller <davem@davemloft.net>
Cc: Florian Fainelli <f.fainelli@gmail.com>
Cc: netdev@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-kernel@vger.kernel.org
-- 
1.8.5.3
