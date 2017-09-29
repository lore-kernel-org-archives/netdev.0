From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 29 Sep 2017 19:19:17 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD4112CC1D@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170907223625.GW11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
 <20170928193416.GH14940@lunn.ch>
 <063D6719AE5E284EB5DD2968C1650D6DD0084EDC@AcuExch.aculab.com>
 <20170929121201.GD19710@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD4112CB89@CHN-SV-EXMX02.mchp-main.com>
 <20170929185316.GB17713@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <David.Laight@ACULAB.COM>, <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
To: <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929185316.GB17713@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > My concern is if a task is already running with SPI access to a lot
> > of registers like reading the 32 MIB counters in every port of the
> > switch, another register access has to wait until they are finished.
> 
> Why does it have to wait? Looking at the code in
> ksz_get_ethtool_stats(), you don't take any mutex which will prevent
> others from using the SPI bus. All there is is a mutex which prevents
> two sets of ksz_get_ethtool_stats() at the same time.
> 
> So a PTP read could happen in parallel, and will not be blocked by MIB
> reads. They should get interleaved access to the SPI bus.
> 

The MIB counters are read in the background.  For multiple CPU cores 2
tasks may run in the same time allowing SPI access one after another.
For single core I am not sure an SPI access like coming from an interrupt
routine can jump ahead from one in a background task.

I know nowadays SoCs are powerful enough to do amazing things.  It is
just I spent a long time using a low-powered SoC doing switch driver
development.
