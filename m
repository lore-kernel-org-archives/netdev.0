From: Vishal Thanki <vishalthanki@gmail.com>
Subject: [PATCH 0/3] Control ethernet PHY LEDs via LED subsystem
Date: Wed, 23 Mar 2016 18:51:37 +0100
Message-ID: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Cc: Vishal Thanki <vishalthanki@gmail.com>
To: andrew@lunn.ch, f.fainelli@gmail.com, ujhelyi.m@gmail.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:36190 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470AbcCWRvq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 13:51:46 -0400
Received: by mail-wm0-f53.google.com with SMTP id r129so146555605wmr.1
        for <netdev@vger.kernel.org>; Wed, 23 Mar 2016 10:51:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Based on suggestions from Andrew and Florian, I have made some changes
to expose the ethernet PHY LEDs using kernel LED subsystem. The following
ALPHA patchset introduces two new LED triggers:

1) <phydev>-eth-phy-link:
To monitor the PHY Link status

2) <phydev>-eth-phy-activity:
To monitor the PHY activity status. This trigger may still some more work
because as of now it just takes decision to set the trigger based on
PHY state machine and triggers the blink_set with delay_on and delay_off
parameters set to 0.

Please provide the review comments so that I can work on this patchset to
make it complete.

Thanks,
Vishal

Vishal Thanki (3):
  net: phy: Add ethernet PHY LED triggers
  net: phy: at8030: Expose the Link and Activity LEDs
  led: at8030: Add LED driver for AT8030 ethernet PHY

 drivers/leds/Kconfig         |   7 ++
 drivers/leds/Makefile        |   1 +
 drivers/leds/leds-at803x.c   | 158 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/Kconfig      |   7 ++
 drivers/net/phy/Makefile     |   1 +
 drivers/net/phy/at803x.c     |  55 ++++++++++++++-
 drivers/net/phy/phy.c        |  20 +++++-
 drivers/net/phy/phy_device.c |   4 ++
 drivers/net/phy/phy_led.c    |  70 +++++++++++++++++++
 drivers/net/phy/phy_led.h    |  37 ++++++++++
 include/linux/leds.h         |   1 +
 include/linux/phy.h          |   6 ++
 include/linux/phy/at803x.h   |  45 ++++++++++++
 13 files changed, 409 insertions(+), 3 deletions(-)
 create mode 100644 drivers/leds/leds-at803x.c
 create mode 100644 drivers/net/phy/phy_led.c
 create mode 100644 drivers/net/phy/phy_led.h
 create mode 100644 include/linux/phy/at803x.h

-- 
2.4.3
