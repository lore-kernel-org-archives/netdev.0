From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/4] net: phy: prevent double suspend
Date: Mon, 26 Jan 2015 16:31:09 -0800
Message-ID: <1422318673-9418-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, s.hauer@pengutronix.de, b38611@freescale.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:59204 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756268AbbA0Abi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 19:31:38 -0500
Received: by mail-pa0-f47.google.com with SMTP id lj1so14740798pab.6
        for <netdev@vger.kernel.org>; Mon, 26 Jan 2015 16:31:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Fugang,

This patch series addresses a problem that Fugang and I observed on different
platforms where a given PHY device might end-up being suspended twice.

Once as part of the call from ndo_open() all the way down to phy_detach() and
phy_suspend() and a second time when the generic platform device/driver
suspend/resume callbacks are called in drivers/net/phy/mdio_bus.c.

Fugang, please test this as an alternative to your submission, since it did
break for me on GENET at least. Thanks!

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
