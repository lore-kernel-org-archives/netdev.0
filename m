From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH RFC net-next 0/3] net: phy: Read if PHY can stop its clock
Date: Mon, 27 Mar 2017 11:47:18 -0700
Message-ID: <20170327184721.30275-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34395 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752020AbdC0Srb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 14:47:31 -0400
Received: by mail-qt0-f193.google.com with SMTP id x35so8917545qtc.1
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 11:47:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series update PHYLIB to read whether the PHY is actually capable of
stopping its clocks during EEE low power modes.

One problem (not the only one) with phy_init_eee() is that it takes a
clk_stop_enable argument that the caller has no idea how to determine.

This patch series makes the PHY library read whether the PHY is capable of
stopping its clock (after config_init has been called) which will allow
future patches to rename clk_stop_enable into something that conveys an
intention (and therefore could fail if the PHY does not support it).

Florian Fainelli (3):
  net: mdio: add definition for MDIO_STAT1_CLOCK_STOP_CAPABLE
  net: phy: read whether PHY supports stopping clock during LPI
  net: phy: stop the PHY clock during LPI only if supported

 drivers/net/phy/phy.c        |  2 +-
 drivers/net/phy/phy_device.c | 23 ++++++++++++++++++++++-
 include/linux/phy.h          |  2 ++
 include/uapi/linux/mdio.h    |  1 +
 4 files changed, 26 insertions(+), 2 deletions(-)

-- 
2.9.3
