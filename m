From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: Subnet router anycast for FE80/10 ?
Date: Wed, 2 Nov 2011 16:27:43 -0700
Message-ID: <OF9628F915.F31E9CFE-ON8825793C.007D063C-8825793C.0080E1AC@us.ibm.com>
References: <4EAF0391.80907@collax.com> <20111102153809.GH297914@jupiter.n2.diac24.net> <OFCBEF5360.F10E7D75-ON8825793C.00613C5C-8825793C.00623B8A@us.ibm.com> <20111102215359.GJ297914@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Andreas Hofmeister <andi@collax.com>,
	David Lamparter <equinox@diac24.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:58684 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752052Ab1KBX2m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 19:28:42 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Wed, 2 Nov 2011 17:28:41 -0600
In-Reply-To: <20111102215359.GJ297914@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netdev-owner@vger.kernel.org wrote on 11/02/2011 02:53:59 PM:

> From: David Lamparter <equinox@diac24.net>

> Going back to Andreas's original question about Subnet-Router Anycast
> for fe80::/64 (or /10), RFC 4291 says
>    +------------------------------------------------+----------------+
>    |                   subnet prefix                | 00000000000000 |
>    +------------------------------------------------+----------------+
> 
>    The "subnet prefix" in an anycast address is the prefix that
>    identifies a specific link.
> 
> But fe80::/64 does not identify a specific link, as it is link-local and
> would specify all links but not one specifically. So, fe80:: is not a
> Subnet-Router anycast address, I'd say.

fe80:: is in fact a subnet-router anycast address because it's a valid
prefix with all-0's host part. Adding it, as linux does,  simply means
a host can use "fe80::" to get an answer from any router on a particular
link. That might be useful, e.g., if a host wants routing protocol 
information
from a directly attached router.

It isn't unique on a host, but all LL addresses require a scope_id to
identify an interface, anyway, so there is no ambiguity. Any multihomed
v6 host will have multiple fe80/10 routes -- one for each interface--
too, used for receiving packets. Those routes and those anycast addresses
only matter for input processing, as is true for all LL addresses.

So, there's no particular reason I see to treat LL as a special case and
exclude them. I haven't seen any RFC wording that forbids it, though the
implementation predates RFC4291.

You certainly don't have to use them in any application if you don't like 
it. :-)

                                                                +-DLS
