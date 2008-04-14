From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: udev can't name PS3's network devices correctly
Date: Mon, 14 Apr 2008 11:08:57 +0100
Message-ID: <1208167737.31695.32.camel@pmac.infradead.org>
References: <ftdb3v$tls$1@ger.gmane.org>
	 <20080407143805.GA9492@bongo.bofh.it>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Harald Hoyer <harald@redhat.com>, linux-hotplug@vger.kernel.org,
	netdev@vger.kernel.org
To: Marco d'Itri <md@Linux.IT>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:51649 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886AbYDNKJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2008 06:09:13 -0400
In-Reply-To: <20080407143805.GA9492@bongo.bofh.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-04-07 at 16:38 +0200, Marco d'Itri wrote:
> On Apr 07, Harald Hoyer <harald@redhat.com> wrote:
> 
> > So Kazunori Asayama attached a patch to the bugzilla, which modifies 
> > write_net_rules to take the KERNEL attribute also in account.
> >
> > What do you think?
>
> If this were accepted by Kay I would definitely remove it from the
> Debian package. It's an ugly hack for a broken device which should not
> be generalized. 

Actually it's a generic problem. It also occurs on OLPC, where the
libertas wireless device presents two interfaces with the same MAC
address -- the 'eth%d' interface for normal 802.11 wireless, and the
'msh%d' interface for mesh. This approach fixes that too. Our previous
fix for that was 'TEST=="anycast_mask"' and 'TEST=="lbs_rtap"', which
are horridly device-specific hacks.

It isn't _broken_ to have more than one device on the same host with the
same MAC address; it's just unusual.

One thing I don't understand: Don't we already emit a KERNEL== criterion
in the case where there is already a udev rule 'reserving' the name that
the kernel used for the current device? Why is that one OK, and why only
in that case? This patch just makes it consistent.

> Unconditionally adding a KERNEL key means that persistent names will
> break if a driver changes the base name (e.g. wlan* -> eth*).

Drivers shouldn't do that. It'll change the name of the device and may
confuse userspace :)


One alternative approach would be to use dev->dev_id (is that exported
in sysfs?). That's what IPv6 addrconf uses in addition to the MAC
address to provide a unique address when MAC addresses are shared.

We could modify the libertas and gelic (and any other affected) drivers
to provide a dev_id, make sure it's exported in sysfs, and then use that
in the udev rules. Would that make you happy?

It has implications w.r.t. the autoconfigured IPv6 addresses of those
devices, but I think we can cope with those. I'm probably the only
person in the world with an IPv6 address for a PS3 listed in DNS anyway.

> This workaround should be confined to the PS3 install media, there is
> no reason to add it to general-purpose distributions.

Our general-purpose distribution installs and runs on PS3. :)

-- 
dwmw2

