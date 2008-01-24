From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH UCC TDM 1/3 Updated] Platform changes for UCC TDM driver for MPC8323eRDB. Also includes related QE changes and dts entries.
Date: Thu, 24 Jan 2008 20:23:27 +0300
Message-ID: <20080124172327.GA6786@localhost.localdomain>
References: <Pine.LNX.4.64.0801241553270.4984@linux121> <20080124154804.GA22178@localhost.localdomain> <4798B4F3.2010101@freescale.com> <20080124162345.GA27359@localhost.localdomain> <4798BDEB.2010501@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: Poonam_Aggrwal-b10812 <b10812@freescale.com>,
	kumar.gala@freescale.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rubini@vision.unipv.it, linuxppc-dev@ozlabs.org,
	michael.barkowski@freescale.com, rich.cutler@freescale.com,
	ashish.kalra@freescale.com
To: Timur Tabi <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:4871 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752488AbYAXRXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 12:23:42 -0500
Content-Disposition: inline
In-Reply-To: <4798BDEB.2010501@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2008 at 10:33:47AM -0600, Timur Tabi wrote:
> Anton Vorontsov wrote:
> 
> >Are you saying that TDM is sharing same pins with the other QE device,
> >and we can choose to use/not use some device depending on which driver
> >is loaded?
> 
> No.  I'd have to closely examine the DTS, but I don't think that UCC 
> devices share pins at all.  But that isn't my point.
> 
> >In that particular case UCC configuration is static, for every UCC.
> >So, we can set up all pins in the firmware/board file.
> 
> Yes, but deciding what the UCC does might not be static.  At what point do 
> we declare, "UCC5 is for eth0 and eth0 only"?
> 
> The advantage of putting the pin configurations in the device tree is that 
> they now become configurable.  I can envision a scenario where UCC5 could 
> be either an Ethernet or a UART, depending on the setting of some jumpers 
> on the board. That's what the QE was designed for: any UCC can do any task, 
> and you can even have a UCC change its purpose while the system is running. 
> So I don't want the pin configurations hard-coded into the kernel.  Having 
> them in the device tree gives me some flexibility.

If hardware configuration is selected at the bootup time, by jumpers
or switches, it's even easier to do it right. Without pio-map.

> For instance, I have a plan (that I keep postponing) to introduce a new 
> feature in U-Boot where U-Boot can determine the settings of some board 
> jumpers and modify the device tree accordingly. The instructions on how to 
> modify the device tree would be embedded in the tree itself.

Why you need to modify the device tree for that? Let the U-Boot simply
setup pins for the kernel. Regarding kernel overwriting pins
configuration...

> I can't 
> support this feature if the kernel calls par_io_config_pin() regardless of 
> what's in the device tree.

What I've understood from the previous debates, is that ideally kernel
should not touch pins' configuration. Today we're using pio-map solely
to fix up some old firmware misconfiguration. And we can do this in the
board file still. To determine if we need to fixup the firmware or not,
we can use some device tree property instead (firmware version?).

p.s.
I'm neither for pio-map nor against. I just want some consequence
regarding this. Last thread ended with consequence that pio-map is a
bad thing to use...

-- 
Anton Vorontsov
email: cbou@mail.ru
backup email: ya-cbou@yandex.ru
irc://irc.freenode.net/bd2
