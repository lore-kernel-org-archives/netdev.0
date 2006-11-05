From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC, PATCH] Purging local routes on NETDEV_DOWN event
Date: Sun, 5 Nov 2006 16:56:54 +0100
Message-ID: <20061105155654.GL12964@postel.suug.ch>
References: <589170c50611050600r3d4bfaafvb2acd513ae695a96@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:44422 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S932712AbWKEP4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Nov 2006 10:56:33 -0500
To: Boris Sukholitko <bobatonhu@gmail.com>
Content-Disposition: inline
In-Reply-To: <589170c50611050600r3d4bfaafvb2acd513ae695a96@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Boris Sukholitko <bobatonhu@gmail.com> 2006-11-05 16:00
> We've noticed that when taking network interface down the local route
> for its address is preserved. The following console session
> illustrates it:
> 
> # ip addr add 5.5.5.5 dev eth4
> # ip route list table all | grep eth4
> local 5.5.5.5 dev eth4  table 255  vrf 0  proto kernel  scope host  src 
> 5.5.5.5
> # ip link set eth4 down
> local 5.5.5.5 dev eth4  table 255  vrf 0  proto kernel  scope host  src 
> 5.5.5.5

This example is incomplete and misleading. The local route is managed
completely synchroneous with the address itself. See the NETDEV_UP/
NETDEV_DOWN handlers of inetaddr events:

	case NETDEV_UP:
			fib_add_ifaddr(ifa);

	case NETDEV_DOWN:
			fib_del_ifaddr(ifa);

The broadcast routes are added/removed when the interface goes up
and down. The fib_addr_ifaddr() in the NETDEV_UP() handler only
exists to add broadcast routes for local address which have been added
while the interface was down.
