From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 16:00:05 +1000
Message-ID: <18115.59365.268987.406001@cargo.ozlabs.ibm.com>
References: <20070816011414.GC9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com>
	<alpine.LFD.0.999.0708160730590.24380@enigma.security.iitk.ac.in>
	<20070816020851.GA30809@gondor.apana.org.au>
	<Pine.LNX.4.64.0708151917210.11736@schroedinger.engr.sgi.com>
	<18115.49946.522011.832468@cargo.ozlabs.ibm.com>
	<20070816033343.GA31844@gondor.apana.org.au>
	<18115.51472.408193.332905@cargo.ozlabs.ibm.com>
	<20070816040308.GA32133@gondor.apana.org.au>
	<18115.54225.644905.463771@cargo.ozlabs.ibm.com>
	<20070816053741.GA32442@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
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
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:35633 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754516AbXHPGAP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 02:00:15 -0400
In-Reply-To: <20070816053741.GA32442@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu writes:

> It doesn't matter.  The memory pressure flag is an *advisory*
> flag.  If we get it wrong the worst that'll happen is that we'd
> waste some time doing work that'll be thrown away.

Ah, so it's the "racy but I don't care because it's only an
optimization" case.  That's fine.  Somehow I find it hard to believe
that all the racy uses of atomic_read in the kernel are like that,
though. :)

> In any case, this actually illustrates why the addition of
> volatile is completely pointless.  Even if this code was
> broken, which it definitely is not, having the volatile
> there wouldn't have helped at all.

Yes, adding volatile to racy code doesn't somehow make it race-free.
Neither does using atomic_t, despite what some seem to believe.

I have actually started going through all the uses of atomic_read in
the kernel.  So far out of the first 100 I have found none where we
have two atomic_reads of the same variable and the compiler could
usefully use the value from the first as the result of the second.
But there's still > 2500 to go...

Paul.
