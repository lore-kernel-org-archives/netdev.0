From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 24 Nov 2016 16:20:45 +0100
Message-ID: <20161124152045.GK13735@pali>
References: <201611111820.52072@pali>
 <201611221805.13606@pali>
 <20161123222335.GA4788@amd>
 <201611232339.59411@pali>
 <20161124075104.GA26721@amd>
 <20161124083329.GB13735@pali>
 <20161124151317.34yoza3dzuh46oa4@earth>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Sebastian Reichel <sre@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f179.google.com ([209.85.210.179]:32992 "EHLO
        mail-wj0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965985AbcKXPVI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Nov 2016 10:21:08 -0500
Content-Disposition: inline
In-Reply-To: <20161124151317.34yoza3dzuh46oa4@earth>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 24 November 2016 16:13:17 Sebastian Reichel wrote:
> Hi,
> 
> On Thu, Nov 24, 2016 at 09:33:29AM +0100, Pali Rohár wrote:
> > On Thursday 24 November 2016 08:51:04 Pavel Machek wrote:
> > > Hi!
> > > 
> > > > > "ifconfig hw ether XX" normally sets the address. I guess that's
> > > > > ioctl?
> > > > 
> > > > This sets temporary address and it is ioctl. IIRC same as what ethtool 
> > > > uses. (ifconfig is already deprecated).
> > > > 
> > > > > And I guess we should use similar mechanism for permanent
> > > > > address.
> > > > 
> > > > I'm not sure here... Above ioctl ↑↑↑ is for changing temporary mac 
> > > > address. But here we do not want to change permanent mac address. We 
> > > > want to tell kernel driver current permanent mac address which is
> > > > stored
> > > 
> > > Well... I'd still use similar mechanism :-).
> > 
> > Thats problematic, because in time when wlan0 interface is registered
> > into system and visible in ifconfig output it already needs to have
> > permanent mac address assigned.
> > 
> > We should assign permanent mac address before wlan0 of wl1251 is
> > registered into system.
> 
> You can just add the MAC address to the NVS data, which is also
> required for the device initialization.

NVS data file has fixed size, there is IIRC no place for it.

But one of my suggestion was to use another request_firmware for MAC
address. So this is similar to what you are proposing, as NVS data are
loaded by request_firmware too...

> I wonder if those information could be put into DT. Iirc some
> network devices get their MAC address from DT. Maybe we can add
> all NVS info to DT? How much data is it?

Proprietary, signed and closed bootloader NOLO does not support DT. So
for booting you need to append DTS file to kernel image.

U-Boot is optional and can be used as intermediate bootloader between
NOLO and kernel. But still it has problems with reading from nand, so
cannot read NVS data nor MAC address.

> Userspace application can add all those information to the DT
> using a DT overlay. Also the u-boot could parse and add it at
> some point in the future.

In case when wl1251 is statically linked into kernel image, it is loaded
and initialized before even userspace applications starts.

So no... adding NVS data or MAC address into DT or DT overlay is not a
solution.

-- 
Pali Rohár
pali.rohar@gmail.com
