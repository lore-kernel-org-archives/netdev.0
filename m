From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv4: sysctl to block responding on down
 interface
Date: Mon, 28 Jun 2010 20:01:05 -0700 (PDT)
Message-ID: <20100628.200105.115936568.davem@davemloft.net>
References: <OF0640B724.BFF8DEB7-ONC1257750.00728ECF-C1257750.00742EFA@transmode.se>
	<20100628.145744.39186500.davem@davemloft.net>
	<OFA9AE9CDE.69224382-ONC1257750.007F44EA-C1257750.0081210A@transmode.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: joakim.tjernlund@transmode.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53713
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751501Ab0F2DAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 23:00:52 -0400
In-Reply-To: <OFA9AE9CDE.69224382-ONC1257750.007F44EA-C1257750.0081210A@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Date: Tue, 29 Jun 2010 01:30:26 +0200

> This is an strict interpretation of the weak host model and does not
> answer my questions. Mind to elaborate why such a strict view and
> what is gained by answering on an IP address which has been "downed"?

IP addresses are never "downed" just as your default route is not
"downed" when you take down an interface.

Rather, hosts are configured with an IP address and when they are so
configured they respond to it and can generate local application
sourced packets with that IP address as a source.

And what this means is that even in situations where hosts are
slightly mis-configured communication between them can still be
possible.  That's the goal of the weak host model, to get a host
respond to IP datagrams in every situation where such an act is
plausible.

All of the design decisions we've made in the networking in this area
are meant to increase the likelyhood of successful communication
between two hosts.

And in the 10+ years this behavior has existed, I know for sure that
people have ended up with a working networking because of the way we
do things.

So from that perspective it doesn't matter one iota what you or any
other particular entity wish things to be, since 10+ years of having
this behavior is ingrained enough that changing it is guarenteed to
break someone's setup so we absolutely can't do it.

This topic comes up at least once every few months, therefore someone
should post a FAQ somewhere because it's tiring to explain over and
over again why this is a good design decision and why the default
behavior is never going to change.

The RFCs allow both models equally, and just because many other
system does things the other way doesn't make it any better or more
valid than what Linux is doing.
