From: "George B." <georgeb@gmail.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount
	of outgoing connections (unable to bind ... )
Date: Wed, 21 Apr 2010 09:52:10 -0700
Message-ID: <u2pb65cae941004210952x1e23957cm1b04ef892d7e8d0a@mail.gmail.com>
References: <4BCE33B9.8050101@candelatech.com>
	 <y2p46c8cb3e1004201635s8f84672dq90d3115dca04a1ed@mail.gmail.com>
	 <4BCE3D8D.3030500@candelatech.com>
	 <1271808314.7895.614.camel@edumazet-laptop>
	 <20100421003022.GA3107@ioremap.net>
	 <1271828799.7895.1287.camel@edumazet-laptop>
	 <20100421082559.GA32475@ioremap.net>
	 <1271840535.7895.1612.camel@edumazet-laptop>
	 <20100421095812.GA14778@ioremap.net>
	 <1271849253.7895.1929.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f186.google.com ([209.85.222.186]:39020 "EHLO
	mail-pz0-f186.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035Ab0DUQwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Apr 2010 12:52:11 -0400
Received: by pzk16 with SMTP id 16so3720470pzk.22
        for <netdev@vger.kernel.org>; Wed, 21 Apr 2010 09:52:11 -0700 (PDT)
In-Reply-To: <1271849253.7895.1929.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 21, 2010 at 4:27 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> Here is the patch I use now and my test application is now able to open
> and connect 1000000 sockets (ulimit -n 1000000)

I believe we hit this very yesterday in our test lab.  We had a stress
test running of one of our applications with about a dozen instances
of it running on the box.  Suddenly dns requests began failing with
the complaint that it couldn't make a request out because there were
no sockets.

root@champagne:/proc/sys/net/ipv4> host gh
host: isc_socket_bind: address in use

Netstat showed 61580 total sockets (UDP and TCP) on the address being
used by the above dns request. (local port range 1025 65535).  That
dns request should not have been failing.

I noticed that the number of UDP sockets was close to the maximum
allowed by the port range, but they were across different IP
addresses, no one IP address had too many and there should have been
available ports on all IP addresses.

Further, the number of udp sockets in use seemed to hit the wall at a
little above 64,000 and I never got above that number.

If that is the normal behavior of the kernel, it could be a big
problem for scaling the application.
