From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 12:03:08 +0800
Message-ID: <20070816040308.GA32133@gondor.apana.org.au>
References: <20070816005348.GA9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151757400.11196@schroedinger.engr.sgi.com> <20070816011414.GC9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708160730590.24380@enigma.security.iitk.ac.in> <20070816020851.GA30809@gondor.apana.org.au> <Pine.LNX.4.64.0708151917210.11736@schroedinger.engr.sgi.com> <18115.49946.522011.832468@cargo.ozlabs.ibm.com> <20070816033343.GA31844@gondor.apana.org.au> <18115.51472.408193.332905@cargo.ozlabs.ibm.com>
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
Received: from rhun.apana.org.au ([64.62.148.172]:3519 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750725AbXHPEDv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 00:03:51 -0400
Content-Disposition: inline
In-Reply-To: <18115.51472.408193.332905@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 01:48:32PM +1000, Paul Mackerras wrote:
> Herbert Xu writes:
> 
> > If you're referring to the code in sk_stream_mem_schedule
> > then it's working as intended.  The atomicity guarantees
> 
> You mean it's intended that *sk->sk_prot->memory_pressure can end up
> as 1 when sk->sk_prot->memory_allocated is small (less than
> ->sysctl_mem[0]), or as 0 when ->memory_allocated is large (greater
> than ->sysctl_mem[2])?  Because that's the effect of the current code.
> If so I wonder why you bother computing it.

You need to remember that there are three different limits:
minimum, pressure, and maximum.  By default we should never
be in a situation where what you say can occur.

If you set all three limits to the same thing, then yes it
won't work as intended but it's still well-behaved.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
