From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 19:35:58 -0700
Message-ID: <20070816023558.GE14613@linux.vnet.ibm.com>
References: <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <18115.35524.56393.347841@cargo.ozlabs.ibm.com> <Pine.LNX.4.64.0708151725130.10497@schroedinger.engr.sgi.com> <20070816003948.GY9645@linux.vnet.ibm.com> <Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com> <18115.44462.622801.683446@cargo.ozlabs.ibm.com> <20070816020042.GA30650@gondor.apana.org.au> <18115.45316.702491.681906@cargo.ozlabs.ibm.com> <20070816021105.GA30883@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
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
	segher@kernel.crashing.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:53364 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755354AbXHPCgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 22:36:03 -0400
Content-Disposition: inline
In-Reply-To: <20070816021105.GA30883@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 10:11:05AM +0800, Herbert Xu wrote:
> On Thu, Aug 16, 2007 at 12:05:56PM +1000, Paul Mackerras wrote:
> > Herbert Xu writes:
> > 
> > > See sk_stream_mem_schedule in net/core/stream.c:
> > > 
> > >         /* Under limit. */
> > >         if (atomic_read(sk->sk_prot->memory_allocated) < sk->sk_prot->sysctl_mem[0]) {
> > >                 if (*sk->sk_prot->memory_pressure)
> > >                         *sk->sk_prot->memory_pressure = 0;
> > >                 return 1;
> > >         }
> > > 
> > >         /* Over hard limit. */
> > >         if (atomic_read(sk->sk_prot->memory_allocated) > sk->sk_prot->sysctl_mem[2]) {
> > >                 sk->sk_prot->enter_memory_pressure();
> > >                 goto suppress_allocation;
> > >         }
> > > 
> > > We don't need to reload sk->sk_prot->memory_allocated here.
> > 
> > Are you sure?  How do you know some other CPU hasn't changed the value
> > in between?
> 
> Yes I'm sure, because we don't care if others have increased
> the reservation.
> 
> Note that even if we did we'd be using barriers so volatile
> won't do us any good here.

If the load-coalescing is important to performance, why not load into
a local variable?

						Thanx, Paul
