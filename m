From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: wake on LAN with sky2
Date: Thu, 14 Dec 2006 00:40:58 +0100
Message-ID: <20061213234058.GA19990@dose.home.local>
References: <20061212202720.GA12047@thinkpad.home.local> <20061213145818.6223ffbb@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:33194 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686AbWLNAAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 19:00:40 -0500
Received: from dose.home.local (port-212-202-201-86.dynamic.qsc.de [212.202.201.86])
	by eazy.amigager.de (Postfix) with ESMTP id B6C9925C3E0
	for <netdev@vger.kernel.org>; Thu, 14 Dec 2006 00:40:59 +0100 (CET)
Received: from scorpion by dose.home.local with local (Exim 4.63)
	(envelope-from <tino.keitel@tikei.de>)
	id 1Gudic-0005oM-E9
	for netdev@vger.kernel.org; Thu, 14 Dec 2006 00:40:58 +0100
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20061213145818.6223ffbb@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 13, 2006 at 14:58:18 -0800, Stephen Hemminger wrote:
> On Tue, 12 Dec 2006 21:27:20 +0100
> Tino Keitel <tino.keitel@tikei.de> wrote:
> 
> > Hi folks,
> > 
> > I just tried the sk98lin driver version 8.41.2.3 and was happy that it
> > seems to support wake on LAN with the Marvell 88E8053 PCIe chip.
> > However, after resume from suspend to RAM, the machine hangs. As it
> > doesn't hang with sky2, it looks like this particular driver breaks
> > suspend to RAM. ($%&?#!!!)
> 
> 
> 
> > A quick look into sk98lin_suspend() shows that there is not much stuff
> > in there. Am I right that I just have to port that stuff to sky2? The
> > affected file skge.c is licenced under the GPL v2 or later.
> > 
> > Regards,
> > Tino
> > -
> 
> 
> I was working on Wol for sky2, and got part way, but discovered that on my
> test machine there were worse problems. The current code in the power management
> resume runs the ACPI finish routine after the device resume. The ACPI finish
> routine calls the BIOS, the BIOS then breaks MSI support.
> 
> The fix for that will be to reorder the PM resume code, but doing it right
> means making the process thaw code SMP safe....  There are some patches
> slowly working through the PM tree to fix this..
> 
> Anyway, this is as far as I got.

Thanks for the patch. I just tried it with 2.6.19. The link LED on the
switch is active after suspend, but no wakeup after sending the WOL
packets, neigher with p nor with g setting in ethtool. After the
resume, the interface is silent, I have to reload sky2.ko to get it
working again.

Regards,
Tino
