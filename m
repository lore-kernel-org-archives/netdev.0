From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: RFC: dsa: add support for multiple CPU ports
Date: Tue, 10 Mar 2015 23:50:42 +0100
Message-ID: <20150310225042.GA14112@lunn.ch>
References: <20150310190129.GB5636@codeaurora.org>
 <20150310192101.GD10838@lunn.ch>
 <20150310221340.GA6465@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux@roeck-us.net, jogo@openwrt.org,
	f.fainelli@gmail.com
To: Mathieu Olivari <mathieu@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57252 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752285AbbCJWyD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 18:54:03 -0400
Content-Disposition: inline
In-Reply-To: <20150310221340.GA6465@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I had a different solution in mind for multiple CPU ports. I've no
> > idea if it actually works though, i've not had time to investigate.
> > It would actually put the host CPU ports into a switch trunk, and use
> > team/bond driver on the host. You then get one logical 2Gbp link to
> > the switch and run DSA over that.
> > 
> 
> I could see it working on the Tx path - as the destination port is specified
> in the header -, but on the Rx path, how would the switch figure out which
> CPU port it should send the packet to?
>
> These switches doesn't have a concept of bonding, so this decision is generally
> based on the internal ARL table, and is automatically learnt by looking at the
> src MAC@ of the incoming packets.

All Marvell switches, and according to Florian SF2 and B53 support
trunk groups. I assume the switch does load balancing between ports in
a trunk. On the CPU you can then use the header to determine which
port the packet came from.

> When using bonding, the switch would see both eth0 & eth1 MAC@ on both of
> its CPU ports. The destination CPU port would be unexpected at best; I could
> see some switches being able to support this, but most of them would not.

At the moment, this is purely an idea. I do have two boards where i
can test it out with Marvell devices, once i get some spare time.
Florian might be able to comment about SF2 and B53, if we thinks
trunking and broadcom tags can be combined.

> At the very least, we would need to treat "dsa,ethernet" as an array,
> and specify the list of ethernet device node that connects to the switch.

True.

> I still think putting this information in the port section makes sense,
> as it represents the board layout more accurately than having a global
> node at a dsa level.

Yes, it does make sense to have it in port. But to keep backwards
compatibility, we need at keep dsa,ethernet, with at least one
interface.

	Andrew
