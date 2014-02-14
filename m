From: David Howells <dhowells@redhat.com>
Subject: Re: Does ICMP_FRAG_NEEDED automatically update the routing cache?
Date: Fri, 14 Feb 2014 15:00:42 +0000
Message-ID: <26769.1392390042@warthog.procyon.org.uk>
References: <20140214144412.GA27343@order.stressinduktion.org> <26474.1392388608@warthog.procyon.org.uk>
Cc: dhowells@redhat.com, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65347 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751323AbaBNPAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 10:00:48 -0500
In-Reply-To: <20140214144412.GA27343@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Fri, Feb 14, 2014 at 02:36:48PM +0000, David Howells wrote:
> > Am I reading the ipv4 code right?  If a UDP packet we send results in an
> > ICMP_FRAG_NEEDED packet being received, the cached routing information for
> > the peer will automatically be updated by __udp4_lib_err()?
> 
> A next hop exception will be generated (or reused) which stores the path
> mtu towards that target, yes (there is no more routing cache).
> 
> Prior to that a validation check happens if the socket really exists (this is
> e.g. needed to identify the namespace or routing table the update should occur
> on).

Sounds good.  Does this work even if the socket is not connected (ie. the UDP
packets are being routed by the address fields in struct msghdr)?

David
