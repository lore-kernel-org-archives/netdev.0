From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 2 Apr 2009 00:23:52 +0200
Message-ID: <20090401222352.GY11935@one.firstfloor.org>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3CEC5.20606@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:34751 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbZDAWWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 18:22:10 -0400
Content-Disposition: inline
In-Reply-To: <49D3CEC5.20606@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 01, 2009 at 04:29:57PM -0400, Gregory Haskins wrote:
> > description?
> >   
> Yes, good point.  I will be sure to be more explicit in the next rev.
> 
> >   
> >> So the administrator can then set these attributes as
> >> desired to manipulate the configuration of the instance of the device,
> >> on a per device basis.
> >>     
> >
> > How would the guest learn of any changes in there?
> >   
> The only events explicitly supported by the infrastructure of this
> nature would be device-add and device-remove.  So when an admin adds or
> removes a device to a bus, the guest would see driver::probe() and
> driver::remove() callbacks, respectively.  All other events are left (by
> design) to be handled by the device ABI itself, presumably over the
> provided shm infrastructure.

Ok so you rely on a transaction model where everything is set up
before it is somehow comitted to the guest? I hope that is made
explicit in the interface somehow.

> This script creates two buses ("client-bus" and "server-bus"),
> instantiates a single venet-tap on each of them, and then "wires" them
> together with a private bridge instance called "vbus-br0".  To complete
> the picture here, you would want to launch two kvms, one of each of the
> client-bus/server-bus instances.  You can do this via /proc/$pid/vbus.  E.g.
> 
> # (echo client-bus > /proc/self/vbus; qemu-kvm -hda client.img....)
> # (echo server-bus > /proc/self/vbus; qemu-kvm -hda server.img....)
> 
> (And as noted, someday qemu will be able to do all the setup that the
> script did, natively.  It would wire whatever tap it created to an
> existing bridge with qemu-ifup, just like we do for tun-taps today)

The usual problem with that is permissions. Just making qemu-ifup suid
it not very nice.  It would be good if any new design addressed this.

> the current code doesnt support rw on the mac attributes yet..i need a
> parser first).

parser in kernel space always sounds scary to me.


> 
> Yeah, ultimately I would love to be able to support a fairly wide range
> of the normal userspace/kernel ABI through this mechanism.  In fact, one
> of my original design goals was to somehow expose the syscall ABI
> directly via some kind of syscall proxy device on the bus.  I have since

That sounds really scary for security. 


> backed away from that idea once I started thinking about things some
> more and realized that a significant number of system calls are really
> inappropriate for a guest type environment due to their ability to
> block.   We really dont want a vcpu to block.....however, the AIO type

Not only because of blocking, but also because of security issues.
After all one of the usual reasons to run a guest is security isolation.

In general the more powerful the guest API the more risky it is, so some
self moderation is probably a good thing.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
