From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/4] net: mvneta: driver for Marvell Armada 370/XP
 network unit
Date: Tue, 4 Sep 2012 20:31:25 +0200
Message-ID: <20120904183125.GB14683@lunn.ch>
References: <1346764004-16332-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1346764004-16332-2-git-send-email-thomas.petazzoni@free-electrons.com>
 <201209041436.36430.arnd@arndb.de> <20120904175610.2c2934f1@skate>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Ike Pan <ike.pan@canonical.com>, Nadav Haklai <nadavh@marvell.com>,
 Ian Molton <ian.molton@codethink.co.uk>,
 Lennert Buytenhek <kernel@wantstofly.org>, David Marlin <dmarlin@redhat.com>,
 Rami Rosen <rosenr@marvell.com>, Yehuda Yitschak <yehuday@marvell.com>,
 Jani Monoses <jani.monoses@canonical.com>, Tawfik Bayouk <tawfik@marvell.com>,
 Dan Frazier <dann.frazier@canonical.com>, Eran Ben-Avi <benavi@marvell.com>,
 Li Li <li.li@canonical.com>, Leif Lindholm <leif.lindholm@arm.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Jon Masters <jcm@redhat.com>, Ben Dooks <ben-linux@fluff.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org, Chris Van Hoof <vanhoof@canonical.com>,
 Nicolas Pitre <n
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <20120904175610.2c2934f1@skate>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

> > I think we normally put the phy into a separate device node on an
> > mdio bus and then use the of_phy_* functions to connect it to
> > the ethernet device.
> 
> Even though it may not be a convincing argument, none of the existing DT
> files in arch/arm/boot/dts seem to instantiate a separate PHY device
> and a proper MDIO bus. However, the PowerPC platforms indeed make this
> distinction a lot clearer.
> 
> However, this network unit has a clever MAC that autonomously queries
> the PHY for the link status, and reports changes (link, duplex, speed)
> in the form of MAC interrupts and MAC registers. Therefore, for basic
> operation, there is no need for a separate PHY driver nor to expose the
> MDIO bus in any way. The only thing needed is the PHY address, which is
> filled into a register of the MAC so that it can start its automatic
> query of the PHY.

Hi Thomas

I've used Marvell switch chipsets, which have a phy polling unit,
PPU. This sounds very similar. You can do a lot with the PPU, but when
you want to configure subsets of auto-negotiation rates/duplex modes,
or fixed speeds/duplex modes, the PPU could not do it. You had to
disable the PPU and configure the PHY directly.

I see you have some of the ethtools API calls implemented, but not the
ones needed for auto-neg and rates/duplex mode configurations. Does
the neta PPU support this, or will you need to export the MDIO bus for
these sorts of configuration options?

   Thanks
      Andrew
