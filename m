From: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Subject: [PATCH 0/3] drivers: net: cpsw: phy-handle fixes
Date: Tue, 22 Dec 2015 19:36:31 -0500
Message-ID: <1450830994-5450-1-git-send-email-drivshin.allworx@gmail.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org, David Miller <davem@davemloft.net>,
	Heiko Schocher <hs@denx.de>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Markus Brunner <systemprogrammierung.brunner@gmail.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:33294 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756031AbbLWAic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2015 19:38:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Rivshin <drivshin@allworx.com>

This series is based on the tip of the net tree.

The first patch fixes a bug that makes dual_emac mode break if
either slave uses the phy-handle property in the devicetree.

The second patch fixes some cosmetic problems with error messages,
and also makes the binding documentation more explicit.

The third patch cleans up the fixed-link case to work like
the now-fixed phy-handle case.

I have tested on the following hardware configurations:
 - (EVMSK) dual emac, phy_id property in both slaves
 - (BeagleBoneBlack) single emac, phy_id property
 - (custom) single emac, fixed-link subnode
Note that I don't have a board which would uses a phy-handle property,
though I have used hacked devicetrees to exercise the code paths.
Testing by anyone who has real hardware using phy-handle or dual_emac
with fixed-link would be appreciated.

David Rivshin (3):
  drivers: net: cpsw: fix parsing of phy-handle DT property in dual_emac
    config
  drivers: net: cpsw: fix error messages when using phy-handle DT
    property
  drivers: net: cpsw: use of_phy_connect() in fixed-link case

 Documentation/devicetree/bindings/net/cpsw.txt |  4 +--
 drivers/net/ethernet/ti/cpsw.c                 | 40 +++++++++++++-------------
 drivers/net/ethernet/ti/cpsw.h                 |  1 +
 3 files changed, 23 insertions(+), 22 deletions(-)

-- 
2.5.0
