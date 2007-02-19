From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: Extensible hashing and RCU
Date: Mon, 19 Feb 2007 13:38:07 -0500
Message-ID: <20070219183807.GC10587@kvack.org>
References: <20070204074143.26312.qmail@science.horizon.com> <20070219142504.GA5626@2ka.mipt.ru> <200702191614.49666.dada1@cosmosbay.com> <200702191913.08125.dada1@cosmosbay.com> <20070219182642.GB10587@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, akepner@sgi.com,
	linux@horizon.com, davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:58861 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932478AbXBSSiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 13:38:14 -0500
Content-Disposition: inline
In-Reply-To: <20070219182642.GB10587@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 19, 2007 at 01:26:42PM -0500, Benjamin LaHaise wrote:
> On Mon, Feb 19, 2007 at 07:13:07PM +0100, Eric Dumazet wrote:
> > So even with a lazy hash function, 89 % of lookups are satisfied with less 
> > than 6 compares.
> 
> Which sucks, as those are typically going to be cache misses (costing many 
> hundreds of cpu cycles).  Hash chains fair very poorly under DoS conditions, 
> and must be removed under a heavy load.  Worst case handling is very 
> important next to common case.

I should clarify.  Back of the napkin calculations show that there is only 
157 cycles on a 3GHz processor in which to decide what happens to a packet, 
which means 1 cache miss is more than enough.  In theory we can get pretty 
close to line rate with quad core processors, but it definately needs some 
of the features that newer chipsets have for stuffing packets directly into 
the cache.  I would venture a guess that we also need to intelligently 
partition packets so that we make the most use of available cache resources.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
