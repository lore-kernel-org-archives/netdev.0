From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/3] Control ethernet PHY LEDs via LED subsystem
Date: Mon, 28 Mar 2016 08:43:35 -0700
Message-ID: <20160328084335.2b631e99@xeon-e3>
References: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com, ujhelyi.m@gmail.com,
	netdev@vger.kernel.org
To: Vishal Thanki <vishalthanki@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36824 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529AbcC1PnU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2016 11:43:20 -0400
Received: by mail-pf0-f176.google.com with SMTP id u190so140650051pfb.3
        for <netdev@vger.kernel.org>; Mon, 28 Mar 2016 08:43:20 -0700 (PDT)
In-Reply-To: <1458755500-15571-1-git-send-email-vishalthanki@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Mar 2016 18:51:37 +0100
Vishal Thanki <vishalthanki@gmail.com> wrote:

> Hi all,
> 
> Based on suggestions from Andrew and Florian, I have made some changes
> to expose the ethernet PHY LEDs using kernel LED subsystem. The following
> ALPHA patchset introduces two new LED triggers:
> 
> 1) <phydev>-eth-phy-link:
> To monitor the PHY Link status
> 
> 2) <phydev>-eth-phy-activity:
> To monitor the PHY activity status. This trigger may still some more work
> because as of now it just takes decision to set the trigger based on
> PHY state machine and triggers the blink_set with delay_on and delay_off
> parameters set to 0.
> 
> Please provide the review comments so that I can work on this patchset to
> make it complete.
> 
> Thanks,
> Vishal
> 
> Vishal Thanki (3):
>   net: phy: Add ethernet PHY LED triggers
>   net: phy: at8030: Expose the Link and Activity LEDs
>   led: at8030: Add LED driver for AT8030 ethernet PHY
> 
>  drivers/leds/Kconfig         |   7 ++
>  drivers/leds/Makefile        |   1 +
>  drivers/leds/leds-at803x.c   | 158 +++++++++++++++++++++++++++++++++++++++++++
>  drivers/net/phy/Kconfig      |   7 ++
>  drivers/net/phy/Makefile     |   1 +
>  drivers/net/phy/at803x.c     |  55 ++++++++++++++-
>  drivers/net/phy/phy.c        |  20 +++++-
>  drivers/net/phy/phy_device.c |   4 ++
>  drivers/net/phy/phy_led.c    |  70 +++++++++++++++++++
>  drivers/net/phy/phy_led.h    |  37 ++++++++++
>  include/linux/leds.h         |   1 +
>  include/linux/phy.h          |   6 ++
>  include/linux/phy/at803x.h   |  45 ++++++++++++
>  13 files changed, 409 insertions(+), 3 deletions(-)
>  create mode 100644 drivers/leds/leds-at803x.c
>  create mode 100644 drivers/net/phy/phy_led.c
>  create mode 100644 drivers/net/phy/phy_led.h
>  create mode 100644 include/linux/phy/at803x.h
> 

There already is LED control via ethtool.
It is more important that the existing API (ethtool) still work.
