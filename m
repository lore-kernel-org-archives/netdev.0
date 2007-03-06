From: Dan Williams <dcbw@redhat.com>
Subject: Re: [2.6.21 patch] unconditionally enable SYSFS_DEPRECATED
Date: Tue, 06 Mar 2007 10:55:34 -0500
Message-ID: <1173196534.12545.12.camel@localhost.localdomain>
References: <20070304220857.GH23311@waste.org>
	 <1173051564.6131.13.camel@johannes.berg> <20070305002550.GI23311@waste.org>
	 <20070305011729.GB7681@kroah.com> <20070305125950.GC26781@thunk.org>
	 <20070305185813.GA31465@kroah.com> <20070305234052.GR3441@stusta.de>
	 <20070306000722.GA11436@kroah.com> <20070306013020.GN23311@waste.org>
	 <20070306015638.GA23756@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>, Adrian Bunk <bunk@stusta.de>,
	Theodore Tso <tytso@mit.edu>,
	Johannes Berg <johannes@sipsolutions.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yi.zhu@intel.com, jketreno@linux.intel.com,
	linux-wireless <linux-wireless@vger.kernel.org>, akpm@osdl.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:52391 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965416AbXCFRzM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 12:55:12 -0500
In-Reply-To: <20070306015638.GA23756@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-03-05 at 17:56 -0800, Greg KH wrote:
> On Mon, Mar 05, 2007 at 07:30:21PM -0600, Matt Mackall wrote:
> > On Mon, Mar 05, 2007 at 04:07:22PM -0800, Greg KH wrote:
> > > On Tue, Mar 06, 2007 at 12:40:52AM +0100, Adrian Bunk wrote:
> > > > On Mon, Mar 05, 2007 at 10:58:13AM -0800, Greg KH wrote:
> > > > > 
> > > > > Ok, how about the following patch.  Is it acceptable to everyone?
> > > > > 
> > > > > thanks,
> > > > > 
> > > > > greg k-h
> > > > > 
> > > > > ---
> > > > >  init/Kconfig |   13 +++++++++++--
> > > > >  1 file changed, 11 insertions(+), 2 deletions(-)
> > > > > 
> > > > > --- gregkh-2.6.orig/init/Kconfig
> > > > > +++ gregkh-2.6/init/Kconfig
> > > > > @@ -290,8 +290,17 @@ config SYSFS_DEPRECATED
> > > > >  	  that belong to a class, back into the /sys/class heirachy, in
> > > > >  	  order to support older versions of udev.
> > > > >  
> > > > > -	  If you are using a distro that was released in 2006 or later,
> > > > > -	  it should be safe to say N here.
> > > > > +	  If you are using an OpenSuSE, Gentoo, Ubuntu, or Fedora
> > > > > +	  release from 2007 or later, it should be safe to say N here.
> > > > > +
> > > > > +	  If you are using Debian or other distros that are slow to
> > > > > +	  update HAL, please say Y here.
> > > > >...
> > > > 
> > > > The sane solution seems to be to enable SYSFS_DEPRECATED unconditionally 
> > > > for all users, and schedule it's removal for mid-2008 (or later).
> > > > 
> > > > 12 months after the first _release_ of a HAL that can live without seems 
> > > > to be the first time when we can consider getting rid of it, since all 
> > > > distributions with at least one release a year should ship it by then.
> > > > 
> > > > Currently, SYSFS_DEPRECATED is only a trap for users.
> > > 
> > > Huh?
> > > 
> > > No, again, I've been using this just fine for about 6 months now.
> > > 
> > > And what about all of the servers not using HAL/NetworkManager?
> > > And what about all of the embedded systems not using either?
> > > 
> > > So to not allow this to be turned off by people who might want to (we
> > > want this for OpenSuSE 10.3, and Fedora 7 also will want this, as will
> > > other distros released this year), is pretty heavy-handed.
> > > 
> > > It also will work in OpenSuSE 10.2 which is already released, and I
> > > think Fedora 6, but I've only limited experience with these.
> > > 
> > > Oh, and Gentoo works just fine, and has been for the past 6 months.
> > >
> > > I would just prefer to come up with an acceptable set of wording that
> > > will work to properly warn people.
> > > 
> > > I proposed one such wording which some people took as a slam against
> > > Debian, which it really was not at all.
> > > 
> > > Does someone else want to propose some other wording instead?
> > 
> > Back up a bit. Let's review:
> > 
> > Problem: NetworkManager stopped working with my ipw2200 on Debian/unstable
> > 
> > Theory A: It broke because I'm not running an as-yet-unreleased HAL.
> > 
> >  Then we should revert the patch pronto because it's an unqualified
> >  regression.
> > 
> > Theory B: It broke because I'm not running relatively recent HAL.
> > 
> >  By all accounts I'm running the latest and greatest HAL and Network
> >  Manager, more than recent enough to work.
> > 
> > Theory C: It broke because I've got some goofy config.
> > 
> >  My setup passes no arguments to either. The HAL config file is
> >  completely bare-bones and there's no sign of any configuration files
> >  for Network Manager.
> > 
> > Theory D: It broke for some nebulous Debian-related reason.
> > 
> >  That's a bunch of unhelpful crap.
> > 
> 
> > Can we come up with an actual theory for what's wrong with my setup, please?
> > Like, perhaps:
> > 
> > Theory E: There's some undiagnosed new breakage that this introduces
> > that no else hit until it went into mainline.
> 
> Theory F:  It broke because you are using NetworkManager for your
> network devices and the patches that fix this have not made it into a
> real release?

The problem is _NOT_ NetworkManager.  NM just asks HAL for network
devices, NM does not muck with /sys at all.  If HAL can't see it,
NetworkManager can't see it, because NM uses HAL.

The problem is that sysfs is fundamentally a kernel API.  Whenever it
changes, HAL must change or HAL will break.  Same story with anything
that ever reads from sysfs.

Dan

> I'm just guessing, but does anyone who is having this problem, NOT using
> NetworkManager?
> 
> I'm running an old version of HAL just fine, but I'm not using
> NetworkManager here.
> 
> I am using NetworkManager on a OpenSuSE 10.3 release, but suse's version
> of NetworkManager is well known to not be anywhere near what is released
> as a tarball :(
> 
> thanks,
> 
> greg k-h
> -
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

