From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 29 Sep 2017 09:14:26 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0084EDC@AcuExch.aculab.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170907223625.GW11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
 <20170928193416.GH14940@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "muvarov@gmail.com" <muvarov@gmail.com>,
        "pavel@ucw.cz" <pavel@ucw.cz>,
        "nathan.leigh.conrad@gmail.com" <nathan.leigh.conrad@gmail.com>,
        "vivien.didelot@savoirfairelinux.com"
        <vivien.didelot@savoirfairelinux.com>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Woojung.Huh@microchip.com" <Woojung.Huh@microchip.com>
To: 'Andrew Lunn' <andrew@lunn.ch>,
        "Tristram.Ha@microchip.com" <Tristram.Ha@microchip.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928193416.GH14940@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Lunn
> Sent: 28 September 2017 20:34
...
> > There are 34 counters.  In normal case using generic bus I/O or PCI to read them
> > is very quick, but the switch is mostly accessed using SPI, or even I2C.  As the SPI
> > access is very slow.
> 
> How slow is it? The Marvell switches all use MDIO. It is probably a
> bit faster than I2C, but it is a lot slower than MMIO or PCI.
> 
> ethtool -S lan0 takes about 25ms.

Is the SPI access software bit-banged?
Doing that with software delays isn't friendly to the rest of the system.
(Hardware guys please note...)

One possibility is to rate-limit the stats reading.
Then an application cannot completely 'hog' the SPI bandwidth.

	David
