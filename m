From: Greg KH <greg@kroah.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 17:10:09 -0800
Message-ID: <20070306011009.GA13267@kroah.com>
References: <20070304220857.GH23311@waste.org> <20070305011625.GA7681@kroah.com> <20070305064229.GJ23311@waste.org> <20070305070248.GA30699@kroah.com> <20070305071325.GK23311@waste.org> <20070305154609.GA3626@irc.pl> <20070305211425.GR16722@waste.org> <20070306002457.GA7078@brong.net> <20070306003715.GA12566@kroah.com> <20070306005625.GC19634@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Theodore Tso <tytso@mit.edu>, Bron Gondwana <brong@fastmail.fm>,
	Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yi.zhu@intel.com, jketreno@linux.intel.com,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:44469 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933762AbXCFBLx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 20:11:53 -0500
Content-Disposition: inline
In-Reply-To: <20070306005625.GC19634@thunk.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 07:56:25PM -0500, Theodore Tso wrote:
> On Mon, Mar 05, 2007 at 04:37:15PM -0800, Greg KH wrote:
> > But I AM TRYING TO MAKE IT COMPATIBLE!!!
> > 
> > That's what that config option is there for.  If you happen to be
> > running a newer userspace, a different distro than what is in Debian
> > right now, or don't use HAL and Networkmanager, then disable that
> > option.  Then all of sysfs looks just like it used to, no user visble
> > changes at all.  It doesn't get any more compatible than that.
> 
> This is great, but I think the real problem isn't the config option,
> but what is changing if the config option isn't enabled.  The claim
> which some, including Matt and Bron, seem to be making is that if you
> turn *off* CONFIG_SYSFS_DEPRECATED, you must be using at least hal
> 0.5.9-rc1, released ***yesterday***, or suffer breakages for at least
> some system configurations.

Ok, well that has been proven incorrect.  I originally thought it was
HAL that had the problem, but I think that is not true, as I am using
the older version of hal here (0.5.7.1) just fine.

> So the problem with putting a date in Kconfig.txt help file, or in
> Documentation/feature-removal-schedule.txt, is that if there are other
> incompatible changes which are added to sysfs in say, December 2007 or
> January 2008, but which are papered over with CONFIG_SYSFS_DEPRECATED,
> and then come June 2008, CONFIG_SYSFS_DEPRECATED is unceremoniously
> ripped out, then users will get screwed.  
> 
> So the question really is are we really done making changes to sysfs,
> or maybe what we should do is talk about major version numbers to
> sysfs.  Call what we have currently not CONFIG_SYSFS_DEPRECATED, but
> rather CONFIG_SYSFS_LAYOUT_1.  At the moment, CONFIG_SYSFS_LAYOUT_2 is
> undergoing changes, but at some point we need to lock down and state
> that Layout version 2 is never going to change, and then people who
> want changes can go work on CONFIG_SYSFS_LAYOUT_3.  
> 
> The problem with calling CONFIG_SYSFS_DEPRECATED is that people think
> that since it's deprecated, it should be turned off, but if we have
> staged major version numbers, with guarantees of absolute stability
> once a particular major version number is locked down, then it may
> make it a lot easier to talk about what version of hal and udev and
> Network Manager is really needed for different versions.  

This is what Documentation/ABI/ has tried to nail down, unfortunatly it
has turned out to be very hard to track down all of the odd userspace
programs that use sysfs and see what they are relying on.  We are slowly
fixing things, as is proof in the OpenSuSE and Gentoo releases.

And I'll be the first to admit that the ABI/ directory needs some
flushing out...

And it isn't really a whole different layout, the only problem here is
that a directory has turned into a symlink, so programs that were not
written that well (and I'll be the first to admit that I made the same
mistake in udev many years ago) and can't handle the change.

So numerous programs "just work" fine, but for a limited few, they have
problems, hence the config option so that nothing will break.

And if you look in the ABI/ directory, it describes this usage of the
class devices in sysfs.  But again, no one is flushing out the users of
these features, or even reading the stuff that is there...

So, again, a better wording for the CONFIG help text anyone?  Or a
better name for the CONFIG value itself?

thanks,

greg k-h
