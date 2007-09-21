From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [PATCH 3/7] CAN: Add raw protocol
Date: 21 Sep 2007 23:05:25 +0200
Message-ID: <ygfvea3u3u2.fsf@janus.isnogud.escape.de>
References: <20070920184323.3795.0@janus.isnogud.escape.de>
	<20070920184533.3795.3@janus.isnogud.escape.de>
	<46F3BDC1.2020200@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Oliver Hartkopp <oliver@hartkopp.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:42553 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755238AbXIUVKv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 17:10:51 -0400
In-Reply-To: <46F3BDC1.2020200@trash.net>; from Patrick McHardy on Fri, 21 Sep 2007 14:49:05 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> Urs Thuermann wrote:
> > +config CAN_RAW_USER
> > +	bool "Allow non-root users to access Raw CAN Protocol sockets"
> 
> 
> If you plan to remove this option, it should happen before merging
> since it affects userspace visible behaviour.

We have discussed this and have come to the conclusion that we should
remove permission checks completely, i.e. any user can open any CAN
socket (raw, bcm, or whatever will be implemented in the future).
This is because CAN is a pure broadcast network with no addresses.
CAN frames can't be directed to only one machine or a group or to only
one process (say one port).  There is no communication between only
two (or some number) of stations which must be protected from other
stations.

On the other hand, requiring a process to have CAP_NET_RAW to open a
CAN socket would mean that such process would also be able to sniff on
your ethernet or WLAN interfaces, which one probably wouldn't want.

We have added that check when we still allowed the CAN raw socket to
bind to any interface and we didn't want an unprivileged process to be
able to read all e.g. TCP/IP traffic.  Now binding is restricted to
ARPHRD_CAN interfaces.  But even without this restriction the check is
not necessary, since all CAN sockets can only receive and send
ETH_P_CAN packets.  So even if there would be an encapsulation of CAN
frames over ethernet or some other type of network, a normal user
process opening a CAN socket would only be able to read/write CAN
traffic, which should be OK without any special capability.

So what do you think about this?

urs
