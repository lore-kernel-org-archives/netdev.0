From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH net v3 0/5] drivers: net: cpsw: phy-handle fixes
Date: Wed, 27 Apr 2016 21:10:03 -0400
Message-ID: <1461805808-4102-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Nicolas Chauvet <kwizart@gmail.com>
To: netdev@vger.kernel.org, linux-omap@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Rivshin <drivshin@allworx.com>

This series fixes a number of related issues around using phy-handle
properties in cpsw emac nodes.

Patch 1 fixes a bug if more than one slave is used, and either
slave uses the phy-handle property in the devicetree.

Patch 2 fixes a NULL pointer dereference which can occur if a
phy-handle property is used and of_phy_connect() return NULL,
such as with a bad devicetree.

Patch 3 fixes an issue where the phy-mode property would be ignored
if a phy-handle property was used. This also fixes a bogus error
message that would be emitted.

Patch 4 fixes makes the binding documentation more explicit that
exactly one PHY property should be used, and also marks phy_id as
deprecated.

Patch 5 cleans up the fixed-link case to work like the now-fixed
phy-handle case.

I have tested on the following hardware configurations:
 - (EVMSK) dual emac, phy_id property in both slaves
 - (EVMSK) dual emac, phy-handle property in both slaves
 - (EVMSK) a bad phy-handle property pointing to &mmc1
 - (EVMSK) phy_id property with incorrect PHY address
 - (BeagleBoneBlack) single emac, phy_id property
 - (custom) single emac, fixed-link subnode

Andrew Goodbody reported testing v2 on a board that doesn't use
dual_emac mode, but with 2 PHYs using phy-handle properties [1].

Nicolas Chauvet reported testing v2 on an HP t410 (dm8148).

Markus Brunner reported testing v1 on the following [2]:
 - emac0 with phy_id and emac1 with fixed phy
 - emac0 with phy-handle and emac1 with fixed phy
 - emac0 with fixed phy and emac1 with fixed phy

[1] https://lkml.org/lkml/2016/4/22/537
[2] http://www.spinics.net/lists/netdev/msg357890.html

David Rivshin (5):
  drivers: net: cpsw: fix parsing of phy-handle DT property in dual_emac
    config
  drivers: net: cpsw: fix segfault in case of bad phy-handle
  drivers: net: cpsw: don't ignore phy-mode if phy-handle is used
  dt: cpsw: phy-handle, phy_id, and fixed-link are mutually exclusive
  drivers: net: cpsw: use of_phy_connect() in fixed-link case

 Documentation/devicetree/bindings/net/cpsw.txt |  6 +--
 drivers/net/ethernet/ti/cpsw.c                 | 69 ++++++++++++++------------
 drivers/net/ethernet/ti/cpsw.h                 |  1 +
 3 files changed, 41 insertions(+), 35 deletions(-)

-- 
2.5.5
