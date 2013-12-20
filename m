From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3 0/8] b44: add support for external PHY
Date: Fri, 20 Dec 2013 02:16:05 +0100
Message-ID: <1387502173-21743-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	f.fainelli@gmail.com, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:53928 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755598Ab3LTBQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 20:16:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for an external phy connected to the mac controlled 
by b44. This is used on home routers of the BCM47xx line where this MAC 
core was used and is contended to an external switch core through MII. 
These patches are in OpenWrt for some time and are tested by different 
users with different devices.

The publicly available Programmer's Reference Guide for some of these 
chips help making this patch it would be nice to have such a 
documentation for more Broadcom Chips like some SoCs.
https://www.broadcom.com/collateral/pg/440X-PG02-R.pdf

v3:
 - remove changes to the fixed phy driver
 - call fixed_phy_add() in arch/mips/bcm47xx/setup.c before the fixed 
   phy gets registered

v2: 
 - add fixed phy driver patch
 - use fixed phy driver in b44
 - some smaller changes and typos

Hauke Mehrtens (8):
  b44: check register instead of PHY address to detect external PHY
  b44: rename B44_PHY_ADDR_NO_PHY to B44_PHY_ADDR_NO_LOCAL_PHY
  b44: abort when no PHY is available at all
  b44: rename b44_mii_{read,write} to b44_mdio_{read,write}_mii
  b44: add phylib support
  b44: activate PHY when MAC is off
  b44: do not set PHY address to 30 for every ext PHY
  b44: use fixed PHY device if we do not find any

 arch/mips/bcm47xx/setup.c             |   10 ++
 drivers/net/ethernet/broadcom/Kconfig |    1 +
 drivers/net/ethernet/broadcom/b44.c   |  250 ++++++++++++++++++++++++++++++---
 drivers/net/ethernet/broadcom/b44.h   |   15 +-
 4 files changed, 250 insertions(+), 26 deletions(-)

-- 
1.7.10.4
