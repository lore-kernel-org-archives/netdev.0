From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 0/4] net: phy: prevent double suspend
Date: Mon, 26 Jan 2015 22:05:36 -0800
Message-ID: <1422338740-18418-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, s.hauer@pengutronix.de, b38611@freescale.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:59677 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbbA0GGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 01:06:00 -0500
Received: by mail-pa0-f54.google.com with SMTP id eu11so16395285pac.13
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 22:06:00 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Fugang,

This patch series addresses a problem that Fugang and I observed on different
platforms where a given PHY device might end-up being suspended twice.

Once as part of the call from ndo_open() all the way down to phy_detach() and
phy_suspend() and a second time when the generic platform device/driver
suspend/resume callbacks are called in drivers/net/phy/mdio_bus.c.

Thanks to Fugang for giving this a quick try on i.MX6/FEC and reporting
positive test results!

Florian Fainelli (4):
  net: phy: utilize phy_suspend and phy_resume
  net: phy: document has_fixups field
  net: phy: keep track of the PHY suspend state
  net: phy: avoid suspending twice a PHY

 drivers/net/phy/mdio_bus.c   | 14 ++++++++------
 drivers/net/phy/phy_device.c | 22 ++++++++++++++++++----
 include/linux/phy.h          |  3 +++
 3 files changed, 29 insertions(+), 10 deletions(-)

-- 
2.1.0
