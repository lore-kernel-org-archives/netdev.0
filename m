From: David Lamparter <equinox@diac24.net>
Subject: Re: Bridging behavior apparently changed around the Fedora 14 time
Date: Tue, 12 Jul 2011 16:54:38 +0200
Message-ID: <20110712145438.GB909183@jupiter.n2.diac24.net>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com>
 <20110711130729.607d461e@nehalam.ftrdhcpuser.net>
 <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com>
 <20110711134938.5178797c@nehalam.ftrdhcpuser.net>
 <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com>
 <20110712000242.GA616804@jupiter.n2.diac24.net>
 <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com>
 <20110712033943.GB616804@jupiter.n2.diac24.net>
 <925A849792280C4E80C5461017A4B8A2A040FA@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	Lynn Hanson <LynnHanson@eaganhills.org>,
	Joe Whalen <JoeWhalen@eaganhills.org>
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:54652 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753100Ab1GLOyq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 10:54:46 -0400
Content-Disposition: inline
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A040FA@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2011 at 09:30:05AM -0500, Greg Scott wrote:
> Linux ehac-fw2011 2.6.35.6-48.fc14.i686.PAE #1 SMP Fri Oct 22 15:27:53
> UTC 2010 i686 i686 i386 GNU/Linux
> 
> It's just as Red Hat delivered it.

Whoa. And here I was almost ashamed of running 2.6.38. I'm sorry, but I
think you need to go bug RedHat.

Anyway, either someone else should have had your problem by now (so it
might be fixed) or I'd say there's something wrong with your setup
(maybe changed defaults) or RedHat messed up the kernel ;).

> > The VLAN saves you the SNAT on your clients traffic towards the NATed
> > services, because the traffic back from those NATed services goes
> > through the firewall, which will apply its conntrack entries.
> 
> I don't see it that way.  I have a couple of devices with public IP
> Addresses and most with "normal" private IP Addresses.  Those public IP
[snip]

You totally misunderstood me. I'm suggesting the separate VLAN for your
servers which have private IPs but which have services exposed to the
internet (and your clients) on public IPs through NAT.

Your H323 stuff is totally unrelated.

> > Also, what you're doing is a case of _layer 3_ routing of packets that
> > arrive at an interface - br0 - back out to the same interface - br0.
> 
> Yes, absolutely, when internal users need to access the NATed websites
> using public IP Addresses instead of their private IP Addresses.
> Classic router on a stick topology, but using DNAT and MASQUERADE.

Where's the log fire for your router on a stick? *SCNR*

> Let me try to describe it this way.  Forget about the reason I need a
> bridge.  I have a good reason this site is bridged and have now
> hopefully presented a reasonable case why I need one.  

Yes. Your problem seems to be between the private-IP clients in your
network and your private-IP servers if I understand correctly.

The bridge is most likely completely innocent and your "stick" NAT
setup just broke down due to some changed default I'd guess.

> And it broke with Fedora 14.

> > Where is your private IP that's facing towards the clients?
> 
> I don't know what this question means.  The setup is a traditional
> Public<-->firewall<-->private topology, as the ASCII art I posted
> earlier shows.  But some of the stuff on the private side needs public
> IP Addresses, so the firewall is a bridge plus a router, not just a
> router.  

Yes. And because it is a router, it as an IP from the private subnet
your clients are in. My question was: what device is that IP on?

> > So it works when you switch the bridge members into PROMISC? (not the
> > bridge itself!)
> 
> No, the br0 bridge device itself.  After a bunch of troubleshooting,
> below is literally the single one and only change I needed to make this
> work again.

This makes me think yet more that the bridge code is innocent.

> I don't think I should need to do this by hand and I never needed it
> before.  That's why it took me weeks and plenty of help with the
> Netfilter folks to find it.  Something apparently changed with bridging.

No. You're jumping to conclusions. You're affecting the "top" bridge
device's promiscuity. I would say that the effect you're seeing is in
the IP stack above it, caused by it now promiscuously handling packets
that are dropped otherwise.

Setups like yours need a lot of caution regarding ICMP redirect /
shared_media / ARP settings. Please check those.


-David


P.S.: you blissfully ignored my "ip neigh add proxy 1.2.3.4" note :)
