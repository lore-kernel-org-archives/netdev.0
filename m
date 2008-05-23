From: Jon Masters <jonathan@jonmasters.org>
Subject: Re: network interface *name* alias support?
Date: Fri, 23 May 2008 15:06:43 -0400
Message-ID: <1211569604.11907.37.camel@perihelion>
References: <alpine.LNX.1.10.0805231817100.25193@fbirervta.pbzchgretzou.qr>
	 <4836FB73.2010709@intel.com>  <4837026A.6000702@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Jan Engelhardt <jengelh@medozas.de>, johnathan@jonmasters.org,
	netdev@vger.kernel.org, dwmw2@infradead.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dallas.jonmasters.org ([72.29.103.172]:45486 "EHLO
	dallas.jonmasters.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbYEWTG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 May 2008 15:06:56 -0400
In-Reply-To: <4837026A.6000702@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Fri, 2008-05-23 at 10:44 -0700, Rick Jones wrote:
> > FWIW you can just use ethtool to determine the slot address quickly
> > in userspace. There's no real need to do this in the kernel.
> > 
> > # ethtool -i eth0
> > driver: e1000e
> > version: 0.2.0
> > firmware-version: 1.3-0
> > bus-info: 0000:00:19.0
> 
> And if it happens to be in a hotplug slot today with a suitable hotplug 
> module (term?) loaded like acpiphp you can then map that to a more human 
> friendly slot number/name.  In the future, once Alex Chiang's pci slots 
> patches make it to mainline it will be possible even with non-hotplug slots.

Yep, that's all great until the bus topology changes underneath you.
There is a need for alias support, because it will allow distributions
to assign a name based upon the *slot ordering specified by the vendor*
and therefore allow a consistent slot number no matter what hotplug
happens, what devices are added or removed, which devices are on-board
vs. in cards, and even (eventually) for non-PCI cards.

In the case of Fedora, right now, we have files:

ifcfg-eth<whatever>

These bind to an interface based on the MAC address. If you swap out the
card, you lose. If you pull out the disks from the machine and put them
into another similar machine, you lose. If you put the disks from the
machine into a less similar machine, but one that still has multiple
network interfaces, you lose.

Some enterprise distributions actually have to play with "bfsort" PCI
enumeration orderings in order to ensure that network devices come up in
a reliable order...this is not the way to be (in the longer term)
determining what order the vendor thinks those cards should be in. This
is why they have a DMI extension that allows them to specify this
without being concerned with PCI bus orderings, or anything else.

My intention is to also allow for:

ifcfg-slot_<whatever>

Where the configuration is based entirely upon what vendor <XYZ> says is
the first, second, or third card. Then, those who want to use the older
names can continue to do so, but those who prefer to base their
configuration upon the order the vendor states, can do so.

Jon.


