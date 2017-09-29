From: <Tristram.Ha@microchip.com>
Subject: RE: [PATCH RFC 3/5] Add KSZ8795 switch driver
Date: Fri, 29 Sep 2017 18:56:31 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD4112CBF0@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A87@CHN-SV-EXMX02.mchp-main.com>
 <20170907223625.GW11248@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41124D5A@CHN-SV-EXMX02.mchp-main.com>
 <20170928184059.GA2825@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
To: <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928184059.GA2825@amd>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Mon 2017-09-18 20:27:13, Tristram.Ha@microchip.com wrote:
> > > > +/**
> > > > + * Some counters do not need to be read too often because they are
> less
> > > likely
> > > > + * to increase much.
> > > > + */
> > >
> > > What does comment mean? Are you caching statistics, and updating
> > > different values at different rates?
> > >
> >
> > There are 34 counters.  In normal case using generic bus I/O or PCI to read
> them
> > is very quick, but the switch is mostly accessed using SPI, or even I2C.  As
> the SPI
> > access is very slow and cannot run in interrupt context I keep worrying
> reading
> > the MIB counters in a loop for 5 or more ports will prevent other critical
> hardware
> > access from executing soon enough.  These accesses can be getting 1588
> PTP
> > timestamps and opening/closing ports.  (RSTP Conformance Test sends test
> traffic
> > to port supposed to be closed/opened after receiving specific RSTP
> > BPDU.)
> 
> Hmm. Ok, interesting.
> 
> I wonder how well this is going to work if userspace actively 'does
> something' with the switch.
> 
> It seems to me that even if your statistics code is careful not to do
> 'a lot' of accesses at the same time, userspace can use other parts of
> the driver to do the same, and thus cause same unwanted effects...

If the user calls "ethtool -S" in a tight loop the system will waste a lot of
CPU time, but this is more like a user error.
Another solution is not to schedule to read the MIB counters in that
function call.  I think I was doing a favor to update the MIB counters
sooner as the user probably wants to find out what is wrong with the
switch by reading the MIB counters and checking them several times.
For system tracking like SNMP I think it is likely a separate mechanism
is used to gather those information.  If I am wrong that function definitely
needs to be modified.
