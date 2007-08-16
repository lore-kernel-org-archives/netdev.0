From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 11:33:43 +0800
Message-ID: <20070816033343.GA31844@gondor.apana.org.au>
References: <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <20070816005348.GA9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151757400.11196@schroedinger.engr.sgi.com> <20070816011414.GC9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708160730590.24380@enigma.security.iitk.ac.in> <20070816020851.GA30809@gondor.apana.org.au> <Pine.LNX.4.64.0708151917210.11736@schroedinger.engr.sgi.com> <18115.49946.522011.832468@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	Satyam Sharma <satyam@infradead.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
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
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3268 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932509AbXHPDek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 23:34:40 -0400
Content-Disposition: inline
In-Reply-To: <18115.49946.522011.832468@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 01:23:06PM +1000, Paul Mackerras wrote:
>
> In particular, atomic_read seems to lend itself to buggy uses.  People
> seem to do things like:
> 
> 	atomic_add(&v, something);
> 	if (atomic_read(&v) > something_else) ...

If you're referring to the code in sk_stream_mem_schedule
then it's working as intended.  The atomicity guarantees
that the atomic_add/atomic_sub won't be seen in parts by
other readers.

We certainly do not need to see other atomic_add/atomic_sub
operations immediately.

If you're referring to another code snippet please cite.

> I'd go so far as to say that anywhere where you want a non-"volatile"
> atomic_read, either your code is buggy, or else an int would work just
> as well.

An int won't work here because += and -= do not have the
atomicity guarantees that atomic_add/atomic_sub do.  In
particular, this may cause an atomic_read on another CPU
to give a bogus reading.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
