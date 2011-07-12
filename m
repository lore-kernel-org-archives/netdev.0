From: David Lamparter <equinox@diac24.net>
Subject: Re: bonding and IPv6 "doesn't work"?
Date: Tue, 12 Jul 2011 18:36:02 +0200
Message-ID: <20110712163602.GE909183@jupiter.n2.diac24.net>
References: <4E1C70D5.6060806@wpkg.org>
 <20110712161455.GD909183@jupiter.n2.diac24.net>
 <4E1C756C.2010700@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:47656 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753738Ab1GLQgJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 12:36:09 -0400
Content-Disposition: inline
In-Reply-To: <4E1C756C.2010700@wpkg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2011 at 06:25:16PM +0200, Tomasz Chmielewski wrote:
> It's a virtual machine.
> So, a bridge of the host.

Just a bridge? No bonding device? You need to set it up on both sides...

> >> bond0: IPv6 duplicate address 2a01:4f8:120:14c4::1247 detected!
> > [...]
> >> However if I start bonding with just one interface, add IPv6 address to
> >> it, then use ifenslave to add a second interface, I'm able to reach the
> >> hosts in the internet.
> >
> > Yeah, when you add the IPv6 address, IPv6 ND does its job and announces
> > your presence/does DAD.
> 
> Shouldn't this disable DAD? Or am I confusing something here?
> 
> net.ipv6.conf.eth0.accept_dad = 0
> net.ipv6.conf.eth1.accept_dad = 0

Yes, you would need to set
  net.ipv6.conf.bond0.accept_dad = 0
because eth0 and eth1 are not actually participating in the IPv6 stack.
(I'd recommend setting disable_ipv6=1 for them too)

However, you should not be getting that DAD error at all, it indicates
that broadcast/multicast packets that go out on eth0 are looped back on
eth1 (and vice versa). Your bonding setups on the host and the VM don't
seem to match each other.


-David
