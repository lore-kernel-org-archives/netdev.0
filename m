From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: phy: Unbind/bind fixes
Date: Sun,  5 Feb 2017 14:25:55 -0800
Message-ID: <20170205222557.24739-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:33322 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750851AbdBEW0G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 17:26:06 -0500
Received: by mail-ot0-f194.google.com with SMTP id f9so8516513otd.0
        for <netdev@vger.kernel.org>; Sun, 05 Feb 2017 14:26:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series addresses the inability to safely unbind and bind
PHY drivers by making the appropriate checks throught PHYLIB where we
may be directly responding to user-space queries, as well as from within
the kernel state machine.

The second patch makes the unbind -> bind working by taking care of the
PHY state machine state.

Florian Fainelli (2):
  net: phy: Check phydev->drv
  net: phy: Fix PHY driver bind and unbind events

 drivers/net/phy/phy.c        | 26 ++++++++++++++++++++++----
 drivers/net/phy/phy_device.c | 27 +++++++++++++++++++++++++--
 include/linux/phy.h          |  3 +++
 3 files changed, 50 insertions(+), 6 deletions(-)

-- 
2.9.3
