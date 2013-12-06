From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/9] net: phy: consolidate PHY reset
Date: Fri, 6 Dec 2013 13:01:29 -0800
Message-ID: <1386363698-8407-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:32631 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758337Ab3LFVDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 16:03:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset consolidates the PHY reset through the MII BMCR
register by using a central place were this is done.

This patchset resumes the work Kyle Moffett started here:
https://lkml.org/lkml/2011/10/20/301

Note that at this point, drivers doing funky things after issuing
a PHY reset using phy_init_hw() will still suffer from PHY state
machine problems, this will be taken care of later on.

Florian Fainelli (9):
  net: phy: report link partner features through ethtool
  net: phy: use phy_init_hw instead of open-coding it
  net: greth: use phy_read_status()
  net: bfin_mac: do not reset PHY after phy_start()
  net: phy: consolidate PHY reset in phy_init_hw()
  net: mv643xx_eth: use phy_init_hw to reset PHY
  net: pxa168_eth: use phy_init_hw for PHY reset
  net: tc35815: use phy_init_hw for PHY reset
  net: sh_eth: do not issue a wild PHY reset through BMCR

 Documentation/networking/phy.txt           |  3 +-
 drivers/net/ethernet/adi/bfin_mac.c        |  1 -
 drivers/net/ethernet/aeroflex/greth.c      |  2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c | 21 +---------
 drivers/net/ethernet/marvell/pxa168_eth.c  | 20 +---------
 drivers/net/ethernet/renesas/sh_eth.c      |  5 ++-
 drivers/net/ethernet/toshiba/tc35815.c     | 15 ++------
 drivers/net/phy/phy.c                      | 11 +++---
 drivers/net/phy/phy_device.c               | 62 +++++++++++++++++++++++++++++-
 include/linux/phy.h                        |  5 ++-
 10 files changed, 82 insertions(+), 63 deletions(-)

-- 
1.8.3.2
