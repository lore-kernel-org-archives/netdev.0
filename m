From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Fri, 17 Aug 2007 07:59:02 +0800
Message-ID: <20070816235902.GB11594@gondor.apana.org.au>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de> <20070816104250.GB2927@gondor.apana.org.au> <20070816163441.GB16957@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Richter <stefanr@s5r6.in-berlin.de>,
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
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763985AbXHQABW@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070816163441.GB16957@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 09:34:41AM -0700, Paul E. McKenney wrote:
>
> The compiler can also reorder non-volatile accesses.  For an example
> patch that cares about this, please see:
> 
> 	http://lkml.org/lkml/2007/8/7/280
> 
> This patch uses an ORDERED_WRT_IRQ() in rcu_read_lock() and
> rcu_read_unlock() to ensure that accesses aren't reordered with respect
> to interrupt handlers and NMIs/SMIs running on that same CPU.

Good, finally we have some code to discuss (even though it's
not actually in the kernel yet).

First of all, I think this illustrates that what you want
here has nothing to do with atomic ops.  The ORDERED_WRT_IRQ
macro occurs a lot more times in your patch than atomic
reads/sets.  So *assuming* that it was necessary at all,
then having an ordered variant of the atomic_read/atomic_set
ops could do just as well.

However, I still don't know which atomic_read/atomic_set in
your patch would be broken if there were no volatile.  Could
you please point them out?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
