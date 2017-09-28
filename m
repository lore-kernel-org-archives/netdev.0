From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Thu, 28 Sep 2017 21:34:16 +0200
Message-ID: <20170928193416.GH14940@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170907223625.GW11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 08:27:13PM +0000, Tristram.Ha@microchip.com wrote:
> > > +/**
> > > + * Some counters do not need to be read too often because they are less
> > likely
> > > + * to increase much.
> > > + */
> > 
> > What does comment mean? Are you caching statistics, and updating
> > different values at different rates?
> > 
> 
> There are 34 counters.  In normal case using generic bus I/O or PCI to read them
> is very quick, but the switch is mostly accessed using SPI, or even I2C.  As the SPI
> access is very slow.

How slow is it? The Marvell switches all use MDIO. It is probably a
bit faster than I2C, but it is a lot slower than MMIO or PCI.

ethtool -S lan0 takes about 25ms.

No other driver does caching. So i'm hesitant to add one which does.

>  These accesses can be getting 1588 PTP timestamps and opening/closing ports.

You could drop the mutex between each statistic read, so allowing
something else access to the switch. That should reduce the jitter PTP
experiences.

	Andrew
