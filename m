From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 9 Aug 2007 01:25:21 +0200
Message-ID: <20070808232521.GC8460@xi.wantstofly.org>
References: <20070808230733.GA17270@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:47049 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759431AbXHHXZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 19:25:25 -0400
Content-Disposition: inline
In-Reply-To: <20070808230733.GA17270@shell.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 08, 2007 at 07:07:33PM -0400, Chris Snook wrote:

> From: Chris Snook <csnook@redhat.com>
> 
> Some architectures currently do not declare the contents of an atomic_t to be
> volatile.  This causes confusion since atomic_read() might not actually read
> anything if an optimizing compiler re-uses a value stored in a register, which
> can break code that loops until something external changes the value of an
> atomic_t.  Avoiding such bugs requires using barrier(), which causes re-loads
> of all registers used in the loop, thus hurting performance instead of helping
> it, particularly on architectures where it's unnecessary.  Since we generally
> want to re-read the contents of an atomic variable on every access anyway,
> let's standardize the behavior across all architectures and avoid the
> performance and correctness problems of requiring the use of barrier() in
> loops that expect atomic_t variables to change externally.  This is relevant
> even on non-smp architectures, since drivers may use atomic operations in
> interrupt handlers.
> 
> Signed-off-by: Chris Snook <csnook@redhat.com>

Documentation/atomic_ops.txt would need updating:

	[...]

	One very important aspect of these two routines is that they DO NOT
	require any explicit memory barriers.  They need only perform the
	atomic_t counter update in an SMP safe manner.
