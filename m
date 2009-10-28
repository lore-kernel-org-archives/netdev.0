From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net interfaces
Date: Wed, 28 Oct 2009 08:03:08 -0500
Message-ID: <20091028130308.GA24611@auslistsprd01.us.dell.com>
References: <20091016214024.GA10091@ldl.fc.hp.com> <20091022063619.GB6321@ldl.fc.hp.com> <20091027205551.GA31963@auslistsprd01.us.dell.com> <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dann frazier <dannf@hp.com>, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, netdev@vger.kernel.org,
	Jordan_Hargrave@dell.com, Charles_Rose@dell.com,
	Ben Hutchings <bhutchings@solarflare.com>
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2009 at 09:23:57AM +0100, Kay Sievers wrote:
> On Tue, Oct 27, 2009 at 21:55, Matt Domsch <Matt_Domsch@dell.com> wrote:
> > On Thu, Oct 22, 2009 at 12:36:20AM -0600, dann frazier wrote:
> >> Here's a proof of concept to further the discussion..
> >>
> >> The default filename uses the format:
> >> ?? /dev/netdev/by-ifindex/$ifindex
> >>
> >> This provides the infrastructure to permit udev rules to create aliases for
> >> network devices using symlinks, for example:
> >>
> >> ?? /dev/netdev/by-name/eth0 -> ../by-ifindex/1
> >> ?? /dev/netdev/by-biosname/LOM0 -> ../by-ifindex/3
> >>
> >> A library (such as the proposed libnetdevname) could use this information
> >> to provide an alias->realname mapping for network utilities.
> >
> > yes, this could work, as IFINDEX is already exported in the uevents,
> > and that's the primary value udev needs to set up the mapping.
> >
> > While I like the little ifindex2name script you've got, I think udev
> > could simply call if_indextoname() to get this, and not call an
> > external program? ??I suppose it could be a really really simple
> > external program too.
> 
> What's the point of all this? Why would udev ever need to find the
> name of a device by the ifindex? The device name is the primary value
> for the kernel events udev acts on.

Ultimately, udev doesn't care.  I just want to use udev to keep track
of the pathname to device connections, like it does for all other
types of devices.

Applications such as net-tools, iproute, ethtool, etc.  take a kernel
device name.  I want to extend them to also take a path, and resolve
that path to a kernel device name.  libnetdevname currently is _one
small function_ which does this.  It need not even be in a library.
But whatever the mechanism, the path names need to be anchored
somewhere, so the library or all apps doing this kind of lookup know
where to look.

> That all sounds very much like something which will hit us back some
> day. I'm not sure, if udev should publish such dead text files in
> /dev, it does not seem to fit the usual APIs/assumptions where /sys
> and /dev match, and libudev provides access to both. It all sounds
> more like a database for a possible netdevname library, which does not
> need to be public in /dev, right?

Right, it doesn't need to be in /dev.  We could have udev rules that
simply call yet another program to maintain that database, in yet
another way.  But I really like how udev maintains the database of
symlinks for other device types, using symlinks in /dev/, and which
people are quite familiar with.  Why can't it be extended to do
likewise for network device names too?

There is a completely different approach possible here, if people
don't want to use something like /dev to track device name aliases.
We could put the whole name alias mechanism in the kernel, with new
netlink commands to add/remove/list aliases (and now we've overloaded that
term, as the old eth0:1 "alias" and dmz -> eth1 "alias" wouldn't be
the same thing).  But that idea hasn't met with a lot of interest
either.


-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
