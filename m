From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 19:32:55 -0700
Message-ID: <20070816023255.GD14613@linux.vnet.ibm.com>
References: <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <18115.35524.56393.347841@cargo.ozlabs.ibm.com> <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com> <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <20070816005348.GA9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151757400.11196@schroedinger.engr.sgi.com> <20070816011414.GC9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
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
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:59941 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755051AbXHPCdA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 22:33:00 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708151839140.11520@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 06:41:40PM -0700, Christoph Lameter wrote:
> On Wed, 15 Aug 2007, Paul E. McKenney wrote:
> 
> > Understood.  My point is not that the impact is precisely zero, but
> > rather that the impact on optimization is much less hurtful than the
> > problems that could arise otherwise, particularly as compilers become
> > more aggressive in their optimizations.
> 
> The problems arise because barriers are not used as required. Volatile 
> has wishy washy semantics and somehow marries memory barriers with data 
> access. It is clearer to separate the two. Conceptual cleanness usually 
> translates into better code. If one really wants the volatile then lets 
> make it explicit and use
> 
> 	atomic_read_volatile()

There are indeed architectures where you can cause gcc to emit memory
barriers in response to volatile.  I am assuming that we are -not-
making gcc do this.  Given this, then volatiles and memory barrier
instructions are orthogonal -- one controls the compiler, the other
controls the CPU.

						Thanx, Paul
