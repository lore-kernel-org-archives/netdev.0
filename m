From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH net v2 0/3] drivers: net: cpsw: phy-handle fixes
Date: Wed, 20 Apr 2016 23:51:31 -0400
Message-ID: <1461210694-29120-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>,
	Andrew Goodbody <andrew.goodbody@cambrionix.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Nicolas Chauvet <kwizart@gmail.com>
To: netdev@vger.kernel.org, linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f68.google.com ([209.85.192.68]:33043 "EHLO
	mail-qg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751407AbcDUDwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 23:52:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Rivshin <drivshin@allworx.com>

The first patch fixes a bug that makes dual_emac mode break if
either slave uses the phy-handle property in the devicetree.

The second patch fixes some cosmetic problems with error messages,
and also makes the binding documentation more explicit.

The third patch cleans up the fixed-link case to work like
the now-fixed phy-handle case.

I have tested on the following hardware configurations:
 - (EVMSK) dual emac, phy_id property in both slaves
 - (EVMSK) dual emac, phy-handle property in both slaves
 - (BeagleBoneBlack) single emac, phy_id property
 - (custom) single emac, fixed-link subnode

Nicolas Chauvet reported testing on an HP t410 (dm8148).

Markus Brunner reported testing v1 on the following [1]:
 - emac0 with phy_id and emac1 with fixed phy
 - emac0 with phy-handle and emac1 with fixed phy
 - emac0 with fixed phy and emac1 with fixed phy


Changes since v1 [2]:
- Rebased
- Added Tested-by from Nicolas Chauvet on all patches
- Added Acked-by from Rob Herring for the binding change in patch 2 [3]

[1] http://www.spinics.net/lists/netdev/msg357890.html
[2] http://www.spinics.net/lists/netdev/msg357772.html
[3] http://www.spinics.net/lists/netdev/msg358254.html

David Rivshin (3):
  drivers: net: cpsw: fix parsing of phy-handle DT property in dual_emac
    config
  drivers: net: cpsw: fix error messages when using phy-handle DT
    property
  drivers: net: cpsw: use of_phy_connect() in fixed-link case

 Documentation/devicetree/bindings/net/cpsw.txt |  4 +--
 drivers/net/ethernet/ti/cpsw.c                 | 41 +++++++++++++-------------
 drivers/net/ethernet/ti/cpsw.h                 |  1 +
 3 files changed, 23 insertions(+), 23 deletions(-)

-- 
2.5.5
