From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] Driver-core: Fix bluetooth network device rename
 regression
Date: Thu, 22 Jul 2010 11:54:49 -0700
Message-ID: <20100722185449.GB528@suse.de>
References: <20100719133451.0862ca62.akpm@linux-foundation.org>
 <20100720201334.GA11991@suse.de>
 <m139vd5sms.fsf_-_@fess.ebiederm.org>
 <m1zkxj27xp.fsf_-_@fess.ebiederm.org>
 <AANLkTimM5Ea8mQ7aX4kDq3dgF3P-t2Wm3dERhckC69Ja@mail.gmail.com>
 <m1vd87toy9.fsf@fess.ebiederm.org>
 <AANLkTil3Q1Vobw48AvStl9gphaJcyUGlt6ZnMLanDMVn@mail.gmail.com>
 <1279822828.12439.24.camel@jlt3.sipsolutions.net>
 <20100722182827.GA12821@suse.de>
 <1279823801.12439.31.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kay Sievers <kay.sievers@vrfy.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Greg KH <greg@kroah.com>, "Rafael J. Wysocki" <rjw@sisk.pl>,
	"Maciej W. Rozycki" <macro@linux-mips.org>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:43307 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751730Ab0GVS4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jul 2010 14:56:24 -0400
Content-Disposition: inline
In-Reply-To: <1279823801.12439.31.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 22, 2010 at 08:36:41PM +0200, Johannes Berg wrote:
> On Thu, 2010-07-22 at 11:28 -0700, Greg KH wrote:
> 
> > It worked only because no one realized that it was broken with the
> > DEPRECATED option enabled.  When that is enabled, it is broken, right?
> 
> I'm pretty sure I always had that enabled, and never had issues. Can't
> test right now since I don't have that option back yet in the tree I'm
> using.
> 
> > Eric's changes to sysfs to add namespace support exposed this breakage.
> > That's not a reason to paper over the problem, but it should be driving
> > someone to fix it correctly, as has been pointed out a number of times
> > already.
> 
> I'm just contesting that that someone should be me. I don't think you
> get to blame driver developers for doing something that worked and
> solved the problem they needed to solve. sysfs is largely opaque to most
> of us already, and it now sure feels like Kay decided to change the
> rules underneath the code in saying "this was wrong all along".

Well, if it worked before, and it doesn't now, that's due to Eric's
changes, nothing Kay and I did here :)

But, in looking at it closer, it does seem that the code is doing things
that was not expected to work at all previously, and It's amazing that
it did.  I thought Kay offered to help fix it all up, and provided 2
different ways to do it.  I know they aren't trivial, but then again,
your usage of sysfs is not trivial either...

thanks,

greg k-h
