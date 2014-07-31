From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2] ipv6: addrconf: fix mcast route for GRE devices
Date: Thu, 31 Jul 2014 21:37:34 +0200
Message-ID: <1406835454.13603.1.camel@localhost>
References: <20140730153503.GJ801478@jupiter.n2.diac24.net>
	 <1406734797-122248-1-git-send-email-equinox@diac24.net>
	 <20140731.120652.225147288366144806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: equinox@diac24.net, netdev@vger.kernel.org,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:43425 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750709AbaGaThm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 15:37:42 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by gateway1.nyi.internal (Postfix) with ESMTP id 1120722FA1
	for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 15:37:37 -0400 (EDT)
In-Reply-To: <20140731.120652.225147288366144806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Do, 2014-07-31 at 12:06 -0700, David Miller wrote:
> From: David Lamparter <equinox@diac24.net>
> Date: Wed, 30 Jul 2014 17:39:57 +0200
> 
> > GRE devices, for some reason, were coming up with an autoconfigured
> > address, but no ff00::/8 route in the local table.  This breaks any kind
> > of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
> > works at all because there is little need for ND on PtP devices.
> > 
> > Adding any other IPv6 address on the device from userspace would rectify
> > this issue through inet6_addr_add()/addrconf_add_dev() - and would leave
> > the route around even if the address was later removed.  (This is
> > probably why this issue was not discovered earlier.  AFAICS it has been
> > there from the beginning, e.g. aee80b5 "generate link local address for
> > GRE tunnel")
> > 
> > (Note: multicast is supported on GRE devices of all kinds, including PtP
> > GRE, P-t-Mcast GRE and NBMA-GRE.)
> > 
> > Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
> > Signed-off-by: David Lamparter <equinox@diac24.net>
> > Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> 
> Hannes, are you OK with this version?  Please ACK if so.

The alternate version does provide the same semantic change and makes
the code more readable. Both changes are technically correct, I acked
the alternate version already.

Thank you,
Hannes
