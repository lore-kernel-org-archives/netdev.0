From: David Lamparter <equinox@diac24.net>
Subject: Re: Bridging behavior apparently changed around the Fedora 14 time
Date: Tue, 12 Jul 2011 05:39:44 +0200
Message-ID: <20110712033943.GB616804@jupiter.n2.diac24.net>
References: <925A849792280C4E80C5461017A4B8A2A040F0@mail733.InfraSupportEtc.com>
 <20110711130729.607d461e@nehalam.ftrdhcpuser.net>
 <925A849792280C4E80C5461017A4B8A2A040F3@mail733.InfraSupportEtc.com>
 <20110711134938.5178797c@nehalam.ftrdhcpuser.net>
 <925A849792280C4E80C5461017A4B8A2A040F6@mail733.InfraSupportEtc.com>
 <20110712000242.GA616804@jupiter.n2.diac24.net>
 <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Lynn Hanson <LynnHanson@eaganhills.org>,
	Joe Whalen <JoeWhalen@eaganhills.org>
To: Greg Scott <GregScott@Infrasupport.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:57017 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754780Ab1GLDjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jul 2011 23:39:52 -0400
Content-Disposition: inline
In-Reply-To: <925A849792280C4E80C5461017A4B8A2A040F8@mail733.InfraSupportEtc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi --

First of all, I still can't find your kernel version in any of your
mails. Can you please repeat the uname -a output of the affected box?

Anyway,

On Mon, Jul 11, 2011 at 09:38:51PM -0500, Greg Scott wrote:
> > Why not proxy ARP?
> 
> I used to use proxy ARP until I got burned really badly with what proxy
> ARP really does - the NIC answers ARP requests (in proxy) for everyone
> and anyone that asks with its own MAC address.  Think about that - proxy
> ARP impersonates everyone and anyone on the LAN to which it's connected.

Yes. That's why you use
	ip neighbor add proxy 1.2.3.4 dev eth0
(for that to work, you need forwarding on, and the route for the host
must point to a different outbound device)

I agree that the proxy_arp /proc knob is pure evil. In my opinion it
should be removed in favour of "ip neighbor add proxy".

> > Why not use a VLAN?
> 
> Because I really don't need one.  Plus it doesn't matter anyway - the
> firewall can act as a router on a stick to go between my H.323 devices
> and private IP servers.  With or without VLANs makes no difference in
> this case.  

The VLAN saves you the SNAT on your clients traffic towards the NATed
services, because the traffic back from those NATed services goes
through the firewall, which will apply its conntrack entries.

Also, what you're doing is a case of _layer 3_ routing of packets that
arrive at an interface - br0 - back out to the same interface - br0. I'm
not excluding the possibility that the bridge code is broken, but my
nose tells me that your SNAT-DNAT setup is more likely to have gotten
broken.

Either way I still don't understand your setup. Are you using ebtables?
Where is your private IP that's facing towards the clients? Is there a
separate third DMZ network? What is $DMZ_IFACE?

(Posting your setup script is a noble thought completeness-wise, but
tbfh it's unreadable and maybe even the wrong parts. Please boil it
down to a few lines and please include the client direction...)

> - and now I think the problem is, bridging is supposed to turn on
> PROMISC mode and it didn't.  I had to do it by hand myself.

So it works when you switch the bridge members into PROMISC? (not the
bridge itself!)

> What I don't know yet is, is this a Fedora bug or a stock kernel bug?
> Is anyone from Red Hat following this email list?

I only know I haven't seen it anywhere, but my bridges are getting fewer
and fewer...


-David

