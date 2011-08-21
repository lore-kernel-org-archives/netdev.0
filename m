From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: Bridge stays down until a port is added
Date: Sun, 21 Aug 2011 14:13:05 +0200
Message-ID: <20110821121305.GA22232@torres.zugschlus.de>
References: <20110811070659.GA21307@torres.zugschlus.de>
 <20110811081706.7307e8b2@nehalam.ftrdhcpuser.net>
 <20110811205429.GB21307@torres.zugschlus.de>
 <alpine.DEB.2.02.1108121418090.11637@aurora>
 <20110820094712.GC21307@torres.zugschlus.de>
 <20110820093059.75c37a1f@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, Sven-Haegar Koch <haegar@sdinet.de>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:45650 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754197Ab1HUMNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 08:13:08 -0400
Content-Disposition: inline
In-Reply-To: <20110820093059.75c37a1f@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Aug 20, 2011 at 09:30:59AM -0700, Stephen Hemminger wrote:
> The problem is that IPv6 Duplicate Address Detection needs to
> work. This is not a simple problem.  If the bridge asserted
> carrier with no ports then:
> 
> 1. IPv6 address assigned and IPv6 decides it is okay.
> 2. Port added later
> 3. Another system has the same address.
> *broke*

Same situation when a system-to-system-link is added after bringing up
an interface. I agree that the issue is not an issue if a real switch
is being used.

> If you want to avoid DAD, then you can configure disable DAD
> by setting /proc/sys/net/ipv6/conf/br0/accept_dad to 0

I'd like to avoid that.

2001:db8::1

Would it acceptable (and clean!) to have:

eth0: 2001:db8:1::100/64 default gw to the internet is 2001:db8:1::1
lo: 127.0.0.1/8, ::1/128, 2001:db8:2::100/64
br0: 2001:db8:2::1/64 (being default gw for the VMs connected to br0,
routing 2001:db8:2::/64 to the Internet)

Note 2001:db8:2::/64 being used both on lo and br0, with 2001:db8:2::100 meant
to be reachable from the Internet even if no VM is already up. my
hostname will be A-Recorded to 2001:db8:2::100 with proper reverse
DNS. The background for doing so is that I cannot control the reverse
DNS for the IP addresses inside 200a:db8:1::/64 in a lot of my setups
(for example, if my IPv6 comes in via Sixxs).

Is this going to work in a clean way?

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
