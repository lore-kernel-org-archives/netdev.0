From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Bridge stays down until a port is added
Date: Mon, 22 Aug 2011 08:57:30 -0700
Message-ID: <20110822085730.69d56034@nehalam.ftrdhcpuser.net>
References: <20110811070659.GA21307@torres.zugschlus.de>
	<20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
	<20110811205429.GB21307@torres.zugschlus.de>
	<alpine.DEB.2.02.1108121418090.11637@aurora>
	<20110820094712.GC21307@torres.zugschlus.de>
	<20110820093059.75c37a1f@nehalam.ftrdhcpuser.net>
	<20110821121305.GA22232@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sven-Haegar Koch <haegar@sdinet.de>
To: Marc Haber <mh+netdev@zugschlus.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40412 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751294Ab1HVP5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Aug 2011 11:57:19 -0400
In-Reply-To: <20110821121305.GA22232@torres.zugschlus.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 21 Aug 2011 14:13:05 +0200
Marc Haber <mh+netdev@zugschlus.de> wrote:

> On Sat, Aug 20, 2011 at 09:30:59AM -0700, Stephen Hemminger wrote:
> > The problem is that IPv6 Duplicate Address Detection needs to
> > work. This is not a simple problem.  If the bridge asserted
> > carrier with no ports then:
> > 
> > 1. IPv6 address assigned and IPv6 decides it is okay.
> > 2. Port added later
> > 3. Another system has the same address.
> > *broke*
> 
> Same situation when a system-to-system-link is added after bringing up
> an interface. I agree that the issue is not an issue if a real switch
> is being used.
> 
> > If you want to avoid DAD, then you can configure disable DAD
> > by setting /proc/sys/net/ipv6/conf/br0/accept_dad to 0
> 
> I'd like to avoid that.
> 
> 2001:db8::1
> 
> Would it acceptable (and clean!) to have:
> 
> eth0: 2001:db8:1::100/64 default gw to the internet is 2001:db8:1::1
> lo: 127.0.0.1/8, ::1/128, 2001:db8:2::100/64
> br0: 2001:db8:2::1/64 (being default gw for the VMs connected to br0,
> routing 2001:db8:2::/64 to the Internet)
> 
> Note 2001:db8:2::/64 being used both on lo and br0, with 2001:db8:2::100 meant
> to be reachable from the Internet even if no VM is already up. my
> hostname will be A-Recorded to 2001:db8:2::100 with proper reverse
> DNS. The background for doing so is that I cannot control the reverse
> DNS for the IP addresses inside 200a:db8:1::/64 in a lot of my setups
> (for example, if my IPv6 comes in via Sixxs).
>

No, DAD config is per interface and addrconf doesn't know anything
about your topology.
