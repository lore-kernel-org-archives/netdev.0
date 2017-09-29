From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 29 Sep 2017 14:12:01 +0200
Message-ID: <20170929121201.GD19710@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170907223625.GW11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
 <20170928193416.GH14940@lunn.ch>
 <063D6719AE5E284EB5DD2968C1650D6DD0084EDC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Tristram.Ha@microchip.com" <Tristram.Ha@microchip.com>,
        "muvarov@gmail.com" <muvarov@gmail.com>,
        "pavel@ucw.cz" <pavel@ucw.cz>,
        "nathan.leigh.conrad@gmail.com" <nathan.leigh.conrad@gmail.com>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Woojung.Huh@microchip.com" <Woojung.Huh@microchip.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DD0084EDC@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 29, 2017 at 09:14:26AM +0000, David Laight wrote:
> From: Andrew Lunn
> > Sent: 28 September 2017 20:34
> ...
> > > There are 34 counters.  In normal case using generic bus I/O or PCI to read them
> > > is very quick, but the switch is mostly accessed using SPI, or even I2C.  As the SPI
> > > access is very slow.
> > 
> > How slow is it? The Marvell switches all use MDIO. It is probably a
> > bit faster than I2C, but it is a lot slower than MMIO or PCI.
> > 
> > ethtool -S lan0 takes about 25ms.
> 
> Is the SPI access software bit-banged?

That will depend on the board design. I've used mdio bit banging, and
that was painfully slow for stats.

But we should primarily think about average hardware. It is going to
have hardware SPI or I2C. If statistics reading with hardware I2C is
reasonable, i would avoid caching, and just ensure other accesses are
permitted between individual statistic reads.

It also requires Microchip also post new code. They have been very
silent for quite a while....

	  Andrew
