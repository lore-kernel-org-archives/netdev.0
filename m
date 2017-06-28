From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 2/2] phy: bcm-ns-usb3: fix MDIO_BUS dependency
Date: Wed, 28 Jun 2017 16:18:52 -0700
Message-ID: <2b043867-c145-1083-f0d8-2bcca5e76efa@gmail.com>
References: <20170621220626.46691-1-arnd@arndb.de>
 <20170621220626.46691-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>,
        Kishon Vijay Abraham I <kishon@ti.com>,
        Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org,
        "David S . Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170621220626.46691-2-arnd@arndb.de>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/21/2017 03:06 PM, Arnd Bergmann wrote:
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

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
