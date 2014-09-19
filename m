From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/8] net: phy: Broadcom BCM7xxx PHY workaround update
Date: Fri, 19 Sep 2014 13:07:48 -0700
Message-ID: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:50174 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069AbaISUIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:08:12 -0400
Received: by mail-pd0-f173.google.com with SMTP id y10so573077pdj.4
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 13:08:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch sets the change to of_phy_connect() that you have seen before,
this time with the full context of why it is useful and applicable here.

Due to some design decision, the internal PHY on Broadcom BCM7xxx chips
is not entirely self contained and does not report its internal revision
through MII_PHYSID2, that is left to external PHY designs.

This forces us to get the PHY revision from the GENET and SF2 switch drivers
because those two peripherals integrate such a PHY and do contain the PHY
revision in their registers.

The approach taken here is hopefully easy to extend to similar needs for
other chips/ as well.

Thanks!

Florian Fainelli (8):
  of: mdio: honor flags passed to of_phy_connect
  net: phy: broadcom: add helper for PHY revision and patch level
  net: phy: bcm7xxx: do not use PHY_BRCM_100MBPS_WAR
  net: bcmgenet: remove PHY_BRCM_100MBPS_WAR
  net: bcmgenet: communicate integrated PHY revision to PHY driver
  net: dsa: allow switch drivers to specify phy_device::dev_flags
  net: dsa: bcm_sf2: communicate integrated PHY revision to PHY driver
  net: phy: bcm7xxx: utilize PHY revision in config_init

 drivers/net/dsa/bcm_sf2.c                      | 16 ++++++++++++++++
 drivers/net/dsa/bcm_sf2.h                      |  1 +
 drivers/net/dsa/bcm_sf2_regs.h                 |  1 +
 drivers/net/ethernet/broadcom/genet/bcmgenet.c |  7 +++++++
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 +
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 18 ++++++------------
 drivers/net/phy/bcm7xxx.c                      | 25 +++++++++++++++++--------
 drivers/of/of_mdio.c                           |  2 ++
 include/linux/brcmphy.h                        |  3 ++-
 include/net/dsa.h                              |  1 +
 net/dsa/slave.c                                |  9 ++++++++-
 11 files changed, 62 insertions(+), 22 deletions(-)

-- 
1.9.1
