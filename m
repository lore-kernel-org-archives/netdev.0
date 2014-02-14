From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Does ICMP_FRAG_NEEDED automatically update the routing cache?
Date: Fri, 14 Feb 2014 16:03:28 +0100
Message-ID: <20140214150328.GB27343@order.stressinduktion.org>
References: <20140214144412.GA27343@order.stressinduktion.org> <26474.1392388608@warthog.procyon.org.uk> <26769.1392390042@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:55033 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbaBNPD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 10:03:29 -0500
Content-Disposition: inline
In-Reply-To: <26769.1392390042@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 14, 2014 at 03:00:42PM +0000, David Howells wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> 
> > On Fri, Feb 14, 2014 at 02:36:48PM +0000, David Howells wrote:
> > > Am I reading the ipv4 code right?  If a UDP packet we send results in an
> > > ICMP_FRAG_NEEDED packet being received, the cached routing information for
> > > the peer will automatically be updated by __udp4_lib_err()?
> > 
> > A next hop exception will be generated (or reused) which stores the path
> > mtu towards that target, yes (there is no more routing cache).
> > 
> > Prior to that a validation check happens if the socket really exists (this is
> > e.g. needed to identify the namespace or routing table the update should occur
> > on).
> 
> Sounds good.  Does this work even if the socket is not connected (ie. the UDP
> packets are being routed by the address fields in struct msghdr)?

Yes, but connected sockets are checked prior to unconnected sockets, so the
most specific one wins.

For unconnected ones only the local ip/port is checked because kernel
does not know the past destination addresses.

Greetings,

  Hannes
