From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 0/5] NET: PHY names vs MDIO bus names regression fixes
Date: Mon, 13 Feb 2012 12:23:19 +0100
Message-ID: <1329132204-27946-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:36783 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754748Ab2BMLX6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 06:23:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

This patch serie aims at fixing the regressions introduced with the
"use an unique MDIO bus name" patchset. Some drivers still formatted
the PHY id to use the old bus name (e.g: "0" or "1") and therefore
the PHY probing logic gets broken because their underlying MDIO bus
name was changed too from "0" to <foo>-<id>.

The offending patches got introduced during 3.3-rc1.

Thanks!

Florian Fainelli (5):
  cpmac: fix PHY name to match MDIO bus name
  bcm63xx-enet: fix PHY name to match MDIO bus name
  fec: fix PHY name to match fixed MDIO bus name
  octeon: fix PHY name to match MDIO bus name
  ixp4xx-eth: fix PHY name to match MDIO bus name

 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    2 +-
 drivers/net/ethernet/freescale/fec.c         |    2 +-
 drivers/net/ethernet/octeon/octeon_mgmt.c    |    4 ++--
 drivers/net/ethernet/ti/cpmac.c              |    4 ++--
 drivers/net/ethernet/xscale/ixp4xx_eth.c     |    3 ++-
 5 files changed, 8 insertions(+), 7 deletions(-)

-- 
1.7.5.4
