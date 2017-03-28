From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next] net: phy: Allow building mdio-boardinfo into the kernel
Date: Tue, 28 Mar 2017 22:43:51 +0200
Message-ID: <CAK8P3a1ZQTgBDxO+k=ebXAA=g_fd_5ht7BNxB+=NgB3oM_6sTw@mail.gmail.com>
References: <20170328195709.13549-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Networking <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>, rmk+kernel@armlinux.org.uk
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36200 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752605AbdC1Unx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 16:43:53 -0400
Received: by mail-oi0-f67.google.com with SMTP id b187so1757457oif.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 13:43:52 -0700 (PDT)
In-Reply-To: <20170328195709.13549-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 9:57 PM, Florian Fainelli <f.fainelli@gmail.com> wrote:
> mdio-boardinfo contains code that is helpful for platforms to register
> specific MDIO bus devices independent of how CONFIG_MDIO_DEVICE or
> CONFIG_PHYLIB will be selected (modular or built-in). In order to make
> that possible, let's do the following:
>
> - descend into drivers/net/phy/ unconditionally
>
> - make mdiobus_setup_mdiodev_from_board_info() take a callback argument
>   which allows us not to expose the internal MDIO board info list and
>   mutex, yet maintain the logic within the same file
>
> - relocate the code that creates a MDIO device into
>   drivers/net/phy/mdio_bus.c
>
> - build mdio-boardinfo.o into the kernel as soon as MDIO_DEVICE is
>   defined (y or m)
>
> Fixes: 90eff9096c01 ("net: phy: Allow splitting MDIO bus/device support from PHYs")
> Fixes: 648ea0134069 ("net: phy: Allow pre-declaration of MDIO devices")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Looks good at first glance. I've added this to my randconfig build setup,
let's see if there are any remaining corner cases I can hit.

        Arnd
