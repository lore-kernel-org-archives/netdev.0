From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2 0/9] b44: add support for external PHY
Date: Thu, 19 Dec 2013 02:28:37 +0100
Message-ID: <1387416526-7394-1-git-send-email-hauke@hauke-m.de>
Cc: zambrano@broadcom.com, netdev@vger.kernel.org,
	f.fainelli@gmail.com, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:44298 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751463Ab3LSB3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Dec 2013 20:29:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for an external phy connected to the mac controlled 
by b44. This is used on home routers of the BCM47xx line where this MAC 
core was used and is contended to an external switch core through MII. 
These patches are in OpenWrt for some time and are tested by different 
users with different devices.

This also does some changes to the fixed phy driver.

v2: 
 - add fixed phy driver patch
 - use fixed phy driver in b44
 - some smaller changes and typos

Hauke Mehrtens (9):
  fixed-phy: register fixed PHY as platform driver
  b44: check register instead of PHY address to detect external PHY
  b44: rename B44_PHY_ADDR_NO_PHY to B44_PHY_ADDR_NO_LOCAL_PHY
  b44: abort when no PHY is available at all
  b44: rename b44_mii_{read,write} to b44_mdio_{read,write}_mii
  b44: add phylib support
  b44: activate PHY when MAC is off
  b44: do not set PHY address to 30 for every ext PHY
  b44: use fixed PHY device if we do not find any

 arch/mips/ar7/platform.c              |   39 ++++-
 drivers/net/ethernet/broadcom/Kconfig |    1 +
 drivers/net/ethernet/broadcom/b44.c   |  276 ++++++++++++++++++++++++++++++---
 drivers/net/ethernet/broadcom/b44.h   |   15 +-
 drivers/net/phy/fixed.c               |   79 +++++-----
 include/linux/phy_fixed.h             |   21 +--
 6 files changed, 349 insertions(+), 82 deletions(-)

-- 
1.7.10.4
