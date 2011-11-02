From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Subnet router anycast for FE80/10 ?
Date: Wed, 2 Nov 2011 10:52:57 -0700
Message-ID: <OFCBEF5360.F10E7D75-ON8825793C.00613C5C-8825793C.00623B8A@us.ibm.com>
References: <4EAF0391.80907@collax.com> <20111102153809.GH297914@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andreas Hofmeister <andi@collax.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:38136 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044Ab1KBRxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 13:53:11 -0400
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 2 Nov 2011 11:53:09 -0600
In-Reply-To: <20111102153809.GH297914@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 11/02/2011 08:38:09 AM:

> From: David Lamparter <equinox@diac24.net>

> > This address seems not to be explicitly mentioned in any RFC, but RFC 
> > 4291 says "All routers are required to support the Subnet-Router 
anycast 
> > addresses for the subnets to which they have interfaces."
> 
> That this directly contradicts RFC 2526 which specifies the
> subnet-router anycast address to be either ::ffff:ffff:ffff:ff80 or
> ::fcff:ffff:ffff:ff80 depending on the phase of the moon (well,
> interface type actually, but same thing. Also, the /64 <> /10
> distinction would matter here.)

        The subnet-router anycast address is defined in section 2.6.1 of 
RFC 4291
to be "all 0's" for the prefix. The definition above is for reserved 
anycast
addresses. RFC 2526 says "IPv6 defines a required Subnet-Router anycast 
address [3]
for all routers within a subnet prefix, and allows additional anycast 
addresses to
be taken from the unicast address space. This document defines an 
additional set
of reserved anycast addresses...".

> 
> ... it's actually fairly hard to implement this at all. The idea of
> "Anycast" is that even if you have 1000 routers, only one router will
> receive the packet. The network is supposed to magically take care of
> that, but in reality this only works with Layer 3/IPv6

        The host implementation is very straightforward. Not every host
on a segment has to use the *same* host for an anycast address (it's
kind of the point that it won't, in fact). A host simply needs to
do a solicitation for the anycast address and keep the first one that
answers (by definition, the "closest").

                                                                +-DLS
