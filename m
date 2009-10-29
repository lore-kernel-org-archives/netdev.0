From: dann frazier <dannf@dannf.org>
Subject: Re: [PATCH] udev: create empty regular files to represent net
 interfaces
Date: Thu, 29 Oct 2009 11:46:00 -0600
Message-ID: <20091029174600.GC3612@ldl.fc.hp.com>
References: <20091016214024.GA10091@ldl.fc.hp.com>
 <20091022063619.GB6321@ldl.fc.hp.com>
 <20091027205551.GA31963@auslistsprd01.us.dell.com>
 <ac3eb2510910280123g3c0e3d95wb38a239238906027@mail.gmail.com>
 <20091029131125.GA13809@auslistsprd01.us.dell.com>
 <20091029142554.GA16869@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Domsch <Matt_Domsch@dell.com>,
	Kay Sievers <kay.sievers@vrfy.org>,
	linux-hotplug@vger.kernel.org, Narendra_K@dell.com,
	netdev@vger.kernel.org, Jordan_Hargrave@dell.com,
	Charles_Rose@dell.com, Ben Hutchings <bhutchings@solarflare.com>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:23077 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756513AbZJ2Rp4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 13:45:56 -0400
Content-Disposition: inline
In-Reply-To: <20091029142554.GA16869@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2009 at 07:25:54AM -0700, Greg KH wrote:
> On Thu, Oct 29, 2009 at 08:11:25AM -0500, Matt Domsch wrote:
> > Netdev team - are you in agreement that having multiple names to
> > address the same netdevice is a worthwhile thing to add, to allow a
> > variety of naming schemes to exist simultaneously?  If not, this whole
> > discussion will be moot, and my basic problem, that the ethX naming
> > convention is nondeterministic, but we need determinism, remains
> > unresolved.
> 
> I'm still totally confused as to why you think this.  What is wrong with
> what we do today, which is name network devices in a deterministic
> manner by their MAC in userspace?  That name goes into the kernel, and
> everyone uses the same name and is happy.
> 
> If you don't like naming by MAC, then pick some other deterministic
> naming scheme that works for your hardware and write udev rules for it.
> 
> You could easily name them in a way that could keep the lowest number
> (eth0) for the lowest PCI id if you so desired and your BIOS guaranteed
> it.
> 
> This way the kernel has only one name, and so does userspace, and
> everyone is happy.

There are two issues, which really seem distinct to me.

Users expect eth0 to map to first-onboard-nic. That's an installer
issue (since the BIOS can already export this info) and I agree that
if we want to "fix" that, we should fix it there.

Users also want to have a name that matches the way they think of
their hardware - pci slot, bios-exposed-name, mac address,
whatever. This can be done today w/ custom udev rules, and I can
visualize an installer that would generate these rules for you:

Configure a NIC
    \-> Choose NIC by: MAC/CHASSIS-NAME/PCI-SLOT
      [ Present list of unconfigured NICs by selected property ]
      \-> What name would you like to use for this interface [eth3]?
          How do you want this configured (DHCP/STATIC/..)
          ...

That would make a lot of users much happier (myself included), but it
does restrict us into one view. At different times, admins think of
their NICs by different properties. I may want to do IP assignment by
the chassis name, but then run ethereal on a specific mac address. Or
I may want to see the routes assigned to all NICs in a given PCI
slot. Sure, I can lookup all of these properties and map them back to
an interface name by hand, but aliasing provides a nice way to
short-circuit that. And, by providing a library that translates the
aliases for us, we can help ensure that all apps that want to provide
aliasing can do so in a common way.

-- 
dann frazier

