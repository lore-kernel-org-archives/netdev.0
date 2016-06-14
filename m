From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Avoiding bridge flood of multicast when L2 switch is used
Date: Tue, 14 Jun 2016 22:26:26 +0200
Message-ID: <20160614202626.GD8518@lunn.ch>
References: <57606530.6030208@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	john.r.fastabend@intel.com, Florian Fainelli <f.fainelli@gmail.com>
To: Murali Karicheri <m-karicheri2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:45925 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbcFNU0b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 16:26:31 -0400
Content-Disposition: inline
In-Reply-To: <57606530.6030208@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> netdev experts,
> 
> When there is a L2 switch underneath the network interface a flooding of
> multicast at the bridge interface results in one copy of this going through each
> of the slave resulting in multiple multicast packets reaching the underlying switch.

Yes, this is something Florian, Vivien and i have discussed. We don't
yet see a way around it. Neither the Marvell or Broadcast switches
have a mechanism to say: Send this frame out of this list of
interfaces. All we can do is send it out a single interface. Even if
we could direct a single frame out multiple interfaces, we still have
the problem of how to teach the bridge about this, in a clean and
elegant fashion.

Overall, this seems like a hard problem. Since it is a hard problem,
implementing IGMP snooping first would make sense. Don't forward the
packet out a port unless you know there is somebody interested in it.
The swichdev parts of IGMP snooping are in place, we just need to
continue them down into DSA.

> L2 switch also duplicates the multicast packet on each egress port as done
> in software bridge. This is undesirable as it reduces the available bandwidth to
> half when multicast packets are involved.

Once you have a DSA driver, the switch will not do this replication.
So you will gain something there.

     Andrew
