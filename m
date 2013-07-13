From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 3/3] pch_gbe: Add MinnowBoard support
Date: Sat, 13 Jul 2013 10:09:14 -0700
Message-ID: <20130713170914.GA3837@kroah.com>
References: <ce5dd365d05f8747d269aa74e0bb929935d9cdee.1373676797.git.dvhart@linux.intel.com>
 <ad20133699c36bd8d183dd685f1b35f6d6b99005.1373676797.git.dvhart@linux.intel.com>
 <20130713011731.GA17939@kroah.com>
 <1373694381.3475.95.camel@envy.home>
 <20130713062631.GB15155@kroah.com>
 <1373731681.3475.113.camel@envy.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	netdev@vger.kernel.org, stable@vger.kernel.org
To: Darren Hart <dvhart@linux.intel.com>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1373731681.3475.113.camel@envy.home>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 13, 2013 at 09:08:01AM -0700, Darren Hart wrote:
> On Fri, 2013-07-12 at 23:26 -0700, Greg KH wrote:
> > On Fri, Jul 12, 2013 at 10:46:21PM -0700, Darren Hart wrote:
> > > On Fri, 2013-07-12 at 18:17 -0700, Greg KH wrote:
> > > > > ---
> > > > >  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    | 15 ++++
> > > > >  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 48 +++++++++++
> > > > >  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.c    | 98 ++++++++++++++++++++++
> > > > >  .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  2 +
> > > > >  4 files changed, 163 insertions(+)
> > > > 
> > > > This is _far_ more than just a simple "add a new device id" for a stable
> > > > kernel update.   Please go read Documentation/stable_kernel_rules.txt
> > > > again for why there's no way I can take this type of thing.
> > > >
> > > > You know better than this.
> > > 
> > > I do appreciate the documentation that is there, and I have read it
> > > (several times). The first two for 3.8 should be acceptable.
> > 
> > I didn't even look at those other patches (and hint, 3.8 is dead and
> > burried, no stable releases are happening for it that really matter.)
> > 
> > I'm talking about _this_ patch.  Look at it.  How big it is.  How it's
> > not just "add a new device id."  Now please explain how _this_ patch
> > meets the stable kernel rules as documented?  Let alone the pr_*
> > conversions, ick, don't get me started...
> 
> I was looking at it as a quirk:
> 
> " - New device IDs and quirks are also accepted."
> 
> I even considered implementation as a pci quirk. I didn't because the
> PHY work needed to happen too late during probe. The frustrating thing
> is there is probably 15 lines of code that are needed to get it to
> work, all the rest is infrastructure to make it generic.

163 lines of code is not a "quirk" I can accept.  When I wrote, "new
device ids or quirks can be accpted for stable", I meant things like
commit 9e9dd0e889c76c786e8f2e164c825c3c06dea30c.  That's acceptable.
Not thing huge thing.

> I get the size argument. It's too big. The docs say 100 lines with
> context, I've seen much larger go in... I just wasn't sure where the
> line is. It seems things are getting more strict here, not less. OK.
> Lesson learned.

You have seen larger "quirks" than this go into the stable tree?
Examples for where I've been sleeping on the job would be good.

And that's the whole point of the huge thread I pointed you at, people
are trying to get stuff into stable that they shouldn't be (and they are
being lazy, but that's not the issue with this patch...)

> > Just have users use 3.11, it's not like you have shipping hardware yet,
> 
> We're talking days here, but yes.
> 
> > and again, who cares about 3.8.  Heck, who cares about 3.9 or even 3.10
> > for brand-new hardware.  Just use 3.11 or 3.12 and don't worry about
> > backport hell.
> > 
> > This isn't going to land in Linus's tree until 3.12 anyway, so what's
> > the rush?
> 
> My reasoning is that the BSP for this is based on 3.8. I would like to
> bring 3.8 in sync with master for support of this board so I can update
> the release BSP to use the same sources. People can use my code from
> the linux-yocto_3.8 standard/minnow branch, but it would be preferable
> if that code was also destined for upstream.

That's your choice to pick 3.8, not upstream's (and frankly, not
something that I would have picked, but that's another topic...)

> If you still feel this doesn't qualify as a "quirk", I'll drop the
> stable push. If you can see that argument, I can look at breaking it up
> into smaller chunks, or possibly reducing some of the generic bits and
> doing the bare minimum to get it working and follow-up in master with
> more generic bits.

You are adding functionality for new devices that take much more than a
simple "add an id to a table", so no, it's not ok for stable releases.

thanks,

greg k-h
