From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] phy: bcm-ns-usb3: fix MDIO_BUS dependency
Date: Thu, 27 Jul 2017 17:20:45 -0700 (PDT)
Message-ID: <20170727.172045.1468668424515214509.davem@davemloft.net>
References: <20170726151442.3913622-1-arnd@arndb.de>
        <20170726151442.3913622-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kishon@ti.com, andrew@lunn.ch,
        f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
        raviteja.garimella@broadcom.com, rafal@milecki.pl
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38986 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbdG1AUq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 20:20:46 -0400
In-Reply-To: <20170726151442.3913622-2-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 26 Jul 2017 17:14:00 +0200

> The driver attempts to 'select MDIO_DEVICE', but the code
> is actually a loadable module when PHYLIB=m:
> 
> drivers/phy/broadcom/phy-bcm-ns-usb3.o: In function `bcm_ns_usb3_mdiodev_phy_write':
> phy-bcm-ns-usb3.c:(.text.bcm_ns_usb3_mdiodev_phy_write+0x28): undefined reference to `mdiobus_write'
> drivers/phy/broadcom/phy-bcm-ns-usb3.o: In function `bcm_ns_usb3_module_exit':
> phy-bcm-ns-usb3.c:(.exit.text+0x18): undefined reference to `mdio_driver_unregister'
> drivers/phy/broadcom/phy-bcm-ns-usb3.o: In function `bcm_ns_usb3_module_init':
> phy-bcm-ns-usb3.c:(.init.text+0x18): undefined reference to `mdio_driver_register'
> phy-bcm-ns-usb3.c:(.init.text+0x38): undefined reference to `mdio_driver_unregister'
> 
> Using 'depends on MDIO_BUS' instead will avoid the link error.
> 
> Fixes: af850e14a7ae ("phy: bcm-ns-usb3: add MDIO driver using proper bus layer")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

Applied.
