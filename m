From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: ipv6: oops in datagram.c line 260
Date: Wed, 7 Jan 2015 13:26:07 +0100
Message-ID: <20150107122607.GC13046@secunet.com>
References: <5487DD65.60800@gtsys.com.hk>
 <549AC2B4.8070203@gtsys.com.hk>
 <1420560073.32369.60.camel@redhat.com>
 <20150107072254.GA13046@secunet.com>
 <1420627502.26870.38.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chris Ruehl <chris.ruehl@gtsys.com.hk>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53286 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752038AbbAGM0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 07:26:11 -0500
Content-Disposition: inline
In-Reply-To: <1420627502.26870.38.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 07, 2015 at 11:45:02AM +0100, Hannes Frederic Sowa wrote:
> On Mi, 2015-01-07 at 08:22 +0100, Steffen Klassert wrote:
> > On Tue, Jan 06, 2015 at 05:01:13PM +0100, Hannes Frederic Sowa wrote:
> > > 
> > > xfrm6_output_finish unconditionally resets skb->protocol so we try to
> > > dispatch to the IPv6 handler, even though tcp just sends an IPv4 packet.
> > 
> > Maybe we better dispatch based on sk->sk_family, this should give
> > always the right address family of the socket.
> 
> The original problem was dealing with IPv4/v6 mapped traffic. Processing
> local errors from unconnected UDP sockets which are emitting both IPv4
> and IPv6 frames won't play nicely with sk->sk_family I fear.

Good point, unfortunately it is not so easy to fix as I thought.
