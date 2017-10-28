From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH v7 net-next 00/13] gtp: Additional feature support - Part
 I
Date: Sat, 28 Oct 2017 10:09:40 +0200
Message-ID: <20171028080940.dvtzn2cg2rrk6f6t@nataraja>
References: <20171028000937.2631-1-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pablo@netfilter.org, aschultz@tpip.net,
        netdev@vger.kernel.org, rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:53424 "EHLO
        ganesha.gnumonks.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdJ1IKJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 04:10:09 -0400
Content-Disposition: inline
In-Reply-To: <20171028000937.2631-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Tom,

my apologies for only getting back to reviews now, after return from
holidays I was too overloaded with plenty of other tasks.

On Fri, Oct 27, 2017 at 05:09:24PM -0700, Tom Herbert wrote:
>   - Experimental IPv6 support

As far as I can tell, my previous comments/concerns regarding an IPv6
support that is in clear violation of how it is specified is not
acceptable to me, sorry.

The question is - as illustrated quite verbosely before - not one
of missing certain bits, but it is simply *different* from what
the protocol specification says.

This makes absolutely no sense to me.  All it will do, is it will raise
the impression that IPv6 is supported in a spec-compliant way.
Furthermore, it will mean that once somebody does convert this into
proper IPv6 support later, they will break the existing use cases of
the non-compliant implementation that you're adding in this patch
series.

To me, I simply don't understand how that makes any sense. There are no
known users of GTP outside of 3GPP networks, and particularly none of a
different GTP flavour than the one specified in 3GPP.  If there are, I
would want to hear of it.  And if there really are, I would strongly
recommend them to use some other tunneling protocol, one that's more
reasonable for normal use cases and with better protocol-level security.

I wouldn't mind merging *incomplete* IPv6 support.  However, I do mind
merging *incompatible* or *incompliant* IPv6 support.

>   - Configurable networking interfaces so that GTP kernel can be
>     used and tested without needing GSN network emulation (i.e. no user
>     space daemon needed).
>   - Addition of a dst_cache in the GTP structure and other cleanup

No issues with this from my side.  I plan on setting up a test system
with your patches over the weekend and give it some more testing from
the use cases I know to avoid regressions.

>   - Common functions to get a route fo for an IP tunnel
>   - Fix VXLAN gro cells initialization

Also no issues from my side, but that's for core networking folks to
decide.

> For IPv6 support, the mobile subscriber needs to allow IPv6 addresses,
> and the remote endpoint can be IPv6.

You are raising the impression - again - that this implementation will
work with any mobile subscriber.  I would bet at lot on the fact that
the current IPv6 implementation will in fact *not* work with any
existing equipment/devices out there.

> Tested:
> 
> Configured the matrix of IPv4/IPv6 mobile subscriber, 

Please indicate how that testing was done, see my comment above.

Regards,
	Harald
-- 
- Harald Welte <laforge@gnumonks.org>           http://laforge.gnumonks.org/
============================================================================
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)
