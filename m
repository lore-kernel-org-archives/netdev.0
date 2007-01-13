From: Michael Buesch <mb@bu3sch.de>
Subject: Re: What is in bcm43xx-wireless-dev.git?
Date: Sat, 13 Jan 2007 15:09:26 +0100
Message-ID: <200701131509.26877.mb@bu3sch.de>
References: <20070113024543.aj2n40s4k0g0cgws@webmail.spamcop.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:52446
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422679AbXAMOKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jan 2007 09:10:37 -0500
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <20070113024543.aj2n40s4k0g0cgws@webmail.spamcop.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 13 January 2007 08:45, Pavel Roskin wrote:
> Quoting Michael Buesch <mb@bu3sch.de>:
> 
> > > drivers/ssb/driver_mips/mips.c includes asm/time.h, which is missing on
> > > x86_64.  It also refers to struct ssb_serial_ports, which is not defined
> > > anywhere.
> >
> > Yeah, CONFIG_SSB_MIPS should depend on the MIPS CPU.
> > Which kconfig option do you suggest to make a "depend" on?
> 
> I try not to add artificial restrictions.  The driver should depend on the
> components providing the necessary API.

Ehm, it is clearly not artificial. The MIPS core depends on the MIPS
platform. Logically and technically. You must not enable it on
non-MIPS platforms, as it's tied with the internals of the MIPS
arch dependent code.

The only logical way to solve the compile issues are to make a dependency
on the MIPS platform.

> > > drivers/ssb/driver_pci/pcicore.c refers to SSB_PCICORE_SBTOPCI1_CFG1
> > > that is not defined anywhere in the kernel.
> >
> > Yeah, could be a typo. I'll have a look at it.
> 
> I only found it because the driver didn't depend on MIPS.  See what I mean?
> 
> This only manifests if CONFIG_SSB_PCICORE_HOSTMODE is defined, and it is only
> selected by CONFIG_SSB_DRIVER_MIPS.

HOSTMODE is not really tested, yet.
And HOSTMODE is _also_ very closely tied to the MIPS platform. So
it must depend on it, too (probably indirectly through the MIPS core driver).

To be honest, I did not even compiletest the HOSTMODE code, as I don't
even have a device for it. But I am going to fix that before pushing stuff
upstream.

> > Hm, not sure why this oopses. It works on PPC (can transmit data and so on).
> 
> My PPC machine is a venerable Blue&White G3, so it won't take PCIe.

I looked more closely at it, but I really can't see why it oopses.
Any idea what's happening there?

> > Does it work with linville's tree (in DMA mode)?
> 
> Yes, it does.  I couldn't connect to the AP, but it's a different story.  I may
> be doing things wrong.  At least I can scan and I see the APs around.

Well, ok. So it should work in my tree, too, once we fixed the DMA oops.

-- 
Greetings Michael.
