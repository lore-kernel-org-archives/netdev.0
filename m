From: David Miller <davem@davemloft.net>
Subject: Re: bonding: propagation of offload settings
Date: Wed, 24 Nov 2010 12:27:36 -0800 (PST)
Message-ID: <20101124.122736.200378471.davem@davemloft.net>
References: <20101030025435.GF12842@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51208
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756449Ab0KXU1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 15:27:11 -0500
In-Reply-To: <20101030025435.GF12842@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Sat, 30 Oct 2010 11:54:35 +0900

> It seems to me that from a user point of view it may make more sense to:
> 
> a) propagate settings from the master to the slaves and;
> b) possibly disallow setting the slaves directly

Yeah, good question.

Propagation from master to slave(s) would have difficult semantics.
If any of the slave changes fail (f.e. unsupported feature or memory
allocation failure) we'd have to unwind all of the slaves which did
accept the change without error.

What if the unwind operation fails, due to lack of resources?  A lot
of state would thus need to be tracked to support this reasonably.

However we pretty much have to respect whatever changes get made
directly to the slaves, since the master must at all times claim
support for only the lowest common denominator, feature wise, amongst
that master's slaves.
