From: jamal <hadi@cyberus.ca>
Subject: RE: [PATCH] NET: Multiqueue network device support.
Date: Sat, 09 Jun 2007 23:02:39 -0400
Message-ID: <1181444559.4043.91.camel@localhost>
References: <1181168020.4064.46.camel@localhost>
	 <D5C1322C3E673F459512FB59E0DDC32902FC61BF@orsmsx414.amr.corp.intel.com>
	 <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D69C@nekter>
	 <1181417000.4043.34.camel@localhost>
	 <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D6BC@nekter>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Alex Aizman <aaizman@neterion.com>
To: Leonid Grossman <Leonid.Grossman@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:2628 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754339AbXFJDCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jun 2007 23:02:42 -0400
Received: by py-out-1112.google.com with SMTP id a29so1975024pyi
        for <netdev@vger.kernel.org>; Sat, 09 Jun 2007 20:02:42 -0700 (PDT)
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7701B7D6BC@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2007-09-06 at 17:23 -0400, Leonid Grossman wrote:

> Not really. This is a very old presentation; you probably saw some newer
> PR on Convergence Enhanced Ethernet, Congestion Free Ethernet etc.

Not been keeping up to date in that area.

> These efforts are in very early stages and arguably orthogonal to
> virtualization, but in general having per channel QoS (flow control is
> just a part of it) is a good thing. 

our definition of "channel" on linux so far is a netdev
(not a DMA ring). A netdev is the entity that can be bound to a CPU.
Link layer flow control terminates (and emanates) from the netdev.

> But my point was that while virtualization capabilities of upcoming NICs
> may be not even relevant to Linux, the multi-channel hw designs (a side
> effect of virtualization push, if you will) will be there and a
> non-virtualized stack can take advantage of them.

Makes sense...

> Actually, our current 10GbE NICs have most of such multichannel
> framework already shipping (in pre-IOV fashion), so the programming
> manual on the website can probably give you a pretty good idea about how
> multi-channel 10GbE NICs may look like. 

Ok, thanks.

> Right, this is one deployment scenario for a multi-channel NIC, and it
> will require very few changes in the stack (couple extra IOCTLS would be
> nice).

Essentially a provisioning interface.

> There are two reasons why you still may want to have a generic
> multi-channel support/awareness in the stack: 
> 1. Some users may want to have single ip interface with multiple
> channels.
> 2. While multi-channel NICs will likely to be many, only "best-in-class"
> will make the hw "channels" completely independent and able to operate
> as a separate nic. Other implementations may have some limitations, and
> will work as multi-channel API compliant devices but not nesseserily as
> independent mac devices.
> I agree though that supporting multi-channel APIs is a bigger effort.

IMO, the challenges you describe above are solvable via a parent
netdevice (similar to bonding) with children being the virtual NICs. The
IP address is attached to the parent. Of course the other model is not
to show the parent device at all.

> To a degree. We have quite a bit of testing done in non-virtual OS (not
> in Linux though), using channels with tx/rx rings, msi-x etc as
> independent NICs. Flow control was not a focus since the fabric
> typically was not congested in these tests, but in theory per-channel
> flow control should work reasonably well. Of course, flow control is
> only part of resource sharing problem. 

In the current model - flow control to the s/ware queueing level (qdisc)
is implicit. i.e hardware receives pause frames - stops sending; ring
becomes full as hardware sends, netdev tx path gets shut until things
open up when 

> This is not what I'm saying :-). The IEEE link you sent shows that
> per-link flow control is a separate effort, and it will likely to take
> time to become a standard. 

Ok, my impression was it was happening already or it will happen
tommorow morning ;->

> Also, (besides the shared link) the channels will share pci bus.
> 
> One solution could be to provide a generic API for QoS level to a
> channel 
> (and also to a generic NIC!). 
> Internally, device driver can translate QoS requirements into flow
> control, pci bus bandwidth, and whatever else is shared on the physical
> NIC between the channels.
> As always, as some of that code becomes common between the drivers it
> can migrate up.

indeed. 

cheers,
jamal


