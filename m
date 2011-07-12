From: David Lamparter <equinox@diac24.net>
Subject: Re: bonding and IPv6 "doesn't work"?
Date: Tue, 12 Jul 2011 18:14:56 +0200
Message-ID: <20110712161455.GD909183@jupiter.n2.diac24.net>
References: <4E1C70D5.6060806@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:52888 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753972Ab1GLQPD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2011 12:15:03 -0400
Content-Disposition: inline
In-Reply-To: <4E1C70D5.6060806@wpkg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2011 at 06:05:41PM +0200, Tomasz Chmielewski wrote:
> I make a bond0 of two interfaces, eth0 and eth1.

What kind of device do you have on the other side of those links?

> bond0: IPv6 duplicate address 2a01:4f8:120:14c4::1247 detected!
[...]
> However if I start bonding with just one interface, add IPv6 address to 
> it, then use ifenslave to add a second interface, I'm able to reach the 
> hosts in the internet.

Yeah, when you add the IPv6 address, IPv6 ND does its job and announces
your presence/does DAD. Your bonding peer is probably looping those
packets back on the other link, most likely because...

> Bonding Mode: load balancing (round-robin)

... most likely because you maybe have a switch on the other side, and
that switch expects you to do 802.3ad?

Just guessing,


-David
