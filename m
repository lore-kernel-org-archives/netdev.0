From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC alternate] ipv6: addrconf: clean up device type handling
Date: Wed, 30 Jul 2014 18:12:35 +0200
Message-ID: <1406736755.6757.15.camel@localhost>
References: <20140730153503.GJ801478@jupiter.n2.diac24.net>
	 <1406735921-122830-1-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jiri Pirko <jiri@resnulli.us>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:46503 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754350AbaG3QMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 12:12:38 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by gateway1.nyi.internal (Postfix) with ESMTP id A25EB23039
	for <netdev@vger.kernel.org>; Wed, 30 Jul 2014 12:12:37 -0400 (EDT)
In-Reply-To: <1406735921-122830-1-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mi, 2014-07-30 at 17:58 +0200, David Lamparter wrote:
> This realigns addrconf support for the various lower-layer device types,
> and removes a little bit of duplicate code.
> 
> For GRE devices, this includes a semantic change in that there is now a
> ff00::/8 route installed on address autogeneration.  This was previously
> missing and broke any kind of IPv6 multicast - unless another address
> was configured from userspace (which then added the missing ff00::/8).
> 
> Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
> Signed-off-by: David Lamparter <equinox@diac24.net>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Jiri Pirko <jiri@resnulli.us>
> ---
> 
> This is an alternate version, yanking the switch() down and removing
> dev_config/gre_config duplication.  I have no idea what rationale is behind
> prefix_route - the result is a fe80::/64 route, but no address, which is not a
> functioning configuration.  Jiri, you touched this just a few weeks ago, can
> you comment?  (The "XXX: why is GRE special?")

Sure, it is valid. You can still use global addresses to talk to link
local addresses on the same link, even from another interface.

I prefer this patch.

Thanks,
Hannes
