From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH 0/9] net: phy: PHY reset consolidation
Date: Thu, 5 Dec 2013 16:55:08 -0800
Message-ID: <1386291317-1202-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <sebastian.hesselbarth@gmail.com>,
	<sergei.shtylyov@cogentembedded.com>, <afleming@gmail.com>,
	<kyle@moffetthome.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:21606 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752514Ab3LFBFE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 20:05:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Over the past few months there have been various attempts at doing
"wild" PHY resets eventually bypassing the PHY state machine and causing
various sort of issues whenever auto-negotiation as not enabled.

This patchset resumes the work Kyle Moffett started here:
https://lkml.org/lkml/2011/10/20/301

Once Sebastian's phy_resume/suspend patchet is in, we can also make sure
we consolidate PHY resets after resuming from S2/S3 suspend modes.

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
 drivers/net/ethernet/marvell/pxa168_eth.c  | 19 +--------
 drivers/net/ethernet/renesas/sh_eth.c      |  5 ++-
 drivers/net/ethernet/toshiba/tc35815.c     | 15 ++------
 drivers/net/phy/phy.c                      | 11 +++---
 drivers/net/phy/phy_device.c               | 62 +++++++++++++++++++++++++++++-
 include/linux/phy.h                        |  5 ++-
 10 files changed, 82 insertions(+), 62 deletions(-)

-- 
1.8.3.2
