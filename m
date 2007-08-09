From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] make atomic_t volatile on all architectures
Date: Thu, 09 Aug 2007 09:03:27 +0800
Message-ID: <E1IIwQx-000468-00@gondolin.me.apana.org.au>
References: <20070808230733.GA17270@shell.boston.redhat.com>
Cc: akpm@linux-foundation.org, torvalds@linux-foundation.org,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org
To: csnook@redhat.com (Chris Snook)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2072 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932591AbXHIBFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 21:05:20 -0400
In-Reply-To: <20070808230733.GA17270@shell.boston.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Snook <csnook@redhat.com> wrote:
> 
> Some architectures currently do not declare the contents of an atomic_t to be
> volatile.  This causes confusion since atomic_read() might not actually read
> anything if an optimizing compiler re-uses a value stored in a register, which
> can break code that loops until something external changes the value of an
> atomic_t.  Avoiding such bugs requires using barrier(), which causes re-loads

Such loops should always use something like cpu_relax() which comes
with a barrier.

> of all registers used in the loop, thus hurting performance instead of helping
> it, particularly on architectures where it's unnecessary.  Since we generally

Do you have an example of such a loop where performance is hurt by this?

The IPVS code that led to this patch was simply broken and has been
fixed to use cpu_relax().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
