From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 29 Sep 2017 22:39:26 +0200
Message-ID: <20170929203926.GD17713@lunn.ch>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170907223625.GW11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
 <20170928193416.GH14940@lunn.ch>
 <063D6719AE5E284EB5DD2968C1650D6DD0084EDC@AcuExch.aculab.com>
 <20170929121201.GD19710@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD4112CB89@CHN-SV-EXMX02.mchp-main.com>
 <20170929185316.GB17713@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD4112CC1D@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David.Laight@ACULAB.COM, muvarov@gmail.com, pavel@ucw.cz,
        nathan.leigh.conrad@gmail.com, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD4112CC1D@CHN-SV-EXMX02.mchp-main.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 29, 2017 at 07:19:17PM +0000, Tristram.Ha@microchip.com wrote:
> > > My concern is if a task is already running with SPI access to a lot
> > > of registers like reading the 32 MIB counters in every port of the
> > > switch, another register access has to wait until they are finished.
> > 
> > Why does it have to wait? Looking at the code in
> > ksz_get_ethtool_stats(), you don't take any mutex which will prevent
> > others from using the SPI bus. All there is is a mutex which prevents
> > two sets of ksz_get_ethtool_stats() at the same time.
> > 
> > So a PTP read could happen in parallel, and will not be blocked by MIB
> > reads. They should get interleaved access to the SPI bus.
> > 
> 
> The MIB counters are read in the background.  For multiple CPU cores 2
> tasks may run in the same time allowing SPI access one after another.
> For single core I am not sure an SPI access like coming from an interrupt
> routine can jump ahead from one in a background task.

The SPI subsystem has a mutex per controller. When starting a
transfer, it takes the mutex and release it once the transfer has
completed. There is also a reschedule point at the end of a
transfer. So even on your single core CPU, there can be multi tasking
going on.

      Andrew
