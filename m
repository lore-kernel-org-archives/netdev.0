From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V6 net-next] LISP: Locator/Identifier Separation
 Protocol
Date: Mon, 23 Jun 2014 15:02:06 -0700 (PDT)
Message-ID: <20140623.150206.1941399398042390524.davem@davemloft.net>
References: <9D51E1BB-BAB2-4859-A3E1-2C4F56BAD641@logicalelegance.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vermagan@cisco.com, lojakab@cisco.com
To: chris@logicalelegance.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753752AbaFWWCH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2014 18:02:07 -0400
In-Reply-To: <9D51E1BB-BAB2-4859-A3E1-2C4F56BAD641@logicalelegance.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christopher White <chris@logicalelegance.com>
Date: Fri, 20 Jun 2014 08:26:12 -0700

> 
> This is a static tunnel implementation of LISP as described in RFC 6830:
>   http://tools.ietf.org/html/rfc6830
> 
> This driver provides point-to-point LISP dataplane
> encapsulation/decapsulation for statically configured endpoints. It provides
> support for IPv4 in IPv4 and IPv6 in IPv4. IPv6 outer headers are not
> supported yet. Instance ID is supported on a per device basis.
> 
> This implementation has been tested against LISPMob.
> 
> Changes from V2: Move some functions to common headers. Remove unecessary skb
> ownership change. Minor cleanup.
> Changes from V3: Revert some generic function consolidation for later patches.
> Changes from V4: Indentation (Note V4 was erroneously marked V3)
> Changes from V5: Remove extraneous export
> 
> Signed-off-by: Chris White <chris@logicalelegance.com>

I'm not so sure if this is how we should start supporting LISP at this
time.

The whole point is to be able to dynamically map EIDs to RLOCs on demand,
and this static tunnel neither provides that functionality, nor provides
generic enough infrastructure to add such a facility easily.

Furthermore, LISP fundamentally seems quite DOS'able.  What is to keep one
from having to service a full Map-Request --> Map-Reply cycle for every
packet received?  Just keep spamming packet after packet through the ITR,
specifying a unique and different EID in the destination address each time.

That's exactly the same kind of problem we had internally with the
ipv4 routing cache and that's why we totally removed it.

Also I wonder if whatever a "properly functioning" (whatever that
means, given the DOS'ability of it in dynamic configurations) LISP gives
us is worth the MTU we lose with the encapsulation.

Sorry, I'm not too thrilled about LISP and this patch in particular,
from several different angles.  And therefore I'm going to mark this
patch deferred and not apply it at this time.
