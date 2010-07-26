From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
 regression
Date: Mon, 26 Jul 2010 11:09:41 -0700
Message-ID: <20100726180941.GB4883@kroah.com>
References: <m139vd5sms.fsf_-_@fess.ebiederm.org>
 <m1zkxj27xp.fsf_-_@fess.ebiederm.org>
 <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
 <m1vd87toy9.fsf@fess.ebiederm.org>
 <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
 <1279822828.12439.24.camel@jlt3.sipsolutions.net>
 <20100722182827.GA12821@suse.de>
 <1279823801.12439.31.camel@jlt3.sipsolutions.net>
 <20100722185449.GB528@suse.de>
 <m1eievugon.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>,
	Johannes Berg <johannes@sipsolutions.net>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:42289 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752763Ab0GZSKW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jul 2010 14:10:22 -0400
Content-Disposition: inline
In-Reply-To: <m1eievugon.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 06:31:52PM -0700, Eric W. Biederman wrote:
> Greg KH <gregkh@suse.de> writes:
> 
> > On Thu, Jul 22, 2010 at 08:36:41PM +0200, Johannes Berg wrote:
> >> On Thu, 2010-07-22 at 11:28 -0700, Greg KH wrote:
> >> 
> >> > It worked only because no one realized that it was broken with the
> >> > DEPRECATED option enabled.  When that is enabled, it is broken, right?
> >> 
> >> I'm pretty sure I always had that enabled, and never had issues. Can't
> >> test right now since I don't have that option back yet in the tree I'm
> >> using.
> >> 
> >> > Eric's changes to sysfs to add namespace support exposed this breakage.
> >> > That's not a reason to paper over the problem, but it should be driving
> >> > someone to fix it correctly, as has been pointed out a number of times
> >> > already.
> >> 
> >> I'm just contesting that that someone should be me. I don't think you
> >> get to blame driver developers for doing something that worked and
> >> solved the problem they needed to solve. sysfs is largely opaque to most
> >> of us already, and it now sure feels like Kay decided to change the
> >> rules underneath the code in saying "this was wrong all along".
> >
> > Well, if it worked before, and it doesn't now, that's due to Eric's
> > changes, nothing Kay and I did here :)
> 
> It mostly worked before, and it works with CONFIG_SYSFS_DEPRECATED=y
> (After I my stupid bug is fixed).
> 
> With CONFIG_SYSFS_DEPRECATED=y we have in sysfs:
> ........./net:bnep0 -> /sys/class/net/bnep0
> /sys/class/net/bnep0 is a directory.
> 
> With CONFIG_SYSFS_DEPRECATED=n we have in sysfs:
> ........./bnep0
> /sys/class/net/bnep0 -> ......./bnep0
> 
> Where for a normal network device we have:
> With CONFIG_SYSFS_DEPRECATED=y we have in sysfs:
> ........./net:eth0 -> /sys/class/net/eth0
> /sys/class/net/bnep0 is a directory.
> 
> With CONFIG_SYSFS_DEPRECATED=n we have in sysfs:
> ........./net/eth0
> /sys/class/net/eth0 -> ......./net/eth0
> 
> The new sysfs layout loses the net namespace separator for bluetooth
> devices.
> 
> > But, in looking at it closer, it does seem that the code is doing things
> > that was not expected to work at all previously, and It's amazing that
> > it did.  I thought Kay offered to help fix it all up, and provided 2
> > different ways to do it.  I know they aren't trivial, but then again,
> > your usage of sysfs is not trivial either...
> 
> I don't expect much just the upper levels to work correctly.  The fact
> this works on all but a handful of drivers is what I find dist
> 
> Does this version of the change look less bleh worthy?  The effect is
> the same as my previous patch but the test is more abstract so the
> effect is not strictly limited to /sys/class/net.

What other class type has a namespace at this point in time?
Essentially this is the same exact thing, just in a different format
that obfuscates what you are really doing here.

As you have now sent this to Linus and he took it, well, it seems moot,
right?

kids these days...

greg k-h
