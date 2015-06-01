From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH RFC 2/3] dsa: Add support for multiple cpu ports.
Date: Mon, 01 Jun 2015 09:23:17 +0200
Message-ID: <87fv6bevtm.fsf@nemi.mork.no>
References: <1432926814-22648-1-git-send-email-andrew@lunn.ch>
	<1432926814-22648-3-git-send-email-andrew@lunn.ch>
	<871thyfer0.fsf@nemi.mork.no> <20150601005105.GA8647@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>, mathieu@codeaurora.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:48817 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750820AbbFAHXg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 03:23:36 -0400
In-Reply-To: <20150601005105.GA8647@lunn.ch> (Andrew Lunn's message of "Mon, 1
	Jun 2015 02:51:05 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Lunn <andrew@lunn.ch> writes:

> So the ports look like normal ports, and you configure then using the
> normal mechanisms.
>
> DSA does not use vlans. It uses an additional protocol header which
> the switch supports, to allow the CPU to direct packets out a specifi=
c
> port. Similarly, packets coming to the CPU from a port and marked wit=
h
> the port they ingressed. This means the ports are completely separate=
d
> by default. When you add interfaces to a bridge, calls are made by th=
e
> bridge code into DSA to setup the switch to hardware bridge the
> interface. And if the switch driver does not support it, software
> bridging is used instead. Unless you know what is going on under the
> hood, you have no idea that eth0 and eth1 are used to carry packets t=
o
> the switch, and that the switch is bridging the interfaces. So it is
> linux concepts, with some hardware acceleration.

Thanks a lot.  This filled most of the blank spots. I should have done
some research into what dsa actually is before posting my question.

> Now back to you question. What is clearly hardware and needs to go
> into device tree is the mapping between switch ports and cpu
> ports. eth0 <--> port 6, eth1 <--> port 5.
>
> But i've reconsidered putting into device tree the load balancing of
> which slave ports, lan[1-4], wan, are attached to which master port,
> eth[01]. It should not be in DT. We want a sensible default, which i
> would say is what i had in DT, allocate them every other, but
> implement this in software. And allow the user to move slaves between
> masters, using a user space command. Something like:
>
> ip link set dev lan4 master eth0
>
> So if you wish, you can then have eth1 dedicated to WAN, and eth0 for
> lan[1-4]. Or any other combination.
>
> I would say implementing this command to move a slave between masters
> can come later, so long as we have a default which works for most
> people. Using every other is clearly between than only using one
> interface.

Yes, that sounds reasonable.

But I do still wonder if this model can be made flexible enough. How
about a switch having more CPU ports than external ports (just an
imaginary product - I don't know if anyone is crazy enough to make it)?
Or what if I'd like to dedicate CPU port eth0 to VLAN 13, while CPU por=
t
eth1 handles everything else?  With lan0 carrying an 802.1q trunk with
both VLAN 13 and more, i.e. a mix of packets for both eth0 and eth1?

Well, I'm being difficult now :) We can probably do fine without being
able to express those things.  And I realize that I'm a bit too late
into any discussion about modelling this.

Thanks again for taking the time to write such a good answer.



Bj=C3=B8rn
