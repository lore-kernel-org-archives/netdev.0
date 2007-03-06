From: Theodore Tso <tytso@mit.edu>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 19:56:25 -0500
Message-ID: <20070306005625.GC19634@thunk.org>
References: <20070304220857.GH23311@waste.org> <20070305011625.GA7681@kroah.com> <20070305064229.GJ23311@waste.org> <20070305070248.GA30699@kroah.com> <20070305071325.GK23311@waste.org> <20070305154609.GA3626@irc.pl> <20070305211425.GR16722@waste.org> <20070306002457.GA7078@brong.net> <20070306003715.GA12566@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bron Gondwana <brong@fastmail.fm>, Matt Mackall <mpm@selenic.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yi.zhu@intel.com, jketreno@linux.intel.com, akpm@osdl.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from THUNK.ORG ([69.25.196.29]:47213 "EHLO thunker.thunk.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbXCFA4d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 19:56:33 -0500
Content-Disposition: inline
In-Reply-To: <20070306003715.GA12566@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 04:37:15PM -0800, Greg KH wrote:
> But I AM TRYING TO MAKE IT COMPATIBLE!!!
> 
> That's what that config option is there for.  If you happen to be
> running a newer userspace, a different distro than what is in Debian
> right now, or don't use HAL and Networkmanager, then disable that
> option.  Then all of sysfs looks just like it used to, no user visble
> changes at all.  It doesn't get any more compatible than that.

This is great, but I think the real problem isn't the config option,
but what is changing if the config option isn't enabled.  The claim
which some, including Matt and Bron, seem to be making is that if you
turn *off* CONFIG_SYSFS_DEPRECATED, you must be using at least hal
0.5.9-rc1, released ***yesterday***, or suffer breakages for at least
some system configurations.

So the problem with putting a date in Kconfig.txt help file, or in
Documentation/feature-removal-schedule.txt, is that if there are other
incompatible changes which are added to sysfs in say, December 2007 or
January 2008, but which are papered over with CONFIG_SYSFS_DEPRECATED,
and then come June 2008, CONFIG_SYSFS_DEPRECATED is unceremoniously
ripped out, then users will get screwed.  

So the question really is are we really done making changes to sysfs,
or maybe what we should do is talk about major version numbers to
sysfs.  Call what we have currently not CONFIG_SYSFS_DEPRECATED, but
rather CONFIG_SYSFS_LAYOUT_1.  At the moment, CONFIG_SYSFS_LAYOUT_2 is
undergoing changes, but at some point we need to lock down and state
that Layout version 2 is never going to change, and then people who
want changes can go work on CONFIG_SYSFS_LAYOUT_3.  

The problem with calling CONFIG_SYSFS_DEPRECATED is that people think
that since it's deprecated, it should be turned off, but if we have
staged major version numbers, with guarantees of absolute stability
once a particular major version number is locked down, then it may
make it a lot easier to talk about what version of hal and udev and
Network Manager is really needed for different versions.  

					- Ted
