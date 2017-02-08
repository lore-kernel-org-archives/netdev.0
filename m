From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v2 0/3] net: phy: Unbind/bind fixes
Date: Tue,  7 Feb 2017 23:37:43 -0800
Message-ID: <20170208073746.10963-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, rmk+kernel@armlinux.org.uk,
        maowenan@huawei.com, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:33424 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932438AbdBHHhu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 02:37:50 -0500
Received: by mail-ot0-f193.google.com with SMTP id f9so17145948otd.0
        for <netdev@vger.kernel.org>; Tue, 07 Feb 2017 23:37:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series addresses the inability to safely unbind and bind
PHY drivers by making the appropriate checks throught PHYLIB where we
may be directly responding to user-space queries, as well as from within
the kernel state machine.

The second patch makes the unbind -> bind working by taking care of the
PHY state machine state.

Changes in v2:

- fixed net: phy: Fix lack of reference count on PHY driver against
  the Generic PHY driver which is special

Florian Fainelli (3):
  net: phy: Fix PHY module checks
  net: phy: Check phydev->drv
  net: phy: Fix PHY driver bind and unbind events

 drivers/net/phy/phy.c        | 26 ++++++++++++++++++++++----
 drivers/net/phy/phy_device.c | 35 ++++++++++++++++++++++++++++++-----
 include/linux/phy.h          |  3 +++
 3 files changed, 55 insertions(+), 9 deletions(-)

-- 
2.9.3
