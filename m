From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH v2] allow access to sysfs_groups member
Date: Mon, 16 Nov 2009 08:46:12 -0800
Message-ID: <20091116084612.3654bdd1@nehalam>
References: <20091113105157.GA322@e-circ.dyndns.org>
	<20091113142738.1aa81a03@s6510>
	<20091114165408.GA283@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Wolfgang Grandegger <wg@grandegger.com>, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58288 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753335AbZKPQqS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Nov 2009 11:46:18 -0500
In-Reply-To: <20091114165408.GA283@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Nov 2009 17:54:09 +0100
Kurt Van Dijck <kurt.van.dijck@eia.be> wrote:

> On Fri, Nov 13, 2009 at 02:27:38PM -0800, Stephen Hemminger wrote:
> > On Fri, 13 Nov 2009 11:51:57 +0100
> > Kurt Van Dijck <kurt.van.dijck@eia.be> wrote:
> [...]
> > EXPORT_SYMBOL_GPL() for all device/sysfs related stuff.
> Ok, no problem
> > 
> > Also, need some way to BUG() if this is done after device has
> > been registered.  
> Ok. I gave it a try. I _think_ I did it write, but a second look would
> not harm :-). I was not able to run a real test yet.
> > 
> > Another way to add sub-directories which is what bridge, bonding,
> > and others do is to use another kobject. I think this is what you
> > want for the case of two CAN objects under one netdevice.
> In fact, I wanted to add this for cards that have multiple seperate CAN
> network device, combined on 1 PCI or PCMCIA device.
> In the 'add network' uevent, a udev rule could find properties of the
> card (device/ symlink). Right now, there is no way to tell if a network
> device is bus 1 or 2 on the card. in CAN, there's no such thing as a MAC
> address.
> I encountered this issue with a softing CAN card (not yet in mainline),
> and there are other drivers in the socketCAN queue that have the same
> problem.
> 
> The ethernet cards with multiple busses (that I've seen yet :-) )
> combine multiple PCI devices on 1 card, and identification of the
> 'instance on the card' can happen with the sysfs properties delivered by
> the PCI bus.
> CAN devices with multiple busses typically are combined all together on
> 1 single device on the PCI or PCMCIA bus.
> 
> So, I wanted to add a 'channel' property in /sys/class/net/canX, which
> could indicate the instance on the device. Such property must be
> installed by the driver, not the bus the device is on.
> This patch allows me to have this channel property present at the moment
> of the uevent.
> 
> I can imagine other subsystems may benefit from this too.

Okay by me.

Acked-by: Stephen Hemminger <shemminger@vyatta.com>


-- 
