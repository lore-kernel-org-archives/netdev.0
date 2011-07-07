From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: Getting the correct asix AX88178 usb gige driver in mainline?
Date: Thu, 7 Jul 2011 19:43:10 +0200
Message-ID: <201107071943.10479.arnd@arndb.de>
References: <E1Qes7I-0004Rx-88@myth-lvr.svh.merlins.org> <201107071455.36975.arnd@arndb.de> <20110707172350.GD13683@merlins.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, greg@kroah.com
To: Marc MERLIN <marc@merlins.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:51673 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751880Ab1GGRnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 13:43:51 -0400
In-Reply-To: <20110707172350.GD13683@merlins.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 07 July 2011 19:23:50 Marc MERLIN wrote:
> On Thu, Jul 07, 2011 at 02:55:36PM +0200, Arnd Bergmann wrote:
> > On Wednesday 06 July 2011, Marc MERLIN wrote:
> > > > The patch I mentioned was merged back in 2006, for 2.6.19. Either that
> > > > patch was never complete and is missing support for your hardware, or
> > > > it broke since then. You should probably try an old kernel to see if it's
> > > > actually a regression.
> > > 
> > > Thanks for the details Arnd, I'll see if I can boot 2.6.19 on that laptop
> > > and report back.
> > 
> > I would perhaps try something less ancient first, 2.6.27-longterm would be
> > a good candidate. If it was working at some point but broken later, chances
> > are that it wasn't broken until a few years ago, rather than shortly after
> > it was merged.
> 
> So, it was problematic to build and boot old kernels for that system, but I
> tried my USB adapter in older systems with older kernels.
> 
> 2.6.20 and 2.6.22.1 both were able to bring the interface up and DHCP.
> 2.6.24.3 was NOT able to.
> Neither was 2.6.34.1.

Not a lot has changed int hat driver between 2.6.22 and 2.6.24, so you could
try

git diff v2.6.22..v2.6.24 drivers/net/usb/asix.c  | patch -Rp1 

on the latest version and see if that helps. There are some rejects, but
those all look harmless.

	Arnd
