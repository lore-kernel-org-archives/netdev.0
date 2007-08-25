From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET]: fix multicast list when cloning sockets
Date: Fri, 24 Aug 2007 22:16:54 -0700 (PDT)
Message-ID: <20070824.221654.03105704.davem@davemloft.net>
References: <20070730.190144.26963470.davem@davemloft.net>
	<39e6f6c70707302000l52926c9ar927fd550467ce3e3@mail.gmail.com>
	<20070731182940.GE4002@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dlstevens@us.ibm.com,
	acme@ghostprotocols.net
To: fleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46000
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751839AbXHYFQz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 01:16:55 -0400
In-Reply-To: <20070731182940.GE4002@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Flavio Leitner <fleitner@redhat.com>
Date: Tue, 31 Jul 2007 15:29:40 -0300

> On Tue, Jul 31, 2007 at 12:00:41AM -0300, Arnaldo Carvalho de Melo wrote:
> > On 7/30/07, David Miller <davem@davemloft.net> wrote:
> > > Allowing non-datagram sockets to end up with a non-NULL inet->mc_list
> > > in the first place is a bug.
> > >
> > > Multicast subscriptions cannot even be used with TCP and DCCP, which
> > > are the only two users of these connection oriented socket functions.
> > >
> > > The first thing that TCP and DCCP do, in fact, for input packet
> > > processing is drop the packet if it is not unicast.
> > >
> > > Therefore the fix really is for the inet layer to reject multicast
> > > subscription requests on sockets for which that absolutely does not
> > > make sense.  There is no reason these functions in
> > > inet_connection_sock.c should need to be mindful of multicast
> > > state. :-)
> > 
> > Well, we can add a BUG_ON there then 8)
> > 
> > Flavio, take a look at  do_ip_setsockopt in net/ipv4/ip_sockglue.c, in
> > the IP_{ADD,DROP}_MEMBERSHIP labels.
> > 
> > Don't forget IPV6 (net/ipv6/ipv6_sockglue.c)
> 
> yes, right. What about the one below?
> 
> [NET]: Fix IP_ADD/DROP_MEMBERSHIP to handle only connectionless
> 
> Fix IP[V6]_ADD_MEMBERSHIP and IP[V6]_DROP_MEMBERSHIP to
> return -EPROTO for connection oriented sockets.
> 
> Signed-off-by: Flavio Leitner <fleitner@redhat.com>

This looks great, patch applied.

Thanks!
