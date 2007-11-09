From: Ben Dooks <ben@fluff.org>
Subject: Re: [RFC] dependencies for platform drivers (was Re: ax88796: add
	superh to kconfig dependencies)
Date: Fri, 9 Nov 2007 12:06:48 +0000
Message-ID: <20071109120648.GA31353@fluff.org.uk>
References: <20071108073105.3996.70418.sendpatchset@clockwork.opensource.se> <20071108081854.GN8181@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
	lethal@linux-sh.org, ben-linux@fluff.org,
	akpm@linux-foundation.org, jeff@garzik.org,
	linux-arch@vger.kernel.org
To: Al Viro <viro@ftp.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 87-194-8-8.bethere.co.uk ([87.194.8.8]:65513 "EHLO
	kira.home.fluff.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758360AbXKIMuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 07:50:04 -0500
Content-Disposition: inline
In-Reply-To: <20071108081854.GN8181@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 08, 2007 at 08:18:54AM +0000, Al Viro wrote:
> On Thu, Nov 08, 2007 at 04:31:05PM +0900, Magnus Damm wrote:
> >  config AX88796
> >  	tristate "ASIX AX88796 NE2000 clone support"
> > -	depends on ARM || MIPS
> > +	depends on ARM || MIPS || SUPERH
> 
> You know, that really sucks more and more.  How about doing the following:
> 	a) making it depend on PLAT_HAS_AX88796
> 	b) adding selects for all subarchitectures that have the corresponding
> platform device
> and setting that as a uniform policy for platform drivers?  For things like
> SM501 we would do
> config MFD_SM501
> 	depends on PCI || PLAT_HAS_SM501
> etc.

The PLAT_HAS_xxx method is nice, and I would like it applied to other places
in the kernel (see libata arugment below), and would have acked
this patch if it hadn't already been applied by Jeff.

The only reservation is that this doesn't show up the posibilty
of having the driver in the menuconfig, but anyone adding new
board support (should) be bright enough to look through the
Kconfig scripts before deciding they need to write an entirely
new driver.

I would note you may want to do PLAT_HAS_NET_AX88796 as there is
entirely a posibility of confusing this with the simple parallel
port driver which a board may not have support for.

> Seriously, folks, we are getting shitloads of platform drivers with no
> dependencies whatsoever, needed on a handful of targets and occasionally
> failing to build on unrelated architectures.  Moreover, having a list
> of architectures in dependencies for each of those suckers is a PITA
> from the conflict POV.  Not to mention platform drivers that fall into
> the mainline kernel with not a single platform device for them, etc.

There is a general problem with chicken-vs-egg here, how do you submit
support for a machine's platform device without the platform device
being there (and vice-versa) with seperate maintainers for network
and machine support?

One of my colleagues has passed along comments you made about a pair
of the simtec drivers (simtec-i2c and simtec-ide) which have been
added, but have no current users as patches have been stalled either
in submission process, or awaiting for an resolution. In the case
of simtec-ide, I would like to replace it with platform-ata, but
the libata maintainers seem wholy un-interested in
PLAT_HAS_PLATFORM_ATA or similar.

-- 
Ben (ben@fluff.org, http://www.fluff.org/)

  'a smiley only costs 4 bytes'
