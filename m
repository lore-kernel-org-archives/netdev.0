From: Bill Fink <billfink@mindspring.com>
Subject: Re: [patch 01/10] e1000e: make E1000E default to the same kconfig
 setting as E1000
Date: Fri, 14 Dec 2007 23:57:57 -0500
Message-ID: <20071214235757.06f5c47a.billfink@mindspring.com>
References: <200712140002.lBE02pUb025505@imap1.linux-foundation.org>
	<4762E9FE.1070707@garzik.org>
	<20071214152215.55ef46e8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	randy.dunlap@oracle.com, auke-jan.h.kok@intel.com,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-dupuy.atl.sa.earthlink.net ([209.86.89.62]:34536 "EHLO
	elasmtp-dupuy.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751047AbXLOE6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 23:58:13 -0500
In-Reply-To: <20071214152215.55ef46e8.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2007, Andrew Morton wrote:

> On Fri, 14 Dec 2007 15:39:26 -0500
> Jeff Garzik <jeff@garzik.org> wrote:
> 
> > akpm@linux-foundation.org wrote:
> > > From: Randy Dunlap <randy.dunlap@oracle.com>
> > > 
> > > Make E1000E default to the same kconfig setting as E1000.  So people's
> > > machiens don't stop working when they use oldconfig.
> > > 
> > I am not inclined to apply this one.  This practice, applied over time, 
> > will tend to accumulate weird 'default' and 'select' statements.
> > 
> > So I think the breakage that occurs is mitigated by two factors:
> > 1) kernel hackers that do their own configs are expected to be able to 
> > figure this stuff.
> > 2) kernel builders (read: distros, mainly) are expected to have put 
> > thought into the Kconfig selection and driver migration strategies.
> > 
> > PCI IDs move across drivers from time, and we don't want to apply these 
> > sorts changes:  Viewed in the long term, the suggested patch is merely a 
> > temporary change to allow kernel experts to more easily deal with the 
> > PCI ID migration across drivers.
> > 
> > I would prefer simply to communicate to kernel experts and builders 
> > about a Kconfig issue that could potentially their booting/networking... 
> >   because this patch is only needed if the kernel experts do not already 
> > know about a necessary config update.
> 
> You can take it out again later on - most people's .configs will then have
> E1000E set.   People who still do `cp ancientconfig .config ; make oldconfig'
> remain screwed.

I was thinking the same thing.  Leave it in for 2 or 3 major versions
and then remove it (something analogous to the timeframe for a feature
removal).

And during the interim period, add something like the following
to the Kconfig help text:

	Note some hardware that was previously supported by the
	e1000 driver is now only handled by the e1000e driver.
	If unsure and you previously used the e1000 driver,
	say Y or M here.

> I dunno.  I guess I'm not into causing people pain in an attempt to train
> them to do what we want.  This is a popular driver and a *lot* of people
> are going to:
> 
> - build new kernel
> 
> - install new kernel
> 
> - find it doesn't work, go through quite large amounts of hassle trying
>   to work out why it stopped working.  Eventually work out that e1000
>   stopped working.  Eventually work out that it stopped working because we
>   forcibly switched them to a new driver which they didn't know about.
> 
> - reconfigure kernel
> 
> - rebuild, reinstall

Having been there, done that, it's definitely a pain.  It's especially
painful when you're doing it remotely, and since the network no longer
works, you can't get into the system anymore.

> Multiply that by 100s of people (at least).  All because Jeff wouldn't
> apply a one-liner?

						-Bill
