From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] udev: create empty regular files to represent net
	interfaces
Date: Wed, 28 Oct 2009 13:06:56 +0000
Message-ID: <1256735216.2846.11.camel@achroite>
References: <20091016214024.GA10091@ldl.fc.hp.com>
	 <20091022063619.GB6321@ldl.fc.hp.com>
	 <20091027205551.GA31963@auslistsprd01.us.dell.com>
	 <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Domsch <Matt_Domsch@dell.com>, dann frazier <dannf@hp.com>,
	linux-hotplug@vger.kernel.org, Narendra_K@dell.com,
	netdev@vger.kernel.org, Jordan_Hargrave@dell.com,
	Charles_Rose@dell.com
To: Kay Sievers <kay.sievers@vrfy.org>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-10-28 at 09:23 +0100, Kay Sievers wrote:
> On Tue, Oct 27, 2009 at 21:55, Matt Domsch <Matt_Domsch@dell.com> wrote:
> > On Thu, Oct 22, 2009 at 12:36:20AM -0600, dann frazier wrote:
> >> Here's a proof of concept to further the discussion..
> >>
> >> The default filename uses the format:
> >>   /dev/netdev/by-ifindex/$ifindex
> >>
> >> This provides the infrastructure to permit udev rules to create aliases for
> >> network devices using symlinks, for example:
> >>
> >>   /dev/netdev/by-name/eth0 -> ../by-ifindex/1
> >>   /dev/netdev/by-biosname/LOM0 -> ../by-ifindex/3
> >>
> >> A library (such as the proposed libnetdevname) could use this information
> >> to provide an alias->realname mapping for network utilities.
> >
> > yes, this could work, as IFINDEX is already exported in the uevents,
> > and that's the primary value udev needs to set up the mapping.
> >
> > While I like the little ifindex2name script you've got, I think udev
> > could simply call if_indextoname() to get this, and not call an
> > external program?  I suppose it could be a really really simple
> > external program too.
> 
> What's the point of all this? Why would udev ever need to find the
> name of a device by the ifindex? The device name is the primary value
> for the kernel events udev acts on.
[...]

Since net devices can be renamed, unlike other devices, the ifindex is
the proper stable identifier.  Using the name as an identifier opens up
race conditions.  If there are events that don't include the ifindex,
this should be fixed.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

