From: Dan Williams <dcbw@redhat.com>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 12:40:58 -0400
Message-ID: <1237912858.9082.39.camel@localhost.localdomain>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
	 <49C9087C.5070907@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Matt Domsch <Matt_Domsch@dell.com>, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35310 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762363AbZCXQnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Mar 2009 12:43:11 -0400
In-Reply-To: <49C9087C.5070907@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-03-24 at 17:21 +0100, Patrick McHardy wrote:
> Matt Domsch wrote:
> > 2) udev may have rules to change the device names.  This is most often
> >    seen in the '70-persistent-net.rules' file.  Here we have
> >    additional challenges:
> > 
> > ...
> > 
> >    c) udev may not always be able to change a device's name.  If udev
> >       uses the kernel assignment namespace (ethN), then a rename of
> >       eth0->eth1 may require renaming eth1->eth0 (or something else).
> >       Udev operates on a single device instance at a time, it becomes
> >       difficult to switch names around for multiple devices, within
> >       the single namespace.
> 
> I would classify this as a bug, especially the fact that udev doesn't
> undo a failed rename, so you end up with ethX_rename. Virtual devices
> using the same MAC address trigger this reliably unless you add
> exceptions to the udev rules.

Any particular reason the MAC addresses are the same?  This came up a
while ago with the 'dnet' device in the thread "Dave DNET ethernet
controller".

If the MAC address isn't a UUID for the device, then *what* is?

If there isn't one, then certainly udev can't be blamed for getting
ordering or names wrong, because there's nothing to use to actually
match up the device to a name, uniquely.  Note that combinations
including bus IDs or device positions in the bus don't work for any type
of hotplug case, because you can plug another adapter into the same
location but it's a different adapter.

Either people want (a) a name assigned to a specific device (which
implies a UUID like a MAC address stored on that device somewhere
accessible to the driver at plug/boot time), or they want (b) to assign
a name to a *position* on the PCI or USB or firewire or whatever bus, or
they (c) don't care about this at all.

The answer is really 'all of the above'.  Most of the people Matt cares
about are probably in the (b) camp.  But most desktop/laptop users are
in the (a) camp because they use hotplug so much.

Dan

> You state that it only operates on one device at a time. If that is
> correct, I'm not sure why the _rename suffix is used at all instead
> of simply trying to assign the final name, which would avoid this
> problem.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

