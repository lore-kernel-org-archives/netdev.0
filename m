From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net v3 0/3] net: phy: Fix PHY module checks and NULL deref in phy_attach_direct()
Date: Wed,  8 Feb 2017 16:13:58 -0800
Message-ID: <20170209001401.2564-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        maowenan <maowenan@huawei.com>, andrew@lunn.ch,
        rmk+kernel@armlinux.org.uk, festevam@gmail.com,
        davem@davemloft.net, nikita.yoush@cogentembedded.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35022 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750941AbdBIAsM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 19:48:12 -0500
Received: by mail-qk0-f193.google.com with SMTP id u25so20179043qki.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 16:48:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series addresses the crash seen with the Generic PHY driver
in phy_attach_direct() introduced in the latest pull to Linus.

We also address how to properly bind and unbind to/from the PHY drivers which
would previously be crashing in flames since we did not stop the state machine.

Thanks!

Changes in v3:

- made more testing as module/built-in, with Generic and non-Generic PHY drivers
- exercised error paths on purpose by injecting errors
- properly incremenet Generic PHY module reference count as well
- fixed the error path to be correct

Changes in v2:

- fixed net: phy: Fix lack of reference count on PHY driver against
  the Generic PHY driver which is special

Florian Fainelli (3):
  net: phy: Fix PHY module checks and NULL deref in phy_attach_direct()
  net: phy: Check phydev->drv
  net: phy: Fix PHY driver bind and unbind events

 drivers/net/phy/phy.c        | 26 +++++++++++++++++++++----
 drivers/net/phy/phy_device.c | 45 ++++++++++++++++++++++++++++++++++++++++----
 include/linux/phy.h          |  3 +++
 3 files changed, 66 insertions(+), 8 deletions(-)

-- 
2.9.3
