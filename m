From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH -next] net/phy: fix phy_bcm_nsp_usb3.c build and kconfig
Date: Mon, 30 Jan 2017 17:13:00 -0800
Message-ID: <864afea8-2303-47e5-b116-bda93597b9d7@gmail.com>
References: <8b028a54-08a1-8e53-04ab-3fa8c51d2369@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>,
        Andrew Lunn <andrew@lunn.ch>
To: Randy Dunlap <rdunlap@infradead.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:33163 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754665AbdAaBND (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 20:13:03 -0500
Received: by mail-it0-f66.google.com with SMTP id e137so17387611itc.0
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 17:13:02 -0800 (PST)
In-Reply-To: <8b028a54-08a1-8e53-04ab-3fa8c51d2369@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/30/2017 05:02 PM, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> This driver uses mdio* (PHYLIB) interfaces, so it should select
> PHYLIB. PHYLIB depends on NETDEVICES to this driver should also
> depend on NETDEVICES.
> 
> Fixes these build errors:
> 
> drivers/built-in.o: In function `nsp_usb3_phy_init':
> phy-bcm-nsp-usb3.c:(.text+0x42d8): undefined reference to `mdiobus_write'
> phy-bcm-nsp-usb3.c:(.text+0x42f4): undefined reference to `mdiobus_write'
> phy-bcm-nsp-usb3.c:(.text+0x4310): undefined reference to `mdiobus_write'
> phy-bcm-nsp-usb3.c:(.text+0x432c): undefined reference to `mdiobus_write'
> phy-bcm-nsp-usb3.c:(.text+0x4348): undefined reference to `mdiobus_write'
> drivers/built-in.o:phy-bcm-nsp-usb3.c:(.text+0x437a): more undefined references to `mdiobus_write' follow
> drivers/built-in.o: In function `mdio_module_init':
> phy-bcm-nsp-usb3.c:(.init.text+0x1e1): undefined reference to `mdio_driver_register'
> drivers/built-in.o: In function `mdio_module_exit':
> phy-bcm-nsp-usb3.c:(.exit.text+0xae): undefined reference to `mdio_driver_unregister'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Yendapally Reddy Dhananjaya Reddy <yendapally.reddy@broadcom.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

This is certainly a good fix for now, but I think we really need to
split the PHY library and its state machine from generic support for
MDIO buses and devices, let me see if I can come up with something for that.

Thanks!

> ---
>  drivers/phy/Kconfig |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> --- linux-next-20170130.orig/drivers/phy/Kconfig
> +++ linux-next-20170130/drivers/phy/Kconfig
> @@ -504,8 +504,9 @@ config PHY_MESON8B_USB2
>  
>  config PHY_NSP_USB3
>  	tristate "Broadcom NorthStar plus USB3 PHY driver"
> -	depends on OF && (ARCH_BCM_NSP || COMPILE_TEST)
> +	depends on OF && (ARCH_BCM_NSP || COMPILE_TEST) && NETDEVICES
>  	select GENERIC_PHY
> +	select PHYLIB
>  	default ARCH_BCM_NSP
>  	help
>  	  Enable this to support the Broadcom Northstar plus USB3 PHY.
> 


-- 
Florian
