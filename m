From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 09:25:40 +0200
Message-ID: <46C54D74.60101@s5r6.in-berlin.de>
References: <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de> <20070816104250.GB2927@gondor.apana.org.au> <20070816163441.GB16957@linux.vnet.ibm.com> <46C512EB.7020603@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:35610 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345AbXHQH2A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 03:28:00 -0400
In-Reply-To: <46C512EB.7020603@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nick Piggin wrote:
> I don't know why people would assume volatile of atomics. AFAIK, most
> of the documentation is pretty clear that all the atomic stuff can be
> reordered etc. except for those that modify and return a value.

Which documentation is there?

For driver authors, there is LDD3.  It doesn't specifically cover
effects of optimization on accesses to atomic_t.

For architecture port authors, there is Documentation/atomic_ops.txt.
Driver authors also can learn something from that document, as it
indirectly documents the atomic_t and bitops APIs.

Prompted by this thread, I reread this document, and indeed, the
sentence "Unlike the above routines, it is required that explicit memory
barriers are performed before and after [atomic_{inc,dec}_return]"
indicates that atomic_read (one of the "above routines") is very
different from all other atomic_t accessors that return values.

This is strange.  Why is it that atomic_read stands out that way?  IMO
this API imbalance is quite unexpected by many people.  Wouldn't it be
beneficial to change the atomic_read API to behave the same like all
other atomic_t accessors that return values?

OK, it is also different from the other accessors that return data in so
far as it doesn't modify the data.  But as driver "author", i.e. user of
the API, I can't see much use of an atomic_read that can be reordered
and, more importantly, can be optimized away by the compiler.  Sure, now
that I learned of these properties I can start to audit code and insert
barriers where I believe they are needed, but this simply means that
almost all occurrences of atomic_read will get barriers (unless there
already are implicit but more or less obvious barriers like msleep).
-- 
Stefan Richter
-=====-=-=== =--- =---=
http://arcgraph.de/sr/
