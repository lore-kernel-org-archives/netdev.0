From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Tue, 5 Nov 2013 22:11:58 +0100
Message-ID: <20131105211158.GL8832@order.stressinduktion.org>
References: <20131028.204306.2213130677400093266.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com> <20131029124010.GA15762@order.stressinduktion.org> <52792499.3030201@6wind.com> <AE90C24D6B3A694183C094C60CF0A2F6026B73E2@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nicolas.dichtel@6wind.com, David Miller <davem@davemloft.net>,
	jiri@resnulli.us, vyasevich@gmail.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51683 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348Ab3KEVL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 16:11:59 -0500
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73E2@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 05, 2013 at 05:12:46PM -0000, David Laight wrote:
> > From: Nicolas Dichtel [mailto:nicolas.dichtel@6wind.com]
> ...
> > If I remember well, another problem is to be able to send these packets with
> > 0.0.0.0 when another IP address is available on the system:
> > 
> > RFC2131
> > 4.1 Constructing and sending DHCP messages
> > ...
> >     DHCP messages broadcast by a client prior to that client obtaining
> >     its IP address must have the source address field in the IP header
> >     set to 0.
> > 
> > We made a patch (never proposed upstream) to add a socket option to keep
> > this 0.0.0.0 address.
> > If people are interested, I can try to port it on net-next.
> 
> Really, what dhcp does before the interface has an address doesn't
> really matter - using bpf isn't a problem.
> 
> What it needs to do is switch to using a normal socket for the renewals.
> 
> Maybe I'll try asking Roy about it on the NetBSD lists.

I would do the full switch to UDP sockets. It is much easier to accomplish
in the isc-dhcp codebase. It is e.g. already implemented and used e.g. by
Solaris. I would just have to wire up Nicolas INADDR_ANY source patch.

By the way:
Although dhclient uses an AF_PACKET socket, it never does request
additional multicast addresses or promisc mode. So the only overhead is
that we have to run the socket filter on each incoming packet.

Greetings,

  Hannes
