From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv5] net: dsa: add SMSC/Microchip LAN9303 three port
 ethernet switch driver
Date: Thu, 13 Apr 2017 10:46:04 -0400 (EDT)
Message-ID: <20170413.104604.168979376298793906.davem@davemloft.net>
References: <20170413073343.8067-1-jbe@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, kernel@pengutronix.de, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: jbe@pengutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170413073343.8067-1-jbe@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Juergen Borleis <jbe@pengutronix.de>
Date: Thu, 13 Apr 2017 09:33:39 +0200

> Changes in v5:
> 
> - missing include file to 'net/dsa/tag_lan9303.c' added

This still doesn't build cleanly.

drivers/net/dsa/lan9303_mdio.o: In function `mdio_module_init':
lan9303_mdio.c:(.init.text+0x0): multiple definition of `init_module'
drivers/net/dsa/lan9303_i2c.o:lan9303_i2c.c:(.init.text+0x0): first defined here
drivers/net/dsa/lan9303_mdio.o: In function `mdio_module_exit':
lan9303_mdio.c:(.exit.text+0x0): multiple definition of `cleanup_module'
drivers/net/dsa/lan9303_i2c.o:lan9303_i2c.c:(.exit.text+0x0): first defined here
scripts/Makefile.build:540: recipe for target 'drivers/net/dsa/lan9303.o' failed

Please test with NET_DSA_SMSC_LAN9303=m, NET_DSA_SMSC_LAN9303_I2C=y and
NET_DSA_SMSC_LAN9303_MDIO=y as that is what I used to reproduce the
problem above.

You cannot really use module_i2c_driver() and mdio_module_driver()
at the same time in the same driver module.

You're going to have to have a common module init function which you
code up by hand, which conditionally handles I2C and MDIO based
probing based upon Kconfig symbol settings.

And please more sufficiently test your builds.

Thank you.
