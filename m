From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] ipv6: addrconf: fix mcast route for GRE devices
Date: Fri, 01 Aug 2014 00:05:25 +0200
Message-ID: <1406844325.13603.16.camel@localhost>
References: <20140731201926.GA754314@jupiter.n2.diac24.net>
	 <1406840034-140848-1-git-send-email-equinox@diac24.net>
	 <1406840034-140848-2-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:49572 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750906AbaGaWFb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 18:05:31 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway1.nyi.internal (Postfix) with ESMTP id 7E19D229AD
	for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 18:05:27 -0400 (EDT)
In-Reply-To: <1406840034-140848-2-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Next time please also specify which tree you want this patch applied to.
We use [PATCH net] for patches which should go into the rc2+ and [PATCH
net-next] for rc1. Thanks!

On Do, 2014-07-31 at 22:53 +0200, David Lamparter wrote:
> GRE devices, for some reason, were coming up with an autoconfigured
> address, but no ff00::/8 route in the local table.  This breaks any kind
> of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
> works at all because there is little need for ND on PtP devices.
> 
> Adding any other IPv6 address on the device from userspace would rectify
> this issue through inet6_addr_add()/addrconf_add_dev() - and would leave
> the route around even if the address was later removed.  (This is
> probably why this issue was not discovered earlier.  AFAICS it has been
> there from the beginning, e.g. aee80b5 "generate link local address for
> GRE tunnel")
> 
> (Note: multicast is supported on GRE devices of all kinds, including PtP
> GRE, P-t-Mcast GRE and NBMA-GRE.)
> 
> Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
> Signed-off-by: David Lamparter <equinox@diac24.net>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Dave, it would make sense to queue this up for net and stable (or only
net-next if there is no merge before the release).

Thanks,
Hannes
