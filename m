From: Juergen Borleis <jbe@pengutronix.de>
Subject: Re: [PATCHv5] net: dsa: add SMSC/Microchip LAN9303 three port ethernet switch driver
Date: Tue, 18 Apr 2017 11:10:29 +0200
Message-ID: <201704181110.30446.jbe@pengutronix.de>
References: <20170413073343.8067-1-jbe@pengutronix.de> <20170413.104604.168979376298793906.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>, andrew@lunn.ch,
        f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kernel@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170413.104604.168979376298793906.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

On Thursday 13 April 2017 16:46:04 David Miller wrote:
> > Changes in v5:
> >
> > - missing include file to 'net/dsa/tag_lan9303.c' added
>
> This still doesn't build cleanly.
>
> drivers/net/dsa/lan9303_mdio.o: In function `mdio_module_init':
> lan9303_mdio.c:(.init.text+0x0): multiple definition of `init_module'
> drivers/net/dsa/lan9303_i2c.o:lan9303_i2c.c:(.init.text+0x0): first
> defined here drivers/net/dsa/lan9303_mdio.o: In function
> `mdio_module_exit':
> lan9303_mdio.c:(.exit.text+0x0): multiple definition of `cleanup_module'
> drivers/net/dsa/lan9303_i2c.o:lan9303_i2c.c:(.exit.text+0x0): first
> defined here scripts/Makefile.build:540: recipe for target
> 'drivers/net/dsa/lan9303.o' failed
>
> Please test with NET_DSA_SMSC_LAN9303=m, NET_DSA_SMSC_LAN9303_I2C=y and
> NET_DSA_SMSC_LAN9303_MDIO=y as that is what I used to reproduce the
> problem above.

Sorry, missed that, due to the need for a static driver by NFSroot...

> You cannot really use module_i2c_driver() and mdio_module_driver()
> at the same time in the same driver module.
>
> You're going to have to have a common module init function which you
> code up by hand, which conditionally handles I2C and MDIO based
> probing based upon Kconfig symbol settings.

I'm now [v6] using the same build-method like the mfd driver mc13xx (which 
can be accessed via I2C or SPI). I've now compile time tested all module 
and static variants (hopefully) and run-time tested the static variant and 
the I2C module variant.

jb

-- 
Pengutronix e.K.                             | Juergen Borleis             |
Industrial Linux Solutions                   | http://www.pengutronix.de/  |
